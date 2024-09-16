#!/bin/zsh

## 初回にこれを実行→ chmod +x ./docker_run.sh

# デフォルトのコンテナ名、イメージ名、マウントディレクトリを設定
DEFAULT_CONTAINER_NAME="ai-scientist-container"
DEFAULT_IMAGE_NAME="ai-scientist-image"
DEFAULT_MOUNT_DIR="/mnt/e/docker/ai-scientist/"

# メッセージをカスタマイズ
MSG_CONTAINER_NAME="コンテナ名を入力してください（デフォルト: ${DEFAULT_CONTAINER_NAME}）: "
MSG_IMAGE_NAME="Dockerイメージ名を入力してください（デフォルト: ${DEFAULT_IMAGE_NAME}）: "
MSG_MOUNT_DIR="マウントするホストのディレクトリを入力してください（デフォルト: ${DEFAULT_MOUNT_DIR}）: "

# コンテナ名を入力
echo "${MSG_CONTAINER_NAME}"
read CONTAINER_NAME
CONTAINER_NAME=${CONTAINER_NAME:-$DEFAULT_CONTAINER_NAME}

# Dockerイメージを入力
echo "${MSG_IMAGE_NAME}"
read IMAGE_NAME
IMAGE_NAME=${IMAGE_NAME:-$DEFAULT_IMAGE_NAME}

# マウントするホストディレクトリを入力
echo "${MSG_MOUNT_DIR}"
read MOUNT_DIR
MOUNT_DIR=${MOUNT_DIR:-$DEFAULT_MOUNT_DIR}

# コンテナが既に存在するか確認
if [ "$(docker ps -a -q -f name=${CONTAINER_NAME})" ]; then
    echo "既存のコンテナが見つかりました。コンテナを再起動します...."

    # コンテナが停止している場合、再起動
    if [ "$(docker ps -q -f name=${CONTAINER_NAME})" ]; then
        echo "コンテナはすでに起動中です。アタッチします....\n ---------- Logs ----------"
    else
        echo "コンテナを起動中です...\n ---------- Logs ----------"
        docker start ${CONTAINER_NAME}
    fi
else
    # コンテナが存在しない場合、新規作成し、デタッチモードで起動
    echo "新しいコンテナを作成してデタッチモードで起動します..."

    # .envファイルが存在するか確認し、対応するコマンドを実行
    if [ -f .env ]; then
        echo ".envファイルが見つかりました。環境変数を読み込んでコンテナを起動します....\n ---------- Logs ----------"
        docker run --gpus all -d --env-file .env -v ${MOUNT_DIR}:/workspace --name ${CONTAINER_NAME} -it ${IMAGE_NAME} /bin/bash
    else
        echo ".envファイルが見つかりません。通常のコンテナを起動します...\n ---------- Logs ----------"
        docker run --gpus all -d -v ${MOUNT_DIR}:/workspace --name ${CONTAINER_NAME} -it ${IMAGE_NAME} /bin/bash
    fi
fi

# コンテナの実行状態を監視し、終了するまで待機
echo "Dockerコンテナはデタッチモードで実行中です。"
echo "コンテナ内に入りたい場合、以下のコマンドを使用してください:"
echo "  docker exec -it ${CONTAINER_NAME} /bin/bash"
echo
echo "コンテナをデタッチするには、Ctrl + P -> Ctrl + Q を押してください。"
echo "終了するには Ctrl + C を押してください。"

# SIGINT（Ctrl + C）をキャッチして、コンテナを停止
trap "echo 'コンテナを停止しています...'; docker stop ${CONTAINER_NAME}; handle_container_removal; exit" SIGINT

# コンテナ削除処理
handle_container_removal() {
    echo -n "コンテナを削除しますか？ (y/n): "
    read answer
    if [[ $answer = "y" || $answer = "Y" ]]; then
        echo "コンテナを削除しています..."
        docker rm ${CONTAINER_NAME}
    else
        echo "コンテナは削除されませんでした。使わない場合は手動で削除してください。"
    fi
}

# 無限ループで待機（Ctrl + C を受け取るまで）
while true; do
  sleep 1
done
