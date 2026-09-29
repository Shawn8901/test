{
  nixpkgs ? <nixpkgs>,
}:
let
  release = import "${nixpkgs}/nixos/release.nix" { };
in
{
  inherit (release) channel;
}
