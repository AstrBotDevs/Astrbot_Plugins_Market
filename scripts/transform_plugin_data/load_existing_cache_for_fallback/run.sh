#!/usr/bin/env bash
set -e

echo "检查现有缓存文件..."
if [ -f plugin_cache_original.json ]; then
  echo "发现现有缓存文件，将用作回退数据"
  cp plugin_cache_original.json existing_cache.json
  echo "has_existing_cache=true" >> "$GITHUB_OUTPUT"
else
  echo "没有现有缓存文件"
  echo "has_existing_cache=false" >> "$GITHUB_OUTPUT"
fi


