#!/usr/bin/env bash
set -e

git config --local user.email "41898282+github-actions[bot]@users.noreply.github.com"
git config --local user.name "github-actions[bot]"
git add plugin-issue.json
git commit -m "🔄 Update plugin-issue.json - ${PLUGINS_COUNT:-0} plugins collected" || echo "No changes to commit"
git push


