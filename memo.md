### boundary database init を 2 回以上行ったときのエラー

v0.1.4 では `Database already initialized.` と標準出力されるだけでエラーにはならなかった。

v0.1.7 では `Unable to capture a lock on the database.` と言われ return code 1 が返される。
エラー扱いになるのはともかくエラーメッセージは変じゃないか?

init コマンドで実行されるのは `internal/cmd/commands/database/init.go` の処理のはず。
内部的には init 特有の処理は前後にありそうだけど DB セットアップとしては migrate と同じ処理をしている。

エラー自体は controller が動いているからでそれを止めれば実行できた。

ただやはり v0.1.7 では一度 init していると `Database has already been initialized.  Please use 'boundary database migrate'.` と言われて return code 1 が返されるので playbook 的には初回でしか実行されないようにしたいところ。

パッケージの update には対応しない前提で、パッケージインストール時のみ initialization が走るようにした。

### API の TLS 化

`ssl` ディレクトリ下に証明書と秘密鍵を置いて以下のように Make タスクを実行する。

```
# for initial installation
$ make install-tls
```

単に動作確認をしたいだけなら上のコマンド実行前に `make cert` で `boundary.example.com` 向けの証明書を作成して使用できる。

またここで Ansible の `no_log` について微妙な挙動を見つけたのでそれを反映した修正を Boundary role に加えた。

ref. https://gist.github.com/tiqwab/0a1ffd9775ac8b712590f2fdd4e74dbf

```
# 変更前は 変数が未定義の場合の対応ができていない
-  no_log: "{{ True if boundary_api_tls_key_content else False }}"
+  no_log: "{{ True if boundary_api_tls_key_content | default(None) else False }}"
```
