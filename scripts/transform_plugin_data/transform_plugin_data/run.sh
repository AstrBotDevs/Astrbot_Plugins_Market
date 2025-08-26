#!/usr/bin/env bash

echo "开始转换插件数据格式..."

# 使用jq转换数据格式，增加容错处理，并过滤掉404的仓库
jq --slurpfile repo_info repo_info.json '
to_entries | 
# 只过滤掉确认已删除(404)的仓库，保留网络错误的仓库
map(select(
  if .value.repo and ($repo_info[0][.value.repo]) then
    ($repo_info[0][.value.repo].status != "deleted")
  else
    true
  end
)) |
map({
  key: .key,
  value: (
    .value + {
      # 保持原有字段
      desc: .value.desc,
      author: .value.author,
      repo: .value.repo,
      tags: (.value.tags // [])
    } +
    # 仅当social_link存在且不为空时添加
    (if .value.social_link then { social_link: .value.social_link } else {} end) + 
    # 添加新字段，从repo_info中获取
    (if .value.repo and ($repo_info[0][.value.repo]) then
      ($repo_info[0][.value.repo] | {
        stars: .stars,
        updated_at: .updated_at,
        version: (if .version != "" then .version else "1.0.0" end)
      })
    else
      {
        stars: 0,
        version: "1.0.0"
      }
    end)
  )
}) | from_entries' original_plugins.json > temp_plugin_cache_original.json

# 格式化JSON使其更易读
jq . temp_plugin_cache_original.json > plugin_cache_original.json

echo "✅ 数据转换完成"

# 显示转换统计
original_count=$(jq 'keys | length' original_plugins.json)
new_count=$(jq 'keys | length' plugin_cache_original.json)
removed_count=$((original_count - new_count))

# 统计不同状态的仓库
success_repos=$(jq '[.[] | select(.status == "success")] | length' repo_info.json)
cached_repos=$(jq '[.[] | select(.status == "cached")] | length' repo_info.json)
redirected_repos=$(jq '[.[] | select(.status == "redirected")] | length' repo_info.json)
deleted_repos=$(jq '[.[] | select(.status == "deleted")] | length' repo_info.json)
failed_repos=$(jq '[.[] | select(.status != "success" and .status != "cached" and .status != "redirected" and .status != "deleted")] | length' repo_info.json)

echo ""
echo "📊 转换统计:"
echo "  插件数量变化: $original_count -> $new_count"
if [ $removed_count -gt 0 ]; then
  echo "  🗑️  已移除: $removed_count 个失效插件"
fi
echo "  ✅ 实时数据: $success_repos 个仓库"
echo "  🔄 缓存数据: $cached_repos 个仓库"
echo "  🔄 重定向: $redirected_repos 个仓库"
echo "  🗑️  已删除(已移除): $deleted_repos 个仓库"
echo "  ❌ 网络错误(已保留): $failed_repos 个仓库"

# 列出被移除的仓库
if [ $removed_count -gt 0 ]; then
  echo ""
  echo "🗑️  以下仓库已从缓存中移除:"
  jq -r 'to_entries[] | select(.value.status == "deleted") | "  - " + .key + " (404 Not Found)"' repo_info.json
fi

# 列出网络错误的仓库（保留但使用缓存数据）
if [ "$failed_repos" -gt 0 ]; then
  echo ""
  echo "❌ 网络错误的仓库（已保留，使用缓存数据）:"
  jq -r 'to_entries[] | select(.value.status != "success" and .value.status != "cached" and .value.status != "redirected" and .value.status != "deleted") | "  - " + .key + " (" + .value.status + ")"' repo_info.json
fi

# 列出重定向的仓库（保留但标记）
if [ "$redirected_repos" -gt 0 ]; then
  echo ""
  echo "🔄 发生重定向的仓库列表（已保留）:"
  jq -r 'to_entries[] | select(.value.status == "redirected") | "  - " + .key' repo_info.json
fi


