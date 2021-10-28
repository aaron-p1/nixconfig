{ pkgs, lib, ... }:
{
  home.packages = with pkgs; [
    jetbrains.idea-ultimate
    (buildFHSUserEnv {
      name = "codeWithMe";
      targetPkgs = pkgs: (with pkgs; [
        unzip
        glib
        zlib
        gawk
        coreutils
        wget
        bash
        fontconfig
        freetype
        noto-fonts
        liberation_ttf
        xorg.libXext
        xorg.libX11
        xorg.libXrender
        xorg.libXtst
        xorg.libXi
        xorg.libXcursor
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
        "bash -c '${script}' '' \"$1\"" ;
    })
  ];

  programs.java.enable = true;

  home.file.".jdks/openjdk-11".source = pkgs.jdk11;
  home.file.".jdks/openjdk-8".source = pkgs.jdk8;
}
