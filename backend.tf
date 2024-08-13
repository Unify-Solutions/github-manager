terraform {
  cloud {

    organization = "Unify-Solutions"

    workspaces {
      name = "github-iac"
    }
  }
}