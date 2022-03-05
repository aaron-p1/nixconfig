{ config, lib, pkgs, ... }:
let cfg = config.within.firefox;
in with lib; {
  options.within.firefox = { enable = mkEnableOption "Firefox"; };

  config = mkIf cfg.enable {
    # firefox override not working "gtk3 missing" (in browser parameter wrapper.nix)
    # https://github.com/nix-community/home-manager/issues/1586
    home.file.".mozilla/native-messaging-hosts/org.kde.plasma.browser_integration.json".source =
      "${pkgs.plasma-browser-integration}/lib/mozilla/native-messaging-hosts/org.kde.plasma.browser_integration.json";

    # ff2mpv does not exist in repo
    home.file.".mozilla/native-messaging-hosts/ff2mpv.json".source =
      "${pkgs.local.ff2mpv-native-client}/lib/mozilla/native-messaging-hosts/ff2mpv.json";

    programs.firefox = {
      enable = true;

      extensions = with pkgs.nur.repos.rycee.firefox-addons; [
        bitwarden
        sponsorblock
        multi-account-containers
        privacy-badger
        sidebery
        ff2mpv
        plasma-integration # deleted by mozilla: https://addons.mozilla.org/en-US/firefox/addon/plasma-integration/
        ublock-origin
      ];

      profiles.main = {
        id = 0;
        isDefault = true;
        settings = {
          "browser.aboutConfig.showWarning" = false;
          "browser.newtabpage.enabled" = false;
          "browser.search.isUS" = false;
          "browser.search.region" = "DE";
          "browser.startup.homepage" = "about:blank";
          "browser.uidensity" = 1;
          "browser.urlbar.trimURLs" = false;
          "devtools.theme" = "dark";
          "devtools.toolbox.host" = "window";
          "extensions.update.autoUpdateDefault" = false;
          "general.useragent.locale" = "de-DE";
          "media.ffmpeg.vaapi.enabled" = true;
          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        };
        userChrome = ''
          #main-window #TabsToolbar {
            height: inherit !important;
            overflow: hidden;
          }
          #main-window[titlepreface*="​"] #TabsToolbar {
            height: 0 !important;
          }
          #main-window[titlepreface*="​"] #tabbrowser-tabs {
            z-index: 0 !important;
          }
        '';
      };
    };
  };
}
