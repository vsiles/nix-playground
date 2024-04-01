{ ... }: {
  imports = [
    ./14-rust-docker-build-publish/manifest.nix
    ./14-rust-docker-build-publish/rust.nix
    ./14-rust-docker-build-publish/docker.nix
    ./14-rust-docker-build-publish/all.nix
    ./14-rust-docker-build-publish/publish.nix
  ];
}
