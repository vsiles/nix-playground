{
  description = "some flake";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { nixpkgs, ... } :
  let f = import ./stuff.nix; in
  {
    my-result = f {msg = "hello"; x= 10; y= 1;};
  };
}
