#!/usr/bin/env bash

if [ "$SHOULD_UPDATE" = "true" ]; then
  if [ "$HAS_CHANGES" = "true" ]; then
    echo "✅ 插件数据已成功转换并提交"

    # 显示详细统计
    if [ -f plugin_cache_original.json ]; then
      total_plugins=$(jq 'keys | length' plugin_cache_original.json)
      echo "📊 最终结果: $total_plugins 个插件已更新"
    fi
  else
    echo "ℹ️ 数据获取和转换成功，但内容未发生变化"
  fi
else
  echo "❌ 由于网络问题、GitHub服务错误或数据异常，跳过了数据转换"
  echo "请检查GitHub服务状态或查看上面的错误详情"
fi


