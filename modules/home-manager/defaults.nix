{
  sources,
  config,
  lib,
  ...
}:
{
  imports = [ "${sources.sops-nix}/modules/home-manager/sops.nix" ];

  sops = {
    age.keyFile = "${config.xdg.configHome}/sops/age/keys.txt";
    defaultSymlinkPath = "/run/user/${toString config.home.uid}/secrets";
    defaultSecretsMountPoint = "/run/user/${toString config.home.uid}/secrets.d";
  };
  home.stateVersion = "23.05";
  manual.manpages.enable = lib.mkDefault false;
  programs.man.enable = lib.mkDefault false;
}
