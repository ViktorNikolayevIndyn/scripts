@{
  # ===== Bitbucket (Cloud) =====
  BBWorkspace              = 'insidednymaic'
  BBAuthMode               = 'HTTPS'
  BBUser                   = 'viktor.nikolayev@gmail.com'   # Atlassian email for REST API
  BBAppPassword            = ''                              # API token (leave empty to use env var)
  BBGitUser                = 'vnikolayev'                    # Bitbucket username for Git over HTTPS

  # ===== GitHub =====
  GHOwer                   = 'ViktorNikolayevIndyn'
  GHAuthMode               = 'SSH'
  GHToken                  = ''
  
  # ===== Migration toggles =====
  UseRepoListFile          = $false
  IncludeWiki              = $true
  IncludeLFS               = $true
  RewriteBotEmail          = $true
  NewEmail                 = 'vn@insidedynamic.de'
  DryRun                   = $false
  DownloadOnly             = $true

  # ===== Naming / Target repo =====
  TargetNameTemplate       = '{PROJECT}.{REPO}'
  TargetNameLowercase      = $true
  TargetNameReplaceMap     = @{ ' ' = '-'; '_' = '-' }
  TargetNameCollisionSuffix= '-index{N}'
  OwnerPerProjectMap       = @{}

  # ===== GitHub Projects / Teams / Topics =====
  UseTopics                = $true
  ProjectTopicPrefix       = 'project'
  CreateTeams              = $true
  DefaultTeamPermission    = 'maintain'
  UseGHProjects            = $true
  GHProjectOwner           = 'ViktorNikolayevIndyn'
  GHProjectTitleFormat     = '{KEY} - {NAME}'
  GHProjectCreateIfMissing = $true
  GHProjectAddRepoItems    = $true
  GHProjectStatusField     = 'Status'
  GHProjectStatusValue     = 'Migrated'

  # ===== Manifest / bookkeeping =====
  ManifestPath             = '.\config\repos-manifest.csv'
  ManifestIdPrefix         = 'bb2gh-'
  TargetVisibilityDefault  = 'private'

  # ===== Paths (all relative) =====
  WorkDir                  = '.\work'
  RepoListFile             = '.\config\repos.txt'
  LogDir                   = '.\logs'
  ConfigDir                = '.\config'
}
