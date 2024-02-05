{ osConfig, lib, pkgs, ... }:
let
  inherit (lib) concatStringsSep mapAttrsToList attrNames optional;

  renderLine = name: value: "${name}=${value}";
  renderSection = name: attrs: ''
    [${name}]
    ${concatStringsSep "\n" (mapAttrsToList renderLine attrs)}
  '';
  renderAction = name: attrs: renderSection "Desktop Action ${name}" attrs;

  makeDesktopFile = name:
    { entry, actions ? { } }:
    pkgs.writeTextFile {
      name = "${name}.desktop";
      destination = "/share/kservices5/ServiceMenus/${name}.desktop";
      text = let
        actionLine = if actions != { } then
          renderLine "Actions" (concatStringsSep ";" (attrNames actions))
        else
          "";
      in ''
        ${renderSection "Desktop Entry" entry}
        ${actionLine}

        ${concatStringsSep "\n\n" (mapAttrsToList renderAction actions)}
      '';
    };

  tailscaleBin = "${pkgs.tailscale}/bin/tailscale";
  jqBin = "${pkgs.jq}/bin/jq";
  kdialogBin = "${pkgs.kdialog}/bin/kdialog";

  taildropScript = pkgs.writeShellScript "taildrop" ''
    set -eu

    files=("$@")

    if [ ''${#files[@]} -eq 0 ]; then
      ${kdialogBin} --title "Taildrop" --sorry "No files selected"
      exit 0
    fi

    hosts=(
      $(
        ${tailscaleBin} status --json | ${jqBin} --raw-output \
          '.Peer.[] | select(.Online == true) | .DNSName | split(".") | .[0]'
      )
    )

    if [ ''${#hosts[@]} -eq 0 ]; then
      ${kdialogBin} --title "Taildrop" --sorry "No hosts online"
      exit 0
    fi

    chosen="$(${kdialogBin} --title 'Test' \
      --radiolist "Choose host to share with" ''${hosts[@]/%*/& & off})"

    if [ -z "$chosen" ]; then
      exit 0
    fi

    pkexec ${tailscaleBin} file cp "''${files[@]}" "$chosen:"

    ${kdialogBin} --title "Taildrop" \
      --passivepopup "''${files[@]##*/} shared with $chosen"
  '';
in {
  config = {
    home.packages = let
      taildrop = makeDesktopFile "Taildrop" {
        entry = {
          Type = "Service";
          X-KDE-ServiceTypes = "KonqPopupMenu/Plugin";
          MimeType = "application/octet-stream";
        };
        actions.shareWithTaildrop = {
          Name = "Share with Taildrop";
          Icon = ./icons/tailscale-icon.svg;
          Exec = "${taildropScript} %F";
        };
      };
    in optional osConfig.within.tailscale.enable taildrop;
  };
}
