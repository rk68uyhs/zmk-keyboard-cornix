#!/bin/bash

# コンテナ起動
docker compose up -d

# Zephyrが正常にダウンロードされているかをチェック
docker compose exec zmk sh -c "if [ ! -f /zmk-workspace/zephyr/CMakeLists.txt ]; then \
  echo '=> ⚠️ キャッシュが空、または壊れているため初期化します...'; \
  echo '=> （※数分かかります。途中で絶対に止めないでください！）'; \
  rm -rf /zmk-workspace/* /zmk-workspace/.west; \
  mkdir -p /zmk-workspace/config; \
  cp /config-repo/config/west.yml /zmk-workspace/config/; \
  cd /zmk-workspace; \
  west init -l config; \
  west update; \
  west zephyr-export; \
else \
  echo '=> ✅ ZMKキャッシュ有効！ビルド準備を行います...'; \
  cd /zmk-workspace && west zephyr-export > /dev/null 2>&1; \
fi"

# 左手
echo "=> 左手 (Left) をビルド中..."
docker compose exec zmk sh -c "cd /zmk-workspace && west build -p always -s zmk/app -b cornix_left -- -DZMK_CONFIG=/config-repo/config -DBOARD_ROOT=/config-repo && cp build/zephyr/zmk.uf2 /config-repo/cornix_left.uf2"

# 右手
echo "=> 右手 (Right) をビルド中..."
docker compose exec zmk sh -c "cd /zmk-workspace && west build -p always -s zmk/app -b cornix_right -- -DZMK_CONFIG=/config-repo/config -DBOARD_ROOT=/config-repo && cp build/zephyr/zmk.uf2 /config-repo/cornix_right.uf2"

echo "✅ 完了！ uf2ファイルを出力しました"