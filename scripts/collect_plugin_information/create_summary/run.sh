#!/usr/bin/env bash
set -e

{
  echo "## Plugin Collection Summary"
  echo "- **Total plugins collected:** ${PLUGINS_COUNT:-0}"
  echo "- **Changes detected:** ${HAS_CHANGES:-false}"
  echo "- **Timestamp:** $(date --iso-8601=seconds)"

  if [ -f "plugin-issue.json" ]; then
    echo ""
    echo "### Latest plugin-issue.json preview:"
    echo '```json'
    head -40 plugin-issue.json
    echo '```'
  fi
} >> "$GITHUB_STEP_SUMMARY"


