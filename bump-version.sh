#!/bin/bash

set -euo pipefail

git diff-index --quiet HEAD || { echo "error: dirty repository"; exit 1; }

current_version=$(tr -d '\n' < VERSION)
IFS='.' read -ra version_array <<< "$current_version"
major="${version_array[0]}"
minor="${version_array[1]}"
bugfix="${version_array[2]}"

action="${1:-0}"
if [[ "$action" == "major" ]]; then
    major=$((major + 1))
elif [[ "$action" == "minor" ]]; then
    minor=$((minor + 1))
elif [[ "$action" == "bugfix" ]]; then
    bugfix=$((bugfix + 1))
else
    echo "Expected argument: major, minor or bugfix"
    exit 1
fi

# Ensure we won't leave a dirty repository if the script is interrupted.
trap 'git reset HEAD . > /dev/null && git checkout HEAD . > /dev/null' INT TERM HUP EXIT

new_version="$major.$minor.$bugfix"
echo "Bumping version to $new_version"

files=(
    "VERSION"
    "README.md"
    "SimpleMDM-Swift.podspec"
    ".jazzy.yaml"
)

echo
for file in "${files[@]}"; do
    echo "Updating version in $file..."
    sed -i '' -e "s/$current_version/$new_version/" "$file"
done

echo
echo "Updating documentation..."
jazzy

echo
echo "Committing changes..."
git add .
git commit -m "Bump version $current_version -> $new_version"
git tag -m "$new_version" "$new_version"
git --no-pager show --summary

echo
echo "Don't forget to release the new version of the Pod by running"
echo "  git push; git push --tags"
echo "  pod trunk push SimpleMDM-Swift.podspec"
