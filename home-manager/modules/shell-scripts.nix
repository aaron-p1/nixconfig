{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.within.shellScripts;

  run-editor = pkgs.writeShellScriptBin "e" ''
    set -eu

    if [ -z "$EDITOR" ]; then
      echo "EDITOR is not set" >&2
      exit 1
    fi

    exec $EDITOR "$@"
  '';

  isolate = pkgs.writeShellApplication {
    name = "isolate";
    runtimeInputs = [ pkgs.bubblewrap ];
    text = ''
      exec bwrap \
        --unshare-all \
        --share-net \
        --die-with-parent \
        --proc /proc \
        --dev /dev \
        --tmpfs /tmp \
        --ro-bind /nix/store /nix/store \
        --ro-bind /run/current-system/sw /run/current-system/sw \
        --bind /run/dbus /run/dbus \
        --bind /run/user/$UID /run/user/$UID \
        --symlink "$(readlink /nix/store/mzqrpwsf8q2pv4k6xpgmc84vhnlzvkf8-graphics-drivers)" /run/opengl-driver \
        --ro-bind /etc/profiles/per-user/aaron /etc/profiles/per-user/aaron \
        --ro-bind /bin /bin \
        --ro-bind /usr /usr \
        --ro-bind /lib /lib \
        --ro-bind /lib64 /lib64 \
        --ro-bind /etc /etc \
        --dir "/home/$USER" \
        "$@"
    '';
  };

  isolate-pwd = pkgs.writeShellScriptBin "isolate-pwd" ''
    exec ${isolate}/bin/isolate --bind "$PWD" "$PWD" "$@"
  '';
in
{
  options.within.shellScripts = {
    enable = mkEnableOption "Enable common shell scripts";
  };

  config = mkIf cfg.enable {
    home.packages = [
      run-editor
      isolate
      isolate-pwd
    ];
  };
}
