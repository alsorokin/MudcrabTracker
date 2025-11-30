#!/usr/bin/env bash
set -euo pipefail

FOLDER="MudcrabTracker"

version="$(grep -E '^## Version:' MudcrabTracker.txt | sed -E 's/^## Version:[[:space:]]*//')"
if [[ -z "$version" ]]; then
  echo "Version not found in MudcrabTracker.txt"
  exit 1
fi

ZIPNAME="MudcrabTracker_${version}.zip"

rm -rf "$FOLDER" "$ZIPNAME"
mkdir "$FOLDER"

cp MudcrabTracker.lua "$FOLDER"/
cp MudcrabTracker.txt "$FOLDER"/
cp MudcrabTracker.xml "$FOLDER"/

zip -r "$ZIPNAME" "$FOLDER"

rm -rf "$FOLDER"

echo "Created $ZIPNAME"