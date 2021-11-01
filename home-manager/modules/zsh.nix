{ pkgs, config, ... }:
{
    programs.zsh = {
      enable = true;
      enableAutosuggestions = true;
      enableCompletion = true;
      enableSyntaxHighlighting = true;
      dotDir = ".config/zsh";
      shellAliases = {
        free = "free -h";
        df = "df -h";
        cdtmp = "cd $(mktemp -d)";

        nvimgit = "nvim +Git +only +'bdelete 1'";

        ns = "NIXPKGS_ALLOW_UNFREE=1 nix shell --impure";
        nr = "NIXPKGS_ALLOW_UNFREE=1 nix run --impure";
      };
      sessionVariables = {
        FZF_BASE = "${pkgs.fzf}/share/fzf";

        # vi mode plugin
        VI_MODE_RESET_PROMPT_ON_MODE_CHANGE = true;
        MODE_INDICATOR = "%B%F{white}<%b<<%f";
        WD_CONFIG = "${config.xdg.configHome}/warprc";
      };
      initExtra = ''
        setopt HIST_IGNORE_ALL_DUPS
      '';
      history = {
        ignoreDups = true;
        share = false;
        ignoreSpace = true;
        path = ".local/share/zsh/zsh_history";
        save = 10000;
      };
      oh-my-zsh = {
        enable = true;
        theme = "robbyrussell";
        plugins = [
          "git"
          "fzf"
          "colored-man-pages"
          "vi-mode"
          "safe-paste"
          "wd"
        ];
      };
    };
}
