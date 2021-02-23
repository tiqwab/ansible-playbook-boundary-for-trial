### 1. ansible-role-boundary のインストール

```
$ ansible-galaxy install bbaassssiiee.ansible_role_boundary -p roles
```

### 2. Run Ansible

```
$ make run
```

いまのところ `boundary_db_init_flags` の `-skip-initial-login-role-creation` 指定を外して、初期 Boundary リソースが自動で生成するようにしている。その場合、初期 admin ユーザのパスワードは Ansible の `initializing database for boundary` タスク実行結果から確認しなければならない。例えば Ansible 実行時に `-vvv` オプションを入れて verbose なメッセージ出力を有効にすればその内容から確認できる。

```
changed: [boundary1] => {
    "changed": true,
    "cmd": [
        "/usr/bin/boundary",
        "database",
        "init",
        "-config",
        "/etc/boundary.d/controller.hcl"
    ],

    ...

    "stdout_lines": [
        "Migrations successfully run.",
        "Global-scope KMS keys successfully created.",
        "",
        "Initial login role information:",
        "  Name:      Login and Default Grants",
        "  Role ID:   r_48NxPX7rcN",
        "",
        "Initial auth information:",
        "  Auth Method ID:     ampw_veqo6W8sl0",
        "  Auth Method Name:   Generated global scope initial auth method",
        "  Login Name:         admin",
        "  Password:           67mlOXxONdzCEsmmH7wu",
        "  Scope ID:           global",
        "  User ID:            u_jGtLEM5Zs3",
        "  User Name:          admin",
        "",
        "Initial org scope information:",
        "  Name:       Generated org scope",
        "  Scope ID:   o_31vvIB6CfS",
        "  Type:       org",
        "",
        "Initial project scope information:",
        "  Name:       Generated project scope",
        "  Scope ID:   p_bfXO5GpjTy",
        "  Type:       project",
        "",
        "Initial host resources information:",
        "  Host Catalog ID:     hcst_vMQntuVOT6",
        "  Host Catalog Name:   Generated host catalog",
        "  Host ID:             hst_ySGfAJPyyZ",
        "  Host Name:           Generated host",
        "  Host Set ID:         hsst_LX5ZEyK4nS",
        "  Host Set Name:       Generated host set",
        "  Scope ID:            p_bfXO5GpjTy",
        "  Type:                static",
        "",
        "Initial target information:",
        "  Default Port:               22",
        "  Name:                       Generated target",
        "  Scope ID:                   p_bfXO5GpjTy",
        "  Session Connection Limit:   -1",
        "  Session Max Seconds:        28800",
        "  Target ID:                  ttcp_kSmdOGzUdr",
        "  Type:                       tcp"
    ]
```

構築が完了すれば `http://localhost:10200` にアクセスしてログイン画面が表示されるはず。

### boundary database init を 2 回以上行ったときのエラー

v0.1.4 では `Database already initialized.` と標準出力されるだけでエラーにはならなかった。

v0.1.7 では `Unable to capture a lock on the database.` と言われ return code 1 が返される。
エラー扱いになるのはともかくエラーメッセージは変じゃないか?

init コマンドで実行されるのは `internal/cmd/commands/database/init.go` の処理のはず。
内部的には init 特有の処理は前後にありそうだけど DB セットアップとしては migrate と同じ処理をしている。

エラー自体は controller が動いているからでそれを止めれば実行できた。

ただやはり v0.1.7 では一度 init していると `Database has already been initialized.  Please use 'boundary database migrate'.` と言われて return code 1 が返されるので playbook 的には初回でしか実行されないようにしたいところ。

boundary の install に hook した handler を用意してそこでやるのがいいかなと。その場合初回インストールのみ init しないといけないが、その判定はまあ boundary が既にあるかないかを事前に見ておくとか?

判定がちょっと面倒なので Make の task を初回 install と以降の update でわけて tags で制御することにした。
現在は update の前には `systemctl stop boundary-controller` を手動でかけておく必要がある。

ただ update はプラットフォーム依存の部分とか詰めきれないのでいっそ無しにしてしまう方がいいかもしれない。

### API の TLS 化

`ssl` ディレクトリ下に証明書と秘密鍵を置いて以下のように Make タスクを実行する。

```
# for initial installation
$ make install-tls
# for update
$ make update-tls
```

単に動作確認をしたいだけなら上のコマンド実行前に `make cert` で `boundary.example.com` 向けの証明書を作成して使用できる。

またここで Ansible の `no_log` について微妙な挙動を見つけたのでそれを反映した修正を Boundary role に加えた。

ref. https://gist.github.com/tiqwab/0a1ffd9775ac8b712590f2fdd4e74dbf

```
# 変更前は 変数が未定義の場合の対応ができていない
-  no_log: "{{ True if boundary_api_tls_key_content else False }}"
+  no_log: "{{ True if boundary_api_tls_key_content | default(None) else False }}"
```
