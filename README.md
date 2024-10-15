# Rustlang Project

## Set the username

Use the user name you're using for the host: `USER_NAME=k33g` (to keep your git credentials)

```yaml
services:

  devcontainer:
    build:
      context: .
      dockerfile: rust.Dockerfile
      args:
        - RUST_VERSION=1.74.0
        - USER_NAME=k33g
    volumes:
      - ../..:/workspaces:cached      
    environment:
      - MESSAGE="Hello World!"
    command: sleep infinity
```

> Check:
```bash
git config --list
```
