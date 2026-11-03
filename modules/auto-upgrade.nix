{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.custom-auto-upgrade;
in
{
  options.services.custom-auto-upgrade = {
    enable = lib.mkEnableOption "auto upgrade";

    url = lib.mkOption {
      type = lib.types.str;
      description = "URL of the git repo";
    };

    branch = lib.mkOption {
      type = lib.types.str;
      default = "main";
    };

    dates = lib.mkOption {
      type = lib.types.str;
      default = "04:00";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.custom-auto-upgrade = {
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      path = with pkgs; [
        coreutils
        gitMinimal
        hostname
        nh
        systemd
      ];
      script = ''
        set -euo pipefail
        echo "Starting Auto-Upgrade..."
        TMP_DIR=$(mktemp -d -t nixos-upgrade-XXXXXX)
        clean_up() {
          echo "Cleaning up temporary directory..."
          rm -rf "$TMP_DIR"
        }
        trap clean_up EXIT

        echo "Cloning repository from ${cfg.url} (Branch: ${cfg.branch})..."
        git clone --depth 1 -b "${cfg.branch}" "${cfg.url}" "$TMP_DIR"

        cd "$TMP_DIR"
        echo "Building configuration..."
        nh os build -f . $(hostname)

        echo "Checking if a reboot is required..."
        booted="$(readlink /run/booted-system/{initrd,kernel,kernel-modules})"
        built="$(readlink ./result/{initrd,kernel,kernel-modules})"

        if [ "''${booted}" = "''${built}" ]; then
          echo "No reboot required. Switching to the new configuration..."
          nh os switch -f . $(hostname)
        else
          echo "Reboot required. Switching to the new configuration and rebooting..."
          nh os boot -f . $(hostname)
          sleep 5
          reboot
        fi
      '';
    };

    # Timer, um den Service regelmäßig zu triggern
    systemd.timers.custom-auto-upgrade = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = cfg.dates;
        Persistent = true;
      };
    };
  };
}
