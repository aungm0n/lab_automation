#!/usr/bin/env bash

set -euo pipefail

# Path to your Terraform directory
TF_DIR="$(cd "$(dirname "$0")/../../terraform" && pwd)"

cd "$TF_DIR"

terraform output -json ansible_inventory | jq '
{
  "_meta": {
    "hostvars":
      with_entries(
        .value |= {
          ansible_host: .ansible_host,
          ansible_user: .ansible_user
        }
      )
  },
  "all": {
    "hosts": keys
  }
}'