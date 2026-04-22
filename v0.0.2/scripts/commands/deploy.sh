#!/bin/bash
set -e

# Generic deploy command template
# Usage: ./scripts/commands/deploy.sh [frontend|backend|all]

TARGET=${1:-all}
REGION="<region>"
PROJECT="<project-id>"

echo "🚀 デプロイプロセスを開始します。ターゲット: $TARGET"

deploy_backend() {
  echo "📦 バックエンド(API)のデプロイを実行中..."
  gcloud run deploy <backend-service> \
    --source <backend-source-dir> \
    --region $REGION \
    --project $PROJECT \
    --set-cloudsql-instances $PROJECT:$REGION:<db-instance> \
    --env-vars-file <backend-env-file>
  echo "✅ バックエンドのデプロイが完了しました。（マイグレーションも自動実行されています）"
}

deploy_frontend() {
  echo "📦 フロントエンドのデプロイを実行中..."
  
  # Google Cloud Build (Kaniko) の強力なキャッシュによって古いViteビルド結果が使い回されるのを防ぐため
  # 毎回必ずソースコードのハッシュを変えて完全新規ビルドを強制する
  date > <frontend-cachebust-file>

  gcloud run deploy <frontend-service> \
    --source <frontend-source-dir> \
    --region $REGION \
    --project $PROJECT
  echo "✅ フロントエンドのデプロイが完了しました。"
}

if [ "$TARGET" = "backend" ]; then
  deploy_backend
elif [ "$TARGET" = "frontend" ]; then
  deploy_frontend
elif [ "$TARGET" = "all" ]; then
  deploy_backend
  deploy_frontend
else
  echo "エラー: 無効なターゲットです。[frontend | backend | all] のいずれかを指定してください。"
  exit 1
fi

echo "🎉 全てのデプロイ処理が完了しました！"
