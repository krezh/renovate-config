#!/usr/bin/env bash
set -euo pipefail

# Usage: get-repos.sh
# Outputs a JSON array of repository objects with metadata
# Example: repos=[{"name":"dotnix","nix":true},{"name":"containers","nix":false}]
#
# Environment variables:
#   LIST_REPOS_PAT - GitHub token
#   INPUTS_REPO - Manual repo override
#   GITHUB_EVENT_CLIENT_PAYLOAD_REPO - Dispatch repo
#   OWNER - Repository owner
#   RENOVATE_TOPIC - Topic to filter repos
#   DOCKER_CMD_TOPIC - Topic to identify nix repos (default: nix)
#   INCLUDE_ARCHIVED - Include archived repos (default: false)

# Required environment variables
: "${OWNER:?OWNER environment variable is required}"
: "${RENOVATE_TOPIC:?RENOVATE_TOPIC environment variable is required}"
: "${LIST_REPOS_PAT:?LIST_REPOS_PAT environment variable is required}"

# Optional with defaults
DOCKER_CMD_TOPIC="${DOCKER_CMD_TOPIC:-nix}"
INCLUDE_ARCHIVED="${INCLUDE_ARCHIVED:-false}"

if [ -z "${INPUTS_REPO:-}" ] && [ -z "${GITHUB_EVENT_CLIENT_PAYLOAD_REPO:-}" ]; then
  # Autodiscover mode - search for all repos with renovate-enabled topic
  response=$(curl -SsL -H "Accept: application/vnd.github.mercy-preview+json" \
    -H "Authorization: Bearer ${LIST_REPOS_PAT}" \
    "https://api.github.com/search/repositories?q=user:${OWNER}+topic:${RENOVATE_TOPIC}")

  repos=$(echo "${response}" | jq -c --arg nix_topic "${DOCKER_CMD_TOPIC}" \
    "[.items[] | select(.archived == ${INCLUDE_ARCHIVED} and .visibility == \"public\") | {name: .name, nix: (.topics | contains([\$nix_topic]))}]")
else
  # Manual mode - get specific repo info
  repo="${INPUTS_REPO:-${GITHUB_EVENT_CLIENT_PAYLOAD_REPO}}"

  response=$(curl -SsL -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer ${LIST_REPOS_PAT}" \
    "https://api.github.com/repos/${OWNER}/${repo}")

  has_nix=$(echo "${response}" | jq -r --arg topic "${DOCKER_CMD_TOPIC}" \
    '[.topics[]? | select(. == $topic)] | length > 0')

  repos="[{\"name\":\"${repo}\",\"nix\":${has_nix}}]"
fi

echo "repos=${repos}"
