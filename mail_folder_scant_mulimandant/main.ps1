# main.ps1
param([switch]$DryRun, [string]$Root = $PSScriptRoot, [string]$Only)

. (Join-Path $Root 'functions.ps1')
Load-EnvRoot $Root

# default cred profile -> token
$def    = Get-CredProfile 'default'
$secret = Get-ClientSecret $def.SecretEnvVar
$token  = Get-GraphToken $def.TenantId $def.ClientId $secret

if(-not (Test-GraphHealth $token $Global:Graph.DefaultSenderUPN)){
  throw 'Graph health failed'
}

$work = Build-Work $Global:Companies $Global:Graph
if($Only){ $work = $work | Where-Object { $_.Company.Name -eq $Only } }
if($work.Count -eq 0){ Write-Info 'Nothing to send.'; exit 0 }

foreach($w in $work){
  $c = $w.Company
  $sender = if([string]::IsNullOrWhiteSpace($c.SendFromUPN)) { $Global:Graph.DefaultSenderUPN } else { $c.SendFromUPN }

  # company-specific cred profile
  $prof   = Get-CredProfile $c.CredName
  $secret = Get-ClientSecret $prof.SecretEnvVar
  $token  = Get-GraphToken $prof.TenantId $prof.ClientId $secret

  if($Global:Graph.SendMode -eq 'PerCompany'){
    $paths = @()
    if($c.Attachment){ $paths = $w.Files | Select-Object -ExpandProperty FullPath }
    $stub    = @{ FileName='batch' }
    $subject = Expand-Template $Global:EmailConfig.SubjectTpl $stub $c
    $body    = Expand-Template $Global:EmailConfig.BodyHtmlTpl $stub $c

    $totalBytes = (($w.Files | ForEach-Object { (Get-Item -LiteralPath $_.FullPath).Length }) | Measure-Object -Sum).Sum
    $count      = $w.Files.Count
    $rcpt       = ($c.SendTo -join '; ')

    if($DryRun){
      Write-Host ("batch({0} files, {1}) -> {2} - DRY-RUN" -f $count, (Format-Size $totalBytes), $rcpt)
      continue
    }

    $ok = Send-GraphMail $token $sender $c.SendTo $subject $body $paths
    if($ok){
      Write-Host ("batch({0} files, {1}) -> {2} - OK" -f $count, (Format-Size $totalBytes), $rcpt)
      if($paths.Count -gt 0 -or $Global:Graph.MoveOnMessageOnly){
        Move-ToDone $c.FolderPath ($w.Files | Select-Object -ExpandProperty FullPath)
      }
    } else {
      Write-Host ("batch -> {0} - FAIL" -f $rcpt)
    }
  } else {
    foreach($f in $w.Files){
      $subject = Expand-Template $Global:EmailConfig.SubjectTpl $f $c
      $body    = Expand-Template $Global:EmailConfig.BodyHtmlTpl $f $c
      $paths   = if($c.Attachment){ @($f.FullPath) } else { @() }

      $fi   = Get-Item -LiteralPath $f.FullPath
      $rcpt = ($c.SendTo -join '; ')

      if($DryRun){
        Write-Host ("{0} -> {1} ({2}) - DRY-RUN" -f $fi.Name, $rcpt, (Format-Size $fi.Length))
        continue
      }

      $ok = Send-GraphMail $token $sender $c.SendTo $subject $body $paths
      if($ok){
        Write-Host ("{0} -> {1} ({2}) - OK" -f $fi.Name, $rcpt, (Format-Size $fi.Length))
        if($paths.Count -gt 0 -or $Global:Graph.MoveOnMessageOnly){
          Move-ToDone $c.FolderPath @($f.FullPath)
        }
      } else {
        Write-Host ("{0} -> {1} - FAIL" -f $fi.Name, $rcpt)
      }
    }
  }
}
