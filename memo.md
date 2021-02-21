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
