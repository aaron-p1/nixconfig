{ config, lib, pkgs, ... }:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.within.tmux;
in {
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
        set -as terminal-features "alacritty:RGB:extkeys:focus"

        # Underline
        set -as terminal-overrides ',*:Smulx=\E[4::%p1%dm'
        # Underline Color
        set -as terminal-overrides ',*:Setulc=\E[58::2::%p1%{65536}%/%d::%p1%{256}%/%{255}%&%d::%p1%{255}%&%d%;m'

        # key sequences
        set -s extended-keys always

        # focus events
        set -s focus-events on

        bind-key -N "Kills session" K confirm-before -p "Kill session?" kill-session
      '';

      plugins = [{
        plugin = pkgs.tmuxPlugins.onedark-theme;
        extraConfig = ''
          set -g @onedark_date_format "%y-%m-%d"
        '';
      }];
    };

    # https://tmuxp.git-pull.com/configuration/index.html
    xdg.configFile."tmuxp/nixconfig.yml" = {
      text = builtins.toJSON {
        session_name = "nixconfig";
        start_directory =
          "${config.home.homeDirectory}/Documents/nixos/nixconfig";
        windows = [
          {
            window_name = "nvim";
            panes = [ "nvimgit" ];
          }
          { window_name = "zsh"; }
          {
            window_name = "man nixos";
            panes = [ "man configuration.nix" ];
          }
          {
            window_name = "man home-manager";
            panes = [ "man home-configuration.nix" ];
          }
        ];
      };
    };

    home.packages = [ pkgs.local.gotmux ];
  };
}
