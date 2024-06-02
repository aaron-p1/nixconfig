{ config, lib, pkgs, ... }:
let
  inherit (lib) removePrefix removeSuffix mkEnableOption mkIf;

  cfg = config.within.firefox;

  toPlainId = id: removePrefix "{" (removeSuffix "}" id);

  sidebery = pkgs.nur.repos.rycee.firefox-addons.sidebery;
  sideberyId = toPlainId sidebery.addonId;

  # https://www.userchrome.org/what-is-userchrome-js.html#combinedloader
  firefox = (pkgs.firefox.overrideAttrs (old: {
    buildCommand = old.buildCommand + # bash
      ''
        echo 'pref("general.config.sandbox_enabled", false);' >> $out/lib/firefox/defaults/pref/autoconfig.js
      '';
  })).override {
    extraPrefs = # javascript
      ''
        function applyCustomScriptToNewWindow(win){
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

        /* Single function userChrome.js loader to run the above init function (no external scripts)
          derived from https://www.reddit.com/r/firefox/comments/kilmm2/ */
        try {
          let { classes: Cc, interfaces: Ci, manager: Cm  } = Components;
          const Services = globalThis.Services;
          function ConfigJS() { Services.obs.addObserver(this, 'chrome-document-global-created', false); }
          ConfigJS.prototype = {
            observe: function (aSubject) { aSubject.addEventListener('DOMContentLoaded', this, {once: true}); },
            handleEvent: function (aEvent) {
              let document = aEvent.originalTarget; let window = document.defaultView; let location = window.location;
              if (/^(chrome:(?!\/\/(global\/content\/commonDialog|browser\/content\/webext-panels)\.x?html)|about:(?!blank))/i.test(location.href)) {
                if (window._gBrowser) applyCustomScriptToNewWindow(window);
              }
            }
          };
          if (!Services.appinfo.inSafeMode) { new ConfigJS(); }
        } catch(ex) {};
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
        };

        userChrome =
          # CSS
          ''
            #main-window[titlepreface*="​"] #TabsToolbar {
              display: none !important;
            }
          '';

        userContent =
          # CSS
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
