resource "github_repository" "managed_repositories" {
  for_each = local.repositories_map

  name        = each.key
  description = each.value.description
  topics      = each.value.topics

  gitignore_template = each.value.gitignore_template

  delete_branch_on_merge = each.value.delete_branch_on_merge

  visibility = each.value.visibility

  is_template = each.value.is_template

  vulnerability_alerts = each.value.enable_vulnerability_alerts

  has_issues      = each.value.has_issues
  has_discussions = each.value.has_discussions
  has_projects    = each.value.has_projects
  has_wiki        = each.value.has_wiki

  # Hack Aug 2024
  # For some reason, the GH provider returns a 422 when applying the default secret scanning config (i.e disabled)
  # to private repos. This should fix it by giving it an empty security_and_analysis config.
  # Source: https://github.com/integrations/terraform-provider-github/issues/2145
  dynamic "security_and_analysis" {
    for_each = each.value.enable_secret_scanning == "enabled" ? [0] : []
    content {
      secret_scanning {
        status = "enabled"
      }
    }
  }

  dynamic "template" {
    for_each = each.value.uses_template == true ? [0] : []
    content {
      owner                = each.value.template_owner
      repository           = each.value.template_repository_name
      include_all_branches = false
    }
  }
}

# Github only allows branch protection rules for public repos (unless we pay $$$), 
# however some of the repos in this org will be private, thus only public repos can have branch protection rules.
# TODO: Sort this.
# resource "github_branch_protection" "managed_repositories_branch_protections" {
#   for_each = local.repositories_map

#   repository_id = each.key

#   pattern          = "main"
#   enforce_admins   = true
#   allows_deletions = false

#   require_conversation_resolution = true

#   allows_force_pushes  = each.value.allows_force_pushes
#   force_push_bypassers = each.value.force_push_bypassers

#   depends_on = [github_repository.managed_repositories]
# }

# One list of collaborators per managed repository
resource "github_repository_collaborators" "managed_repositories_collaborators" {
  for_each = local.collaborators_map

  repository = each.key

  dynamic "user" {
    for_each = each.value
    content {
      username   = each.value.username
      permission = each.value.permission
    }
  }

  depends_on = [github_repository.managed_repositories]
}

resource "github_repository_dependabot_security_updates" "managed_repositories_dependabot_updates" {
  for_each = local.repositories_map

  repository = each.key
  enabled    = each.value.enable_dependabot_updates

  depends_on = [github_repository.managed_repositories]
}