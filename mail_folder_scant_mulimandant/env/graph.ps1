# env\graph.ps1
$Global:Graph = @{
  DefaultSenderUPN   = 'diamant@mode-jost.de'  # default sender
  SendMode           = 'PerFile'               # PerFile | PerCompany
  AllowedExt         = @('.pdf','.png','.jpg','.jpeg','.tif','.tiff')
  MaxTotalMB         = 18
  MaxFilesPerMail    = 40
  MoveOnMessageOnly  = $false                  # move to DONE even if message had no attachments
}
