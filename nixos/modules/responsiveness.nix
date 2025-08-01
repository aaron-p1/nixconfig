{ config, lib, ... }:
let
  inherit (lib)
    mkEnableOption
    mkOption
    mkIf
    isAttrs
    filterAttrs
    optionalAttrs
    ;
  inherit (lib.types) nullOr str int;

  cfg = config.within.responsiveness;

  hasValue =
    attrs:
    ((filterAttrs (name: value: if isAttrs value then hasValue value else value != null)) attrs) != { };

  toSystemdConfig =
    {
      configName ? "serviceConfig",
      override ? false,
    }:
    attrs:
    let
      res = attrs.resources or { };

      conf = {
        ${configName} = {
          CPUWeight = res.cpu.weight;
          MemoryLow = res.memory.low;
          IOWeight = res.io.weight;
        };
      }
      // optionalAttrs override { overrideStrategy = "asDropin"; };
    in
    mkIf (hasValue res) conf;

  toSliceConfigOverride = toSystemdConfig {
    configName = "sliceConfig";
    override = true;
  };

  toServiceConfig = toSystemdConfig {
    configName = "serviceConfig";
    override = false;
  };
  toServiceConfigOverride = toSystemdConfig {
    configName = "serviceConfig";
    override = true;
  };

  # man systemd.resource-control
  resourceOptions = {
    cpu.weight = mkOption {
      type = nullOr int;
      default = null;
      description = "CPU weight";
    };
    memory.low = mkOption {
      type = nullOr str;
      default = null;
      description = "Min memory it protects in RAM";
    };
    io.weight = mkOption {
      type = nullOr int;
      default = null;
      description = "IO weight";
    };
  };
in
{
  options.within.responsiveness = {
    enable = mkEnableOption "Enable responsiveness module";

    # systemd-cgls
    system.nix-daemon.resources = resourceOptions;
    user = {
      resources = resourceOptions;

      session.resources = resourceOptions;
      app.firefox.resources = resourceOptions;
    };
  };

  config = mkIf cfg.enable {
    systemd = {
      slices = {
        system = toSliceConfigOverride cfg.system;
        user = toSliceConfigOverride cfg.user;
      };
      services.nix-daemon = toServiceConfig cfg.system.nix-daemon;

      user = {
        slices.session = toSliceConfigOverride cfg.user.session;
        services."app-firefox@" = toServiceConfigOverride cfg.user.app.firefox;
      };
    };
  };
}
