# env\email.ps1
$Global:EmailConfig = @{
  SubjectTpl = 'Rechnung {FileName} - {FirmName}'
  BodyHtmlTpl = '<p>Neue Rechnung: {FileName}</p> fuer Firma {FirmName}'
}
