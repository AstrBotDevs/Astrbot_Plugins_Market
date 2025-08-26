#!/usr/bin/env bash
set -e

echo "检查文件状态..."

echo "检查远程仓库是否存在 plugin_cache_original.json..."
if git ls-tree --name-only -r origin/main | grep -q "^plugin_cache_original.json$"; then
  echo "文件在远程仓库中已存在"
  remote_exists="true"
else
  echo "文件在远程仓库中不存在"
  remote_exists="false"
fi

echo "检查本地 plugin_cache_original.json 是否存在..."
if [ -f plugin_cache_original.json ]; then
  echo "文件存在，大小: $(wc -c < plugin_cache_original.json) bytes"
  # 验证JSON格式
  if jq empty plugin_cache_original.json > /dev/null 2>&1; then
    echo "✅ JSON格式有效"
  else
    echo "❌ JSON格式无效"
    echo "has_changes=false" >> "$GITHUB_OUTPUT"
    exit 1
  fi
else
  echo "❌ 本地文件不存在"
  echo "has_changes=false" >> "$GITHUB_OUTPUT"
  exit 1
fi

# 检查是否有变更
if [ -f plugin_cache_original.json ]; then
  if [ "$remote_exists" = "true" ]; then
    # 文件在远程存在，检查是否有内容变更
    git add plugin_cache_original.json  # 先添加到暂存区以便比较
    if git diff --cached --exit-code plugin_cache_original.json > /dev/null 2>&1; then
      echo "has_changes=false" >> "$GITHUB_OUTPUT"
      echo "ℹ️ 文件内容没有变化"
    else
      echo "has_changes=true" >> "$GITHUB_OUTPUT"
      echo "✅ 检测到文件内容变更"
      echo "变更详情:"
      git diff --cached plugin_cache_original.json
    fi
  else
    # 文件在远程不存在，这是新文件
    echo "has_changes=true" >> "$GITHUB_OUTPUT"
    echo "✅ 这是新文件，需要提交"
    # 预先添加到暂存区
    git add plugin_cache_original.json
  fi
else
  # 本地文件不存在
  echo "has_changes=false" >> "$GITHUB_OUTPUT"
  echo "❌ 本地文件不存在，跳过提交"
  exit 1
fi

# 输出 Git 状态以便调试
echo "Git 状态:"
git status


