{ config, lib, pkgs, ... }:
let cfg = config.within.tmux;
in with lib; {
  options.within.tmux = { enable = mkEnableOption "tmux"; };

  config = mkIf cfg.enable {
    programs.tmux = {
      enable = true;

      keyMode = "vi";
      clock24 = true;
      escapeTime = 0;

      historyLimit = 5000;

      tmuxp.enable = false; # not needed for gotmux

      terminal = "tmux-256color";

      extraConfig = ''
        set-option -sa terminal-overrides ',xterm-256color:RGB'

        # Underline
        set -as terminal-overrides ',*:Smulx=\E[4::%p1%dm'
        # Underline Color
        set -as terminal-overrides ',*:Setulc=\E[58::2::%p1%{65536}%/%d::%p1%{256}%/%{255}%&%d::%p1%{255}%&%d%;m'
      '';

      plugins = with pkgs.tmuxPlugins; [{
        plugin = onedark-theme;
        extraConfig = ''
          set -g @onedark_date_format "%y-%m-%d"
        '';
      }];
    };

    xdg.configFile."tmuxp/nixconfig.yml" = {
      text = ''
        session_name: nixconfig
        start_directory: ${config.home.homeDirectory}/Documents/nixos/nixconfig
        windows:
        - window_name: nvim
          panes:
          - shell_command:
            - sleep 0.1
            - nvimgit
        - window_name: zsh
        - window_name: man home-manager
          panes:
          - man home-configuration.nix
      '';
    };

    home.packages = [ pkgs.local.gotmux ];
  };
}
