{
  lib,
  config,
  sources,
  ...
}:
{
  options.includes.desktop.browser.enable = lib.mkEnableOption "Enables desktop browser";

  config = lib.mkIf (config.includes.desktop.browser.enable) {

    nixpkgs = {
      config.allowUnfreePackages = [
        "tampermonkey"
        "betterttv"
        "video-downloadhelper"
      ];

      overlays = [
        (final: prev: {
          firefox-addons = final.callPackage (import "${sources.rycee}/pkgs/firefox-addons") {
            buildMozillaXpiAddon =
              let
                libMozilla = import "${sources.rycee}/lib/mozilla.nix" { inherit (prev) lib; };
              in
              libMozilla.mkBuildMozillaXpiAddon { inherit (final) fetchurl stdenv; };
          };
        })

      ];
    };
    environment.sessionVariables.MOZ_ENABLE_WAYLAND = "1";
  };
}
