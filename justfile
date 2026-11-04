set shell := ["bash", "-euo", "pipefail", "-c"]

# List recipes
default:
    @just --list

# Copy the reference examples from a provider release (a tag such as v1.4.2)
sync TAG:
    #!/usr/bin/env bash
    set -euo pipefail
    src=$(mktemp -d); trap 'rm -rf "$src"' EXIT
    git -c advice.detachedHead=false clone -q --depth 1 --branch "{{TAG}}" https://github.com/Vulnetix/terraform-provider-resolve.git "$src"
    find terraform -maxdepth 1 -name '*.tf' ! -name versions.tf ! -name provider.tf -delete
    rm -f yaml/*.yaml
    for d in "$src"/examples/resources/vulnetix_*/; do
        type=$(basename "$d"); type=${type#vulnetix_}
        cp "$d/reference.tf" "terraform/$type.tf"
        kind=$(awk '/^kind:/ {print $2; exit}' "$d/reference.yaml")
        cp "$d/reference.yaml" "yaml/$kind.yaml"
    done
    echo "{{TAG}}" > PROVIDER_VERSION
    echo "synced $(ls terraform | wc -l) Terraform files and $(ls yaml | wc -l) YAML documents from {{TAG}}"

# Format check and validate (no credentials needed)
check:
    terraform -chdir=terraform fmt -check
    terraform -chdir=terraform init -backend=false -input=false >/dev/null
    terraform -chdir=terraform validate

# Plan against your tenant (VULNETIX_API_KEY and VULNETIX_ORG_ID in the environment)
plan:
    terraform -chdir=terraform init -input=false >/dev/null
    terraform -chdir=terraform plan -input=false
