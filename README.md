# Flutter for web 環境構築
Flutterのweb版での環境構築です。

## HowTo
1. リポジトリをクローン
    ```
    git clone https://github.com/toshi-click/flutter_test
    ```
1. クローンしたディレクトリで
    ```
    cd flutter_test
    docker-compose build
    ```
1. コンテナを構築、起動
    ```
    docker-compose up -d
    ```
1. 起動したコンテナに入る
    ```
    docker exec -it flutter bash
    ```
