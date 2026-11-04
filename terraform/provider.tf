# Credentials come from the environment, never from a file:
#   VULNETIX_API_KEY and VULNETIX_ORG_ID: the ApiKey of a developer service account
#   (or VULNETIX_API_TOKEN: an Authentik access token of the Platform IaC application).
provider "vulnetix" {}
