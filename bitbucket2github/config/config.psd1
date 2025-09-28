@{
  # Bitbucket (API: email + API token, Git clone: SSH)
  BBWorkspace      = 'insidednymaic'
  BBAuthMode       = 'SSH'
  BBUser           = 'viktor.nikolayev@gmail.com'     # e-mail для API
  BBAppPassword    = 'ATATT3xFfGF0pHOmJZvEg2PQLmAhNge2Yl8uW6kgtnVARWuyPL2S03gk9F7TtEd-YWa-OO9jhnv73AEbmk4wedExW7OaCh_UgqxWSZQR0ujdE57QWkPbl-1zBhYNrHFB6NV7CeYE4nyUQZQ9f0cBNPXBBmO5e318E1aZC3hJQlsRXI3baOIsNgY=338E3735' # новый API-токен
  UseRepoListFile  = $false                            # тянуть все репо через API

  # GitHub
  GHOwer           = 'ViktorNikolayevIndyn'
  GHAuthMode       = 'SSH'
  GHToken          = ''
  Visibility       = 'private'

  # Миграция
  IncludeWiki      = $true
  IncludeLFS       = $true
  RewriteBotEmail  = $true
  NewEmail         = 'vn@insidedynamic.de'
  DryRun           = $false
  DownloadOnly     = $true     # сначала делаем локальный бэкап без пуша

  # Пути
  WorkDir          = 'C:\PROJECT\scripts_git\bitbucket2github\work'
  RepoListFile     = 'C:\PROJECT\scripts_git\bitbucket2github\config\repos.txt'
  LogDir           = 'C:\PROJECT\scripts_git\bitbucket2github\logs'
}
