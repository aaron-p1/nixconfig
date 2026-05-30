{ config, lib, ... }:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.within.zsh;
in
{
  _class = "homeManager";

  options.within.zsh = {
    enable = mkEnableOption "ZSH";
  };

  config = mkIf cfg.enable {
    programs = {
      zsh = {
        enable = true;
        autosuggestion.enable = true;
        enableCompletion = true;
        syntaxHighlighting = {
          enable = true;
          styles = {
            assign = "bold";
            comment = "fg=#928374";
            redirection = "fg=magenta";
          };
        };
        dotDir = "${config.xdg.configHome}/zsh";
        shellAliases = {
          ":q" = "exit";

          free = "free -h";
          df = "df -h";
          cdtmp = "cd $(mktemp -d)";

          o = "xdg-open";

          nvimgit = "nvim +Git +'bdelete 1'";
          # run editor with git (e already exists)
          eg = "nvim +Git +'bdelete 1'";

          ssh = "TERM=xterm-256color ssh";
        };
        sessionVariables = {
          LANG = "en_US.UTF-8";
          LANGUAGE = "en_US.UTF-8";

          # vi mode plugin
          VI_MODE_SET_CURSOR = 1;
          WD_CONFIG = "${config.xdg.configHome}/warprc";
        };
        history = {
          append = true;
          ignoreDups = true;
          ignoreAllDups = true;
          share = false;
          ignoreSpace = true;
          path = "${config.xdg.dataHome}/zsh/zsh_history";
          save = 10000000;
        };
        oh-my-zsh = {
          enable = true;
          theme = "robbyrussell";
          plugins = [
            "git"
            "colored-man-pages"
            "vi-mode"
            "safe-paste"
            "wd"
          ];
        };
      };

      zoxide = {
        enable = true;
        enableZshIntegration = true;
      };
    };
  };
}
