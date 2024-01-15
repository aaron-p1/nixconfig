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

      profiles.main = {
        id = 0;
        isDefault = true;
        settings = {
          "browser.aboutConfig.showWarning" = false;
          "browser.download.always_ask_before_handling_new_types" = true;
          "browser.download.improvements_to_download_panel" = false;
          "browser.download.start_downloads_in_tmp_dir" = true;
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
          "intl.regional_prefs.use_os_locales" = true;
          "media.ffmpeg.vaapi.enabled" = true;
          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        };
        extensions = with pkgs.nur.repos.rycee.firefox-addons; [
          bitwarden
          ff2mpv
          multi-account-containers
          onepassword-password-manager
          plasma-integration
          privacy-badger
          return-youtube-dislikes
          sidebery
          sponsorblock
          ublock-origin
          videospeed
          vue-js-devtools
        ];
        userChrome = ''
          #main-window[titlepreface*="​"] #TabsToolbar {
            display: none !important;
          }
        '';
      };
    };
  };
}
