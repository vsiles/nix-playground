```bash
$ direnv allow
$ nix flake check # will error because of the warning on the config in flake.nix
$ # we can use check to fail the CI quickly now ;)
$ nix build && tree result # will build everything even if check failed
$ # meaning we can build even if there are local warning, no blocking the user
$ nix run .#app_b 
```
