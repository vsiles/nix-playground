```bash
$ direnv allow
$ nix flake check
$ nix build .#dockerImage
$ file result
result: symbolic link to /nix/store/nh9ix7djajdlwqdpp8n755k3knnqh702-docker-image-app_a.tar.gz
```
