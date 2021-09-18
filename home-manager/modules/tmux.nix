{ pkgs, ... }:
{
  programs.tmux = {
    enable = true;

    clock24 = true;
    escapeTime = 0;

    historyLimit = 5000;

    terminal = "tmux-256color";

    tmuxp.enable = true;

    extraConfig = ''
      set-option -sa terminal-overrides ',xterm-256color:RGB'

      # Underline
      set -as terminal-overrides ',*:Smulx=\E[4::%p1%dm'
      # Underline Color
      set -as terminal-overrides ',*:Setulc=\E[58::2::%p1%{65536}%/%d::%p1%{256}%/%{255}%&%d::%p1%{255}%&%d%;m'
    '';

    plugins = with pkgs.tmuxPlugins; [
      {
        plugin = onedark-theme;
        extraConfig = ''
          set -g @onedark_date_format "%y-%m-%d"
        '';
      }
    ];
  };
}
