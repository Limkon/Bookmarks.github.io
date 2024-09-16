#!/bin/bash

# 设置 GitHub 个人访问令牌和仓库信息
GITHUB_TOKEN="your_personal_access_token"
REPO="Limkon/bookmarks"  # 格式为 "owner/repo"

PAGE=1
PER_PAGE=100

while : ; do
  # 获取当前页的关闭 Issues
  ISSUES=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
    "https://api.github.com/repos/$REPO/issues?state=closed&per_page=$PER_PAGE&page=$PAGE" \
    | jq -r '.[].number')

  # 如果没有更多的 Issue，则退出循环
  if [ -z "$ISSUES" ]; then
    break
  fi

  # 批量删除每个关闭的 Issue
  for ISSUE in $ISSUES; do
    echo "Deleting Issue #$ISSUE"
    curl -s -X DELETE -H "Authorization: token $GITHUB_TOKEN" \
      "https://api.github.com/repos/$REPO/issues/$ISSUE"
  done

  PAGE=$((PAGE + 1))
done

echo "Finished deleting closed issues."
