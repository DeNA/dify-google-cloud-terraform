# ベースイメージとしてDocker Hubからイメージをプル
FROM langgenius/dify-api:0.6.15

# カスタムのentrypoint.shを追加
COPY entrypoint.sh /entrypoint.sh

# エントリーポイントスクリプトに実行権限を付与
RUN chmod +x /entrypoint.sh

# 新しいエントリーポイントを設定
ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]