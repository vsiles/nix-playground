{
  description = "some flake";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { nixpkgs, ... } :
  let f = import ./stuff.nix; in
  {
    # will trigger a warning but we don't care
    my-result = f {msg = "hello"; x= 10; y= 1;};
  };
}
