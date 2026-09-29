{
  system ? builtins.currentSystem,
}:
let
  sources = import ../lon.nix;
  systems = import ../system.nix;
  lib = import "${sources.nixpkgs}/lib";
in
{
  nixos = lib.mapAttrs (name: attr: attr.config.system.build.toplevel) systems;
}
