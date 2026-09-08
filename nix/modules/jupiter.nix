{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.jupiter.client;

  # Ping LAN IP for up to attemptSeconds; on success connect with nc; else cloudflared Access SSH.
  proxyScript = pkgs.writeShellScript "jupiter-ssh-lan-or-cf" ''
    set -eu
    : "''${1:?}"
    : "''${2:?}"
    LAN_IP="${cfg.lanFirst.address}"
    CF_HOST="${cfg.cloudflareHostname}"
    WAIT=${toString cfg.lanFirst.attemptSeconds}
    PING="${pkgs.inetutils}/bin/ping"
    NC="${lib.getExe pkgs.netcat-gnu}"
    CF="${lib.getExe pkgs.cloudflared}"

    SECONDS=0
    while [ "$SECONDS" -lt "$WAIT" ]; do
      if "$PING" -c 1 -w 1 "$LAN_IP" >/dev/null 2>&1; then
        exec "$NC" "$LAN_IP" "$2"
      fi
      sleep 1
    done

    exec "$CF" access ssh --hostname "$CF_HOST"
  '';

  proxyCommand =
    if cfg.lanFirst.enable then
      "${proxyScript} %h %p"
    else
      "${lib.getExe pkgs.cloudflared} access ssh --hostname ${cfg.cloudflareHostname}";
in
{
  options.jupiter.client = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Install cloudflared and configure SSH for Jupiter (LAN-first or Cloudflare Access).
      '';
    };

    host = lib.mkOption {
      type = lib.types.str;
      default = "lab.ren.lk";
      description = "SSH Host entry name and Cloudflare Access hostname (for `cloudflared access ssh --hostname`).";
    };

    cloudflareHostname = lib.mkOption {
      type = lib.types.str;
      default = "lab.ren.lk";
      description = "Hostname passed to `cloudflared access ssh` when the LAN path is not used.";
    };

    lanFirst = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = ''
          If true, ping the LAN address for up to attemptSeconds; on success connect with plain TCP
          (nc) to that address. Otherwise use Cloudflare Access SSH only.
        '';
      };

      address = lib.mkOption {
        type = lib.types.str;
        default = "192.168.4.5";
        description = "LAN IP to ping and to connect to when reachable (before Cloudflare fallback).";
      };

      attemptSeconds = lib.mkOption {
        type = lib.types.int;
        default = 10;
        description = "How long to keep trying ping (once per second) before using Cloudflare.";
      };

      addHostForLanAddress = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = ''
          If true, emit a second Host block for lanFirst.address so `ssh user@192.168.4.5` uses the
          same ProxyCommand as host (lab.ren.lk).
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.cloudflared ];

    programs.ssh.matchBlocks =
      {
        ${cfg.host} = { inherit proxyCommand; };
      }
      // lib.optionalAttrs (cfg.lanFirst.enable && cfg.lanFirst.addHostForLanAddress) {
        ${cfg.lanFirst.address} = { inherit proxyCommand; };
      };
  };
}
