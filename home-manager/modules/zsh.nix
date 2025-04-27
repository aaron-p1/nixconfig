{ config, lib, pkgs, ... }:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.within.zsh;
in {
  options.within.zsh = { enable = mkEnableOption "ZSH"; };

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
        dotDir = ".config/zsh";
        shellAliases = {
          ":q" = "exit";

          free = "free -h";
          df = "df -h";
          cdtmp = "cd $(mktemp -d)";

          o = "xdg-open";

          nvimgit = "nvim +Git +'bdelete 1'";
          update-nvim-packer = "nvim +PackerSync";

          ns = "NIXPKGS_ALLOW_UNFREE=1 nix shell --impure";
          nr = "NIXPKGS_ALLOW_UNFREE=1 nix run --impure";

          ssh = "TERM=xterm-256color ssh";

          "??" = "copilot-cli shell";
          "?git" = "copilot-cli git";
        };
        sessionVariables = {
          LANG = "en_US.UTF-8";
          LANGUAGE = "en_US.UTF-8";
          FZF_BASE = "${pkgs.fzf}/share/fzf";

          # vi mode plugin
          VI_MODE_SET_CURSOR = true;
          WD_CONFIG = "${config.xdg.configHome}/warprc";
        };
        initContent = ''
          setopt HIST_IGNORE_ALL_DUPS
        '';
        history = {
          append = true;
          ignoreDups = true;
          share = false;
          ignoreSpace = true;
          path = "${config.xdg.dataHome}/zsh/zsh_history";
          save = 100000;
        };
        oh-my-zsh = {
          enable = true;
          theme = "robbyrussell";
          plugins = [ "git" "colored-man-pages" "vi-mode" "safe-paste" "wd" ];
        };
      };

      zoxide = {
        enable = true;
        enableZshIntegration = true;
      };
    };
  };
}
