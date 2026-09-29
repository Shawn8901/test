{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.includes.desktop.coding.enable = lib.mkEnableOption "Enables desktop coding";

  config = lib.mkIf (config.includes.desktop.coding.enable) {

    nixpkgs.config.allowUnfreePackages = [
      "vscode"
      "vscode-extension-mhutchie-git-graph"
      "vscode-extension-MS-python-vscode-pylance"
      "vscode-extension-bmewburn-vscode-intelephense-client"
    ];

    programs = {
      ssh.startAgent = true;
    };
    services.mysql = {
      enable = true;
      package = pkgs.mariadb;
      ensureDatabases = [ "db" ];
      ensureUsers = [
        {
          name = "shawn";
          ensurePermissions = {
            "db.*" = "ALL PRIVILEGES";
          };
        }
      ];
    };
  };
}
