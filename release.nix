let
  sources = import ./lon.nix;
  systems = import ./system.nix;
  lib = import "${sources.nixpkgs}/lib";
in
lib.mapAttrs (name: attr: attr.config.system.build.toplevel) systems
