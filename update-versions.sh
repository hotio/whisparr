#!/bin/bash
set -exuo pipefail

json=$(curl -fsSL "https://api.github.com/repos/Whisparr/Whisparr/releases" | jq -re 'map(select(.prerelease == false)) | first')
version=$(jq -re '.tag_name' <<< "${json}" | sed 's/^v//')
version_url_arm64=$(jq -re '.assets[].browser_download_url | select(contains("linux-musl-arm64"))' <<< "${json}")
version_url_amd64=$(jq -re '.assets[].browser_download_url | select(contains("linux-musl-x64"))' <<< "${json}")
json=$(cat meta.json)
jq --sort-keys \
    --arg version "${version}" \
    --arg version_url_arm64 "${version_url_arm64}" \
    --arg version_url_amd64 "${version_url_amd64}" \
    '.version = $version | .version_url_arm64 = $version_url_arm64 | .version_url_amd64 = $version_url_amd64' <<< "${json}" | tee meta.json
