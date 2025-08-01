{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.within.idea-ultimate;
in
{
  options.within.idea-ultimate = {
    enable = mkEnableOption "idea-ultimate";
  };

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        jetbrains.idea-ultimate

        github-copilot-intellij-agent

        (buildFHSUserEnv {
          name = "codeWithMe";
          targetPkgs =
            pkgs:
            (with pkgs; [
              bash
              coreutils
              fontconfig
              freetype
              gawk
              glib
              liberation_ttf
              noto-fonts
              unzip
              wget
              xorg.libX11
              xorg.libXcursor
              xorg.libXext
              xorg.libXi
              xorg.libXrender
              xorg.libXtst
              zlib
              # browser libraries
              alsa-lib
              atk
              at-spi2-core
              cups
              dbus
              expat
              libdrm
              libxkbcommon
              mesa
              nspr
              nss
              xorg.libxcb
              xorg.libXcomposite
              xorg.libXdamage
              xorg.libXfixes
              xorg.libXrandr
              xorg.libxshmfence
            ]);
          runScript =
            let
              script = ''
                if [ -z "$1" ]
                then
                  echo "Usage: $0 {link}" 1>&2
                  exit 1
                fi

                id=$(<<< "$1" awk -F "[#/]" "{print \$4}")

                if [ "$(<<< "$id" wc -c)" != 23 ]
                then
                  echo "Link broken: $1 | $id" 1>&2
                  exit 1
                fi

                bash -c "$(wget -nv -O- "https://code-with-me.jetbrains.com/$id/cwm-client-launcher-linux.sh")"
              '';
            in
            "bash -c '${script}' '' \"$1\"";
        })
      ];

      file = {
        ".jdks/openjdk-17".source = pkgs.jdk17;
        ".jdks/openjdk-11".source = pkgs.jdk11;
        ".jdks/openjdk-8".source = pkgs.jdk8;
      };
    };

    programs.java.enable = true;
  };
}
