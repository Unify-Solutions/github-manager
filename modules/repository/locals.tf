locals {
  # New repositories are added to this list
  repositories_list = [
    {
      name        = "BaseTemplate"
      description = ""
      topics      = [""]

      visibility = "public"

      gitignore_template = "" # name as found on https://github.com/github/gitignore

      delete_branch_on_merge = true

      is_template = true

      enable_vulnerability_alerts = true
      enable_dependabot_updates   = true

      has_issues      = true
      has_discussions = false
      has_projects    = false
      has_wiki        = false

      allows_force_pushes = false
      force_push_bypassers = [
        "/RazvanBerbece",
        "/fhatti"
      ]

      collaborators = [
        {
          username   = "ant-devbot"
          permission = "admin"
        }
      ]
    }
    
  ]
}


# These shouldn't change, unless extra configuration values are added to the repositories above
locals {
  repositories_map = tomap({
    for repository in local.repositories_list :
    repository.name => {
      description                 = repository.description
      topics                      = repository.topics
      visibility                  = repository.visibility
      gitignore_template          = repository.gitignore_template
      delete_branch_on_merge      = repository.delete_branch_on_merge
      is_template                 = repository.is_template
      has_issues                  = repository.has_issues
      has_discussions             = repository.has_discussions
      has_projects                = repository.has_projects
      has_wiki                    = repository.has_wiki
      allows_force_pushes         = repository.allows_force_pushes
      force_push_bypassers        = repository.force_push_bypassers
      enable_vulnerability_alerts = repository.enable_vulnerability_alerts
      enable_dependabot_updates   = repository.enable_dependabot_updates
    }
  })

  # Reformat the collaborators into a map of repo => {username; perms}
  flattened_collaborators = flatten([
    for repository in local.repositories_list : [
      for collaborator in repository.collaborators : {
        repository_name = repository.name
        username        = collaborator.username
        permission      = collaborator.permission
      }
    ]
  ])
  collaborators_map = {
    for collaborator in local.flattened_collaborators :
    collaborator.repository_name => {
      username   = collaborator.username
      permission = collaborator.permission
    }
  }
}