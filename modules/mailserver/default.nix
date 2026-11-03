{
  options,
  config,
  lib,
  ...
}:
let
  cfg = config.includes.mailserver;
in
{
  options.includes.mailserver = {
    enable = lib.mkEnableOption "Enables mailserver";
    fqdn = lib.mkOption {
      type = lib.types.str;
      default = config.mailserver.fqdn;
      description = "The fully qualified domain name of the mailserver.";
    };
    domain = lib.mkOption {
      type = lib.types.str;
      default = config.mailserver.fqdn;
      description = "The fully qualified domain name of the mailserver.";
    };
  };

  config = lib.optionalAttrs (options ? mailserver) {
    sops.secrets = {
      snm-shawn.sopsFile = ./secrets.yaml;
      snm-dorman.sopsFile = ./secrets.yaml;
    };
    services.nginx = {
      enable = true;
      virtualHosts.${cfg.fqdn}.enableACME = true;
    };
    mailserver = {
      enable = true;
      stateVersion = 4;
      domains = [ cfg.domain ];
      x509.useACMEHost = cfg.fqdn;
      accounts = {
        "shawn@pointjig.de".hashedPasswordFile = config.sops.secrets.snm-shawn.path;
        "dorman@pointjig.de".hashedPasswordFile = config.sops.secrets.snm-dorman.path;
      };
    };
  };
}
