{
  config,
  pkgs,
  sources,
  modulesPath,
  lib,
  ...
}:
{
  imports = [
    "${modulesPath}/profiles/perlless.nix"
    "${sources.snm}"
    ./hardware.nix
    "${sources.preservation}/module.nix"
    ./preservation.nix
    "${sources.disko}/module.nix"
    ./disko-config.nix
    ./valheim.nix
    ./vaultwarden.nix
  ];
  # steamcmd pulls perl
  system.forbiddenDependenciesRegexes = lib.mkForce [ ];

  includes = {
    managed-users.enable = true;
    mailserver.enable = true;
    monitoree.enable = true;
    postgresql.enable = true;
    server.enable = true;
    zfs.enable = true;
    zrepl.enable = true;
  };

  networking.firewall = {
    allowedUDPPorts = [ 443 ];
    allowedTCPPorts = [
      80
      443
    ];
  };

  systemd = {
    network = {
      enable = true;
      networks = {
        "20-wired" = {
          matchConfig.Name = "ens3";
          networkConfig = {
            Address = [
              "152.53.44.132/22"
              "2a0a:4cc0:0:23b0::/64"
            ];
            DNS = "8.8.8.8";
            Gateway = "152.53.44.1";
          };
          routes = [
            {
              Gateway = "fe80::1";
              GatewayOnLink = "yes";
            }
          ];
        };
      };
      wait-online.anyInterface = true;
    };
  };

  services = {
    fstrim.enable = true;
    postgresql = {
      package = pkgs.postgresql_16;
      dataDir = "/var/lib/postgresql/${config.services.postgresql.package.psqlSchema}";
      settings = {
        max_connections = 200;
        shared_buffers = "1GB";
        effective_cache_size = "3GB";
        maintenance_work_mem = "256MB";
        checkpoint_completion_target = 0.9;
        wal_buffers = "16MB";
        default_statistics_target = 100;
        random_page_cost = 4;
        effective_io_concurrency = 2;
        work_mem = "1310kB";
        huge_pages = "off";
        min_wal_size = "1GB";
        max_wal_size = "4GB";
        track_activities = true;
        track_counts = true;
        track_io_timing = true;
      };
    };
    nginx = {
      package = pkgs.nginx;
      additionalModules = with pkgs.nginxModules; [ geoip2 ];
      virtualHosts."pointjig.de" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          extraConfig = ''
            return 204;
          '';
        };
      };
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedTlsSettings = true;
      enableReload = true;
      clientMaxBodySize = "40M";
      mapHashMaxSize = 4096;
    };
  };
  mailserver = {
    fqdn = "mail.pointjig.de";
    accounts = {
      "shawn@pointjig.de".aliases = [
        "aktienfinder@pointjig.de"
        "alphavps@pointjig.de"
        "aquatuning@pointjig.de"
        "atlas@pointjig.de"
        "caseking@pointjig.de"
        "check24@pointjig.de"
        "circular@pointjig.de"
        "codeberg@pointjig.de"
        "dropbox@pointjig.de"
        "eatventure@pointjig.de"
        "epic@pointjig.de"
        "estateguru@pointjig.de"
        "flexispot@pointjig.de"
        "fritz@pointjig.de"
        "geizhals@pointjig.de"
        "intex@pointjig.de"
        "kinguin@pointjig.de"
        "lotto@pointjig.de"
        "megaprimus@pointjig.de"
        "milesandmore@pointjig.de"
        "mindfactory@pointjig.de"
        "nb@pointjig.de"
        "osaio@pointjig.de"
        "parqet@pointjig.de"
        "planetside@pointjig.de"
        "pool@pointjig.de"
        "reddit@pointjig.de"
        "smite@pointjig.de"
        "spocks@pointjig.de"
        "spotify@pointjig.de"
        "steam@pointjig.de"
        "stfc@pointjig.de"
        "stne@pointjig.de"
        "sto@pointjig.de"
        "supremegamers@pointjig.de"
        "unity@pointjig.de"
        "zsa@pointjig.de"
      ];
      "dorman@pointjig.de".aliases = [
        "ninjatrader@pointjig.de"
      ];
    };
  };
}
