#!/bin/bash
set -exuo pipefail

json=$(curl -fsSL "https://api.github.com/repos/whisparr/whisparr/actions/runs" | jq -re '[.workflow_runs[] | select(.name == "Build") | select(.conclusion == "success") | select(.event == "pull_request") | select(.actor.login != "dependabot[bot]")| .][0]')
version=$(jq -re '.head_sha' <<< "${json}")
version_branch=$(jq -re '.head_branch' <<< "${json}")
url=$(jq -re '.artifacts_url' <<< "${json}")
json_artifacts=$(jq -re '.artifacts[]' <<< "$(curl -fsSL "${url}?per_page=100")")
version_url_amd64=$(jq -re '. | select(.name | contains("release-linux-musl-x64")) | .archive_download_url' <<< "${json_artifacts}")
version_url_arm64=$(jq -re '. | select(.name | contains("release-linux-musl-arm64")) | .archive_download_url' <<< "${json_artifacts}")

json=$(cat meta.json)
jq --sort-keys \
    --arg version "${version}" \
    --arg version_branch "${version_branch}" \
    --arg version_url_arm64 "${version_url_arm64}" \
    --arg version_url_amd64 "${version_url_amd64}" \
    '.version = $version | .version_branch = $version_branch | .version_url_arm64 = $version_url_arm64 | .version_url_amd64 = $version_url_amd64' <<< "${json}" | tee meta.json
