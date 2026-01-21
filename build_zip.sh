#!/usr/bin/env bash
set -euo pipefail

FOLDER="MudcrabTracker"
FOLDER_BIN="bin"

version="$(grep -E '^## Version:' MudcrabTracker.txt \
    | sed -E 's/^## Version:[[:space:]]*//' \
    | tr -d '\r')"

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
cp LootLogger.lua "$FOLDER"/
cp Init.lua "$FOLDER"/

zip -r "$ZIPNAME" "$FOLDER"

# Create bin folder if it doesn't exist
mkdir -p "$FOLDER_BIN"
mv "$ZIPNAME" "$FOLDER_BIN"/

rm -rf "$FOLDER"

echo "Created $ZIPNAME"
