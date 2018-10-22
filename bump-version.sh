#!/bin/bash

set -euo pipefail

current_version=$(tr -d '\n' < VERSION)
IFS='.' read -ra version_array <<< "$current_version"
major="${version_array[0]}"
minor="${version_array[1]}"
bugfix="${version_array[2]}"

action="$1"
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

new_version="$major.$minor.$bugfix"
new_build="$(git rev-list HEAD --count)"
echo "Bumping version to $new_version (build $new_build)"

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
xcrun agvtool new-version -all "$new_build"
xcrun agvtool new-marketing-version "$new_version"

echo
echo "Updating documentation..."
jazzy

git tag -m "$new_version ($new_build)" "$new_version"
