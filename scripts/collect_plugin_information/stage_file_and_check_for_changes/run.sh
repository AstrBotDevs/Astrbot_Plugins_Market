#!/usr/bin/env bash
set -e

# stage the generated file (ensures new/untracked files are considered)
git add plugin-issue.json || true

# If there are staged changes compared to HEAD, exit code will be non-zero
if git diff --staged --quiet --exit-code; then
  echo "has_changes=false" >> "$GITHUB_OUTPUT"
  echo "No changes detected (no staged changes)"
else
  echo "has_changes=true" >> "$GITHUB_OUTPUT"
  echo "Staged changes detected"
fi


