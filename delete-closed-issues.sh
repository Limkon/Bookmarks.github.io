#!/bin/bash

# 设置 GitHub 个人访问令牌和仓库信息
GITHUB_TOKEN="${GITHUB_TOKEN}"
REPO_OWNER="Limkon"   # 仓库所有者
REPO_NAME="bookmarks" # 仓库名称

PAGE=1
PER_PAGE=100
AFTER_CURSOR=""

while : ; do
  # GraphQL 查询模板
  QUERY=$(cat <<EOF
  {
    repository(owner: "$REPO_OWNER", name: "$REPO_NAME") {
      issues(states: CLOSED, first: 100, after: "$AFTER_CURSOR") {
        edges {
          node {
            number
            id
          }
        }
        pageInfo {
          hasNextPage
          endCursor
        }
      }
    }
  }
EOF
)

  # 执行 GraphQL 查询以获取关闭的 Issues
  RESPONSE=$(curl -s -H "Authorization: Bearer $GITHUB_TOKEN" \
    -H "Content-Type: application/json" \
    -X POST -d "{\"query\": \"$QUERY\"}" \
    "https://api.github.com/graphql")

  # 检查 API 响应是否成功
  if [ -z "$RESPONSE" ]; then
    echo "Failed to retrieve issues. Empty response."
    exit 1
  fi

  # 解析 JSON 响应
  ISSUES=$(echo "$RESPONSE" | jq -r '.data.repository.issues.edges[].node.id')
  HAS_NEXT_PAGE=$(echo "$RESPONSE" | jq -r '.data.repository.issues.pageInfo.hasNextPage')
  AFTER_CURSOR=$(echo "$RESPONSE" | jq -r '.data.repository.issues.pageInfo.endCursor')

  # 如果没有更多的 Issue，则退出循环
  if [ -z "$ISSUES" ]; then
    echo "No more issues to delete."
    break
  fi

  # 批量删除每个关闭的 Issue
  for ISSUE_ID in $ISSUES; do
    echo "Deleting Issue with ID $ISSUE_ID"

    # GraphQL Mutation 模板
    MUTATION=$(cat <<EOF
    mutation {
      deleteIssue(input: {issueId: "$ISSUE_ID"}) {
        clientMutationId
      }
    }
EOF
)
    RESPONSE=$(curl -s -H "Authorization: Bearer $GITHUB_TOKEN" \
      -H "Content-Type: application/json" \
      -X POST -d "{\"query\": \"$MUTATION\"}" \
      "https://api.github.com/graphql")

    if [ "$RESPONSE" == "{}" ]; then
      echo "Successfully deleted Issue with ID $ISSUE_ID"
    else
      echo "Failed to delete Issue with ID $ISSUE_ID. Response: $RESPONSE"
    fi
  done

  # 如果还有更多的 Issue，则继续获取
  if [ "$HAS_NEXT_PAGE" == "false" ]; then
    break
  fi
done

echo "Finished deleting closed issues."
