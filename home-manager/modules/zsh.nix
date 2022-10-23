{ config, lib, pkgs, ... }:
let cfg = config.within.zsh;
in with lib; {
  options.within.zsh = { enable = mkEnableOption "ZSH"; };

  config = mkIf cfg.enable {
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

        o = "xdg-open";

        nvimgit = "nvim +Git +'bdelete 1'";
        update-nvim-packer = "nvim +PackerSync";

        ns = "NIXPKGS_ALLOW_UNFREE=1 nix shell --impure";
        nr = "NIXPKGS_ALLOW_UNFREE=1 nix run --impure";

        oro = "nvim ~/Documents/private/orgmode/optimize.org";
      };
      sessionVariables = {
        LANG = "en_US.UTF-8";
        LANGUAGE = "en_US.UTF-8";
        FZF_BASE = "${pkgs.fzf}/share/fzf";

        # vi mode plugin
        VI_MODE_SET_CURSOR = true;
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
        plugins =
          [ "git" "fzf" "colored-man-pages" "vi-mode" "safe-paste" "wd" ];
      };
    };
  };
}
