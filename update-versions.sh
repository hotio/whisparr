#!/bin/bash
set -exuo pipefail

version_branch=$(curl -fsSL "https://api.github.com/repos/whisparr/whisparr/pulls?state=open&sort=updated&direction=desc" | jq -re '[.[] | select((.head.repo.full_name == "Whisparr/Whisparr") and (.head.ref | contains("dependabot") | not) and (.base.ref == "develop" or .base.ref == "eros")) | .head.ref][0]')
version=$(curl -fsSL "https://whisparr.servarr.com/v1/update/${version_branch}/changes?os=linuxmusl&runtime=netcore&arch=x64" | jq -re '.[0].version')
curl -fsSL "https://whisparr.servarr.com/v1/update/${version_branch}/updatefile?version=${version}&os=linuxmusl&runtime=netcore&arch=x64" -o /dev/null
json=$(cat meta.json)
jq --sort-keys \
    --arg version "${version//v/}" \
    --arg version_branch "${version_branch}" \
    '.version = $version | .version_branch = $version_branch' <<< "${json}" | tee meta.json
