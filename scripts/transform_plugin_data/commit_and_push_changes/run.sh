#!/usr/bin/env bash
set -e

# 验证认证状态
echo "验证Git认证状态..."
if git ls-remote origin HEAD > /dev/null 2>&1; then
  echo "✅ Git认证成功"
else
  echo "❌ Git认证失败，检查PAT_TOKEN权限"
  exit 1
fi

# 添加和提交文件
git add plugin_cache_original.json

# 获取统计信息用于提交信息（与转换输出对齐：扁平对象）
total_plugins=$(jq 'keys | length' plugin_cache_original.json 2>/dev/null || echo "0")
success_repos=$(jq '[.[] | select(.status == "success")] | length' repo_info.json 2>/dev/null || echo "0")

commit_message="🔄 Update plugin cache: $total_plugins plugins, $success_repos fresh updates - $(date -u '+%Y-%m-%d %H:%M:%S UTC')"

git commit -m "$commit_message"

# 推送更改
echo "推送更改到远程仓库..."
if git push origin HEAD; then
  echo "✅ 成功推送到远程仓库"
else
  echo "❌ 推送失败，可能是权限问题"
  exit 1
fi


