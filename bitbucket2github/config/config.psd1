@{
  # ===== Bitbucket =====
  BBWorkspace      = 'insidedynamic'     # Workspace slug (organization ID in Bitbucket)
  BBAuthMode       = 'SSH'               # SSH | HTTPS
  BBUser           = ''                  # Needed only for HTTPS
  BBAppPassword    = ''                  # Needed only for HTTPS

  # ===== GitHub =====
  GHOwer           = 'ViktorNikolayevIndyn' # GitHub account/org
  GHAuthMode       = 'SSH'               # SSH | HTTPS
  GHToken          = ''                  # Needed only for HTTPS (Personal Access Token)
  Visibility       = 'private'           # private | public

  # ===== Migration settings =====
  UseRepoListFile  = $true               # true → use repos.txt, false → query Bitbucket API
  IncludeWiki      = $true
  IncludeLFS       = $true
  RewriteBotEmail  = $true               # rewrite @bots.bitbucket.org emails
  NewEmail         = 'vn@insidedynamic.de'
  DryRun           = $false

  # ===== Paths =====
  WorkDir          = 'C:\PROJECT\bb2gh\work'
  RepoListFile     = 'C:\PROJECT\bb2gh\config\repos.txt'
  LogDir           = 'C:\PROJECT\bb2gh\logs'
}
