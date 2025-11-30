#!/usr/bin/env bash
set -e

FOLDER="MudcrabTracker"
rm -rf "$FOLDER"
mkdir "$FOLDER"

cp MudcrabTracker.lua "$FOLDER"/
cp MudcrabTracker.txt "$FOLDER"/
cp MudcrabTracker.xml "$FOLDER"/

zip -r MudcrabTracker.zip "$FOLDER"

rm -rf "$FOLDER"

echo "Created MudcrabTracker.zip"

