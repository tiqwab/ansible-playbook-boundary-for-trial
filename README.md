### Usage

```
$ git clone https://github.com/tiqwab/ansible-playbook-boundary-for-trial.git --recursive

$ vagrant up

$ make install
```

You can try Hashicorp Boundary by opening login page at http://localhost:10200.
The login account is shown in the last boundary task.

```
...
    "stdout_lines": [
    ...
        "Initial auth information:",
        "  Auth Method ID:     ampw_veqo6W8sl0",
        "  Auth Method Name:   Generated global scope initial auth method",
        "  Login Name:         admin",
        "  Password:           67mlOXxONdzCEsmmH7wu",
        "  Scope ID:           global",
        "  User ID:            u_jGtLEM5Zs3",
        "  User Name:          admin",
        "",
    ...
```
