#!/bin/bash
set -exuo pipefail

branch=$(curl -fsSL "https://api.github.com/repos/whisparr/whisparr/pulls?state=open&sort=updated&direction=desc" | jq -re '[.[] | select((.head.repo.full_name == "Whisparr/Whisparr") and (.head.ref | contains("dependabot") | not) and (.base.ref == "develop" or .base.ref == "eros")) | .head.ref][0]')
version=$(curl -fsSL "https://whisparr.servarr.com/v1/update/${branch}/changes?os=linuxmusl&runtime=netcore&arch=x64" | jq -re '.[0].version')
curl -fsSL "https://whisparr.servarr.com/v1/update/${branch}/updatefile?version=${version}&os=linuxmusl&runtime=netcore&arch=x64" -o /dev/null
json=$(cat VERSION.json)
jq --sort-keys \
    --arg version "${version//v/}" \
    --arg branch "${branch}" \
    '.version = $version | .branch = $branch' <<< "${json}" | tee VERSION.json
