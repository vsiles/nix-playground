# IMPORTANT

`Cargo.lock` must be in git for build/check to happen so when creating a rust
project from scratch, you'll have to run a first `cargo build/check` command
by hand to generate such a file.

This can be done with `nix run nixpkgs#cargo -- check` if the devShell is not
setup yet and cargo is not yet available.

# LOGS

```bash
$ direnv allow
$ nix flake check # will error because of the warning on the config in flake.nix
$ # we can use check to fail the CI quickly now ;)
$ nix build && tree result # will build everything even if check failed
$ # meaning we can build even if there are local warning, no blocking the user
$ nix run .#app_b 
```
