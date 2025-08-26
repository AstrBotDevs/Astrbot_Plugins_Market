#!/usr/bin/env bash

echo "开始获取原始插件数据..."
echo "当前工作目录: $(pwd)"
echo "PAT_TOKEN 权限检查..."
if [ -n "$PAT_TOKEN" ]; then
  echo "✓ PAT_TOKEN 已设置"
else
  echo "✗ PAT_TOKEN 未设置"
fi

# 创建临时文件存储响应和HTTP状态码
temp_response="temp_response.txt"
temp_headers="temp_headers.txt"

# 获取GitHub原始文件内容
github_url="https://raw.githubusercontent.com/AstrBotDevs/AstrBot_Plugins_Collection/main/plugins.json"

# 使用curl获取数据，添加-L参数自动跟随重定向，增加重定向限制
http_code=$(curl -L -s --max-time 30 --retry 3 --retry-delay 5 \
  --max-redirs 10 \
  -H "Authorization: token $PAT_TOKEN" \
  -H "User-Agent: GitHub-Action-Plugin-Transformer" \
  -H "Accept: application/json" \
  -w "%{http_code}" \
  -D "$temp_headers" \
  -o "$temp_response" \
  "$github_url")

curl_exit_code=$?

# 检查curl命令是否执行成功
if [ $curl_exit_code -ne 0 ]; then
  echo "❌ 网络请求失败，curl退出码: $curl_exit_code"
  case $curl_exit_code in
    5) echo "无法解析代理" ;;
    6) echo "无法解析主机名" ;;
    7) echo "无法连接到服务器" ;;
    28) echo "请求超时" ;;
    35) echo "SSL连接错误" ;;
    47) echo "重定向次数过多" ;;
    *) echo "其他网络错误" ;;
  esac
  echo "should_update=false" >> "$GITHUB_OUTPUT"
  rm -f "$temp_response" "$temp_headers"
  exit 0
fi

echo "HTTP状态码: $http_code"

# 检查是否发生了重定向
if [ -f "$temp_headers" ]; then
  redirect_count=$(grep -c "^HTTP/" "$temp_headers" || echo "1")
  if [ "$redirect_count" -gt 1 ]; then
    echo "ℹ️ 检测到重定向，共发生 $((redirect_count - 1)) 次重定向"
    echo "重定向详情:"
    grep -E "^(HTTP/|Location:)" "$temp_headers" | head -10
  fi
fi

# 检查HTTP状态码
if [ "$http_code" -ne 200 ]; then
  echo "❌ 最终返回非200状态码: $http_code"
  case $http_code in
    301) echo "永久重定向 (301 Moved Permanently) - 可能需要更新URL" ;;
    302) echo "临时重定向 (302 Found)" ;;
    404) echo "文件不存在或仓库不可访问 (404 Not Found)" ;;
    403) echo "访问被拒绝，可能是API限制 (403 Forbidden)" ;;
    500) echo "GitHub服务器内部错误 (500 Internal Server Error)" ;;
    *) echo "HTTP错误状态码: $http_code" ;;
  esac
  echo "should_update=false" >> "$GITHUB_OUTPUT"
  rm -f "$temp_response" "$temp_headers"
  exit 0
fi

# 读取响应内容
if [ ! -f "$temp_response" ]; then
  echo "❌ 响应文件不存在"
  echo "should_update=false" >> "$GITHUB_OUTPUT"
  exit 0
fi

response=$(cat "$temp_response")

# 检查响应是否为空
if [ -z "$response" ] || [ "$response" = "" ]; then
  echo "❌ 获取到的响应为空，跳过更新"
  echo "should_update=false" >> "$GITHUB_OUTPUT"
  rm -f "$temp_response" "$temp_headers"
  exit 0
fi

# 检查响应大小
response_size=$(wc -c < "$temp_response")
if [ "$response_size" -lt 50 ]; then
  echo "❌ 响应内容过小 ($response_size 字节)，可能是错误响应"
  echo "should_update=false" >> "$GITHUB_OUTPUT"
  rm -f "$temp_response" "$temp_headers"
  exit 0
fi

# 检查是否为有效的JSON
if ! echo "$response" | jq . > /dev/null 2>&1; then
  echo "❌ 响应不是有效的JSON格式，跳过更新"
  echo "Content preview: $(echo "$response" | head -c 200)"
  echo "should_update=false" >> "$GITHUB_OUTPUT"
  rm -f "$temp_response" "$temp_headers"
  exit 0
fi

# 检查JSON是否为空对象或空数组
if [ "$response" = "{}" ] || [ "$response" = "[]" ] || [ "$response" = "null" ]; then
  echo "❌ 获取到空的JSON数据，跳过更新"
  echo "should_update=false" >> "$GITHUB_OUTPUT"
  rm -f "$temp_response" "$temp_headers"
  exit 0
fi

# 保存原始数据到临时文件
echo "$response" > original_plugins.json
echo "should_update=true" >> "$GITHUB_OUTPUT"
echo "✅ 成功获取原始插件数据 ($response_size 字节)"

# 清理临时文件
rm -f "$temp_response" "$temp_headers"


