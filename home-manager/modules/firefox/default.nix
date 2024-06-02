{ config, lib, pkgs, ... }:
let
  inherit (builtins) head match readFile;
  inherit (lib) mkEnableOption mkIf;

  cfg = config.within.firefox;

  toPlainAddonId = addonId: head (match "^\\{(.*)}$" addonId);

  sidebery = pkgs.nur.repos.rycee.firefox-addons.sidebery;
  sideberyId = toPlainAddonId sidebery.addonId;

  # https://www.userchrome.org/what-is-userchrome-js.html#combinedloader
  firefox = (pkgs.firefox.overrideAttrs (old: {
    buildCommand = old.buildCommand + # bash
      ''
        echo 'pref("general.config.sandbox_enabled", false);' >> $out/lib/firefox/defaults/pref/autoconfig.js
      '';
  })).override {
    extraPrefs = # javascript
      ''
        function runInWindow(win){
          function getElem(elem){
            return win.document.getElementById(elem);
          }

          // ctrl+o will be used for Sidebery prev active tab
          getElem("openFileKb")?.remove();
          // ctrl+i will be used for Sidebery next active tab
          getElem("key_viewInfo")?.remove();

          // ctrl+p will be used for Sidebery prev tab
          getElem("printKb")?.remove();
          // ctrl+n will be used for Sidebery next tab
          getElem("key_undoCloseWindow")?.setAttribute("modifiers", "accel,shift,alt");
          getElem("key_newNavigator")?.setAttribute("modifiers", "accel,shift");
        }

        ${readFile ./user-chome-js-loader.js}
      '';
  };
in {
  options.within.firefox = { enable = mkEnableOption "Firefox"; };

  config = mkIf cfg.enable {
    programs.firefox = {
      enable = true;
      package = firefox;

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
          "extensions.autoDisableScopes" = 15;
          "extensions.pocket.enabled" = false;
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
          dearrow
          ublock-origin
          videospeed
          vue-js-devtools
        ];

        search.default = "DuckDuckGo";
        search.privateDefault = "DuckDuckGo";
        search.force = true;
        search.engines = let
          nixIcon =
            "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
        in {
          "Nix Packages" = {
            urls = [{
              template = "https://search.nixos.org/packages";
              params = [
                {
                  name = "channel";
                  value = "unstable";
                }
                {
                  name = "query";
                  value = "{searchTerms}";
                }
              ];
            }];

            icon = nixIcon;
            definedAliases = [ "@np" ];
          };

          "Nix Options" = {
            urls = [{
              template = "https://search.nixos.org/options";
              params = [
                {
                  name = "channel";
                  value = "unstable";
                }
                {
                  name = "query";
                  value = "{searchTerms}";
                }
              ];
            }];

            icon = nixIcon;
            definedAliases = [ "@no" ];
          };

          "NixOS Wiki" = {
            urls = [{
              template = "https://wiki.nixos.org/w/index.php";
              params = [{
                name = "search";
                value = "{searchTerms}";
              }];
            }];

            icon = nixIcon;
            definedAliases = [ "@nw" ];
          };

          "Google".metaData.alias = "@g";
          "Bing".metaData.hidden = true;
        };

        userChrome = # CSS
          ''
            /* context menu no navigation buttons */
            #context-navigation, #context-sep-navigation {
              display: none !important;
            }

            /* hide empty tab notifications (e.g. translation) */
            #tab-notification-deck notification:empty {
              display: none !important;
            }

            /* Sidebery hide tab bar and side bar title
                if Sidebery is open in sidebar */
            #main-window:has(
              #sidebar-box[sidebarcommand*="${sideberyId}"]:not([hidden="true"])
            ) {
              #TabsToolbar {
                display: none !important;
              }

              #sidebar-header {
                display: none !important;;
              }

              /** change style of sidebar splitter:
               * - same dark border as top navigator toolbox
               * - dragging hit box should stay the same
               */
              #sidebar-splitter {
                width: 6px !important;
                margin-right: -5px !important;
                z-index: 1 !important;
                background: transparent !important;
                border: none !important;
                border-left: 1px solid var(--chrome-content-separator-color) !important;
              }
            }
          '';

        userContent = # CSS
          ''
            @-moz-document domain(chatgpt.com) {
              @media (min-width: 1280px) {
                /* make chat wider */
                .text-token-text-primary > div > div {
                  max-width: 80rem !important;
                }
              }
            }
          '';
      };

      nativeMessagingHosts =
        [ pkgs.local.ff2mpv-native-client pkgs.plasma-browser-integration ];
    };
  };
}
