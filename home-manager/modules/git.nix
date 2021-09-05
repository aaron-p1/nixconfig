{ pkgs, ... }:
{
  programs.git = {
    enable = true;
    aliases = {
      co = "checkout";
      f = "fetch";
    };
    userName = "Aaron Pietscher";
    signing = {
      signByDefault = true;
      key = "59C3DF25ECE049B6";
    };
  };

  home.packages = with pkgs; [
    (
      pkgs.writeTextFile rec {
        name = "gitemail";
        destination = "/bin/${name}";
        executable = true;
        text = ''
          #!/bin/sh

          if [ ! -r "$HOME/.local/share/gitemails" ]
          then
            echo "create File $HOME/.local/share/gitemails"
            echo "[shortform]\\t[email]"
            exit 1
          fi

          usage() {
            echo "Usage: gitemail {shortform}"
            cat "$HOME/.local/share/gitemails"
            exit 2
          }

          [ -z "$1" ] && usage

          result=$(grep "^$1" "$HOME/.local/share/gitemails" | head | cut -f2)

          [ -z "$result" ] && usage

          ${pkgs.git}/bin/git config user.email "$result"
        '';
      }
    )
  ];
}
