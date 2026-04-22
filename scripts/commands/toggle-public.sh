#!/bin/bash
set -e

# Generic public/private toggle command template
# Usage: ./scripts/commands/toggle-public.sh [public|private]

ACTION=$1
REGION="<region>"
PROJECT="<project-id>"

if [ -z "$ACTION" ]; then
  echo "エラー: 引数が必要です。使用方法: ./scripts/commands/toggle-public.sh [public|private]"
  exit 1
fi

if [ "$ACTION" != "public" ] && [ "$ACTION" != "private" ]; then
  echo "エラー: 引数は 'public' または 'private' を指定してください。"
  exit 1
fi

echo "🔒 Cloud Run のアクセス権限を変更します... 対象状態: $ACTION"

toggle_service() {
  local service_name=$1
  if [ "$ACTION" = "public" ]; then
    echo "🌍 $service_name を一般公開(allUsers)に設定中..."
    gcloud run services add-iam-policy-binding $service_name \
      --region=$REGION \
      --project=$PROJECT \
      --member="allUsers" \
      --role="roles/run.invoker" \
      --quiet
    echo "🔓 $service_name を一般公開しました。"
  else
    echo "🛡️ $service_name を非公開(allUsers削除)に設定中..."
    gcloud run services remove-iam-policy-binding $service_name \
      --region=$REGION \
      --project=$PROJECT \
      --member="allUsers" \
      --role="roles/run.invoker" \
      --quiet
    echo "🔒 $service_name を非公開にしました。"
  fi
}

toggle_service "<frontend-service>"
toggle_service "<backend-service>"

echo "🎉 アクセス権限の変更が完了しました！"
