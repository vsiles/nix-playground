{ ... }: {
  imports = [
    ./14-rust-docker-build-all-publish/manifest.nix
    ./14-rust-docker-build-all-publish/rust.nix
    ./14-rust-docker-build-all-publish/docker.nix
    ./14-rust-docker-build-all-publish/all.nix
    ./14-rust-docker-build-all-publish/publish.nix
  ];
}
