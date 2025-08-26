#!/usr/bin/env bash
set -e

git fetch origin main --depth=1

# 在 Actions 的 detached HEAD 下也能切换到 main
if git rev-parse --abbrev-ref HEAD | grep -q '^HEAD$'; then
  git checkout -B main origin/main
else
  git checkout main 2>/dev/null || git checkout -b main origin/main
fi

# 使用 autostash 自动 stash 未暂存更改，rebase 完成后会自动 pop
if git pull --rebase --autostash origin main; then
  echo "✅ pull --rebase --autostash 成功"
else
  echo "❌ pull --rebase --autostash 失败，工作流将退出以便人工检查"
  git rebase --abort 2>/dev/null || true
  exit 1
fi


