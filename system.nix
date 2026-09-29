let
  sources = import ./lon.nix;
  nixosSystem = import "${sources.nixpkgs}/nixos/lib/eval-config.nix";
  lib = import "${sources.nixpkgs}/lib";
  mkSystem =
    hostname:
    lib.attrsets.genAttrs [ hostname ] (
      hostname:
      nixosSystem {
        specialArgs = { inherit sources; };
        modules = [
          { networking.hostName = hostname; }
          ./modules/nixos
          ./hosts/pointalpha/configuration.nix
        ];
      }
    );
in
lib.mergeAttrsList [
  (mkSystem "pointalpha")
]
