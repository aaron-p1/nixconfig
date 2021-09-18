{ pkgs, ... }:
{
  virtualisation.containers = {
    enable = true;
    containersConf.settings = {
      engine.network_cmd_options = ["allow_host_loopback=true"];
    };
  };
}
