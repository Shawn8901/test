{ config, ... }: {

  boot.initrd.systemd.services.initrd-rollback-root = {
    after = [ "zfs-import-rpool.service" ];
    requires = [ "zfs-import-rpool.service" ];
    before = [ "sysroot.mount" ];
    wantedBy = [ "initrd.target" ];
    description = "Rollback root fs";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${config.boot.zfs.package}/sbin/zfs rollback -r rpool/local/root@blank";
    };
  };

  security.sudo.extraConfig = ''
    Defaults lecture = never
  '';

  preservation = {
    enable = true;
    preserveAt."/persist" = {
      directories = [
        {
          directory = "/var/lib/systemd";
          inInitrd = true;
        }
        "/var/lib/acme"
        "/var/lib/alsa"
        "/var/lib/attic"
        "/var/lib/dovecot"
        "/var/lib/fail2ban"
        "/var/lib/hydra"
        "/var/lib/immich"
        "/var/lib/nextcloud"
        {
          directory = "/var/lib/nixos";
          inInitrd = true;
        }
        "/var/lib/openarchiver"
        "/var/lib/postfix"
        {
          directory = "/var/lib/private/";
          mode = "0700";
        }
        "/var/lib/prometheus2"
        "/var/lib/rspamd"
        "/var/lib/samba"
        "/var/lib/userborn"
        {
          directory = "/var/lib/vnstat";
          user = "vnstatd";
          group = "vnstatd";
        }
      ];
      files = [
        {
          file = "/etc/ssh/ssh_host_rsa_key";
          how = "symlink";
          inInitrd = true;
          configureParent = true;
        }
        {
          file = "/etc/ssh/ssh_host_ed25519_key";
          how = "symlink";
          inInitrd = true;
          configureParent = true;
        }
        {
          file = "/etc/machine-id";
          inInitrd = true;
        }
      ];
    };
  };
  systemd.suppressedSystemUnits = [ "systemd-machine-id-commit.service" ];
}
