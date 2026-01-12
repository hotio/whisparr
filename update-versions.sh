#!/bin/bash
set -exuo pipefail

sbranch="eros"
version=$(curl -fsSL "https://whisparr.servarr.com/v1/update/${sbranch}/changes?os=linuxmusl&runtime=netcore&arch=x64" | jq -re '.[0].version')
json=$(cat meta.json)
jq --sort-keys \
    --arg version "${version//v/}" \
    --arg sbranch "${sbranch}" \
    '.version = $version | .sbranch = $sbranch' <<< "${json}" | tee meta.json
