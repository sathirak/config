{
  lib,
  pkgs,
  ...
}:

# Grafana + Prometheus launchd daemons are disabled. Flip `enabled` to true to bring them back.
let
  prometheusConfig = pkgs.writeText "prometheus.yml" ''
    global:
      scrape_interval: 15s

    scrape_configs:
      - job_name: 'node_exporter'
        static_configs:
          - targets: ['localhost:9000']
      - job_name: 'voyager3'
        static_configs:
          - targets: ['localhost:9464']
        metrics_path: /metrics
        scrape_interval: 1s

    otlp:
      promote_resource_attributes:
        - service.name
        - service.instance.id
  '';

  grafanaConfig = pkgs.writeText "grafana.ini" ''
    [server]
    http_port = 3000
    http_addr = 127.0.0.1

    [paths]
    data = /var/lib/grafana/data
    logs = /var/lib/grafana/logs
    plugins = /var/lib/grafana/plugins
    provisioning = /var/lib/grafana/provisioning

    [security]
    admin_user = admin
    admin_password = admin
  '';

  grafanaDatasources = pkgs.writeText "datasources.yaml" ''
    apiVersion: 1
    datasources:
      - name: Prometheus
        type: prometheus
        access: proxy
        url: http://127.0.0.1:9090
        isDefault: true
        jsonData:
          timeInterval: "1s"
  '';

  enabled = false;
in
{
  # Match existing _prometheus-node-exporter user home (nix-darwin forbids changing it)
  users.users._prometheus-node-exporter.home = lib.mkForce "/private/var/lib/prometheus-node-exporter";

  services.prometheus.exporters.node = {
    enable = false;
    port = 9000;
    enabledCollectors = [
      "cpu"
      "meminfo"
      "netdev"
    ];
  };

  launchd.daemons = lib.mkIf enabled {
    prometheus = {
      command = "${pkgs.prometheus}/bin/prometheus --config.file=${prometheusConfig} --storage.tsdb.path=/var/lib/prometheus --web.enable-otlp-receiver";
      serviceConfig = {
        KeepAlive = true;
        RunAtLoad = true;
        StandardOutPath = "/var/log/prometheus.out.log";
        StandardErrorPath = "/var/log/prometheus.err.log";
      };
    };

    grafana = {
      script = ''
        export G_HOME=/var/lib/grafana
        mkdir -p $G_HOME/{data,logs,plugins,provisioning/datasources}
        ln -sf ${grafanaDatasources} $G_HOME/provisioning/datasources/prometheus.yaml
        exec ${pkgs.grafana}/bin/grafana server \
          --config ${grafanaConfig} \
          --homepath ${pkgs.grafana}/share/grafana
      '';
      serviceConfig = {
        KeepAlive = true;
        RunAtLoad = true;
        StandardOutPath = "/var/log/grafana.out.log";
        StandardErrorPath = "/var/log/grafana.err.log";
        UserName = "root";
      };
    };
  };

  system.activationScripts.postActivation.text = lib.mkIf enabled ''
    sudo mkdir -p /var/lib/prometheus
    sudo chown -R _prometheus-node-exporter /var/lib/prometheus || true
    sudo mkdir -p /var/lib/grafana
    sudo chmod 755 /var/lib/grafana
  '';
}
