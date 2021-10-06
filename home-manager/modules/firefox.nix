{ pkgs, ... }:
{
  programs.firefox = {
    enable = true;

    extensions = with pkgs.nur.repos.rycee.firefox-addons; [
      bitwarden
      sponsorblock
      multi-account-containers
      privacy-badger
      sidebery
      ff2mpv
    ];

    profiles.main = {
      id = 0;
      isDefault = true;
      settings = {
        "browser.aboutConfig.showWarning" = false;
        "browser.search.isUS" = false;
        "browser.search.region" = "DE";
        "browser.startup.homepage" = "about:blank";
        "browser.newtabpage.enabled" = false;
        "browser.uidensity" = 1;
        "devtools.theme" = "dark";
        "devtools.toolbox.host" = "window";
        "general.useragent.locale" = "de-DE";
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
}
