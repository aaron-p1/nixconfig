{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (builtins) head match;
  inherit (lib) mkEnableOption mkIf;

  cfg = config.within.firefox;

  toPlainAddonId = addonId: head (match "^\\{(.*)}$" addonId);

  sidebery = pkgs.nur.repos.rycee.firefox-addons.sidebery;
  sideberyPlainId = toPlainAddonId sidebery.addonId;

  onePassword = pkgs.nur.repos.rycee.firefox-addons.onepassword-password-manager;
  onePasswordId = onePassword.addonId;

  # https://www.userchrome.org/what-is-userchrome-js.html#combinedloader
  firefox =
    (pkgs.firefox.overrideAttrs (old: {
      buildCommand =
        old.buildCommand
        # bash
        + ''
          echo 'pref("general.config.sandbox_enabled", false);' >> $out/lib/firefox/defaults/pref/autoconfig.js
        '';
    })).override
      {
        extraPrefs = pkgs.callPackage ./userchromejs {
          nativeShortcutsRemoved = [
            # ctrl+k is often used by websites for search
            "key_search"
            # ctrl+j will be used for toggling shortcuts permission
            "key_search2"

            # ctrl+o will be used for Sidebery prev active tab
            "openFileKb"
            # ctrl+i will be used for Sidebery next active tab
            "key_viewInfo"
            # ctrl+shift+o will be used for Sidebery new tab under current
            "manBookmarkKb"
            # ctrl+p will be used for Sidebery prev tab
            "printKb"
            # ctrl+s will be used for Sidebery search
            "key_savePage"
          ];

          nativeShortcutChanges = {
            # ctrl+n will be used for Sidebery next tab
            # so add modifiers to existing ctrl+n and ctrl+shift+n
            key_undoCloseWindow.modifiers = "accel,shift,alt";
            key_newNavigator.modifiers = "accel,shift";
          };

          shortcuts = {
            # focus website window or send keydown Escape to website
            "Escape" = # javascript
              ''
                // for some reason, Sidebery search input needs over 100 ms delay
                // ctrl+f search, etc. only needs 10 ms
                const delay = bWindow.document.activeElement.id === "sidebar" ? 150 : 10;

                bWindow.setTimeout(() => {
                  const browser = bWindow.gBrowser.selectedBrowser
                  if (bWindow.document.activeElement === browser) {
                    return;
                  }

                  browser.focus()
                }, delay);

                // give key to website, because shortcut permissions prevent keydown esc for some reason
                const browser = bWindow.gBrowser.selectedBrowser
                if (bWindow.document.activeElement === browser) {
                  resendKey(browser, event, { down: true });
                }
              '';

            # reload current page with http
            "CTRL+ALT+SHIFT+L" = # javascript
              ''
                const browser = bWindow.gBrowser.selectedBrowser
                const url = browser.currentURI.spec
                if (url.startsWith("https://")) {
                  const principal = Services.scriptSecurityManager.getSystemPrincipal()
                  const uri = Services.io.newURI(url.replace("https://", "http://"))
                  browser.loadURI(uri, {triggeringPrincipal: principal})
                }
              '';

            # toggle "userresizable" attribute on #sidebar-box
            "ALT+s" = # javascript
              ''
                event.preventDefault();

                const sidebarBox = bWindow.document.getElementById("sidebar-box");
                if (!sidebarBox) {
                  return;
                }

                const isResizable = sidebarBox.getAttribute("userresizable") === "true";
                sidebarBox.setAttribute("userresizable", isResizable ? "false" : "true");
              '';

            # CTRL+SHIFT+Numpad1: toggle 1Password addon enabled/disabled state
            "CTRL+SHIFT+End" = # javascript
              ''
                (async function() {
                  const addon = await AddonManager.getAddonByID("${onePasswordId}");

                  if (addon.isActive) {
                    addon.disable();
                  } else if (addon.userDisabled) {
                    // Only enable if I disabled it
                    addon.enable();
                  }
                })();
              '';

            # focus Sidebery search in sidebar
            "CTRL+s" = # javascript
              ''
                // sidebar command is _3c078156-979c-498b-8990-85f7987dd929_-sidebar-action
                const isSideberySidebarOpen = bWindow.document
                  .querySelector(
                    '#sidebar-box[sidebarcommand*="${sideberyPlainId}"]:not([hidden="true"])'
                  );

                if (!isSideberySidebarOpen) {
                  return;
                }

                if (bWindow.sidebar) {
                  Services.focus.moveFocus(bWindow.sidebar, null, null, Services.focus.FLAG_BYKEY)
                  bWindow.sidebar.document.getElementById("webext-panels-browser").focus()
                }
              '';
          };

          websiteInjections = {
            # remove all keybindings outside of editor
            "app.asana.com" = # javascript
              ''
                window.document.addEventListener("keydown", e => {
                  if (e.target && !e.target.className.toLowerCase().includes("editor")) {
                    e.stopImmediatePropagation();
                  }
                }, true);
              '';
          };
        };
      };
in
{
  options.within.firefox = {
    enable = mkEnableOption "Firefox";
  };

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

          "browser.ai.control.default" = "blocked";
          "browser.ai.control.linkPreviewKeyPoints" = "blocked";
          "browser.ai.control.pdfjsAltText" = "blocked";
          "browser.ai.control.sidebarChatbot" = "blocked";
          "browser.ai.control.smartTabGroups" = "blocked";
          "browser.ai.control.translations" = "blocked";

          "browser.ml.chat.enabled" = false;
          "browser.ml.enable" = false;
          "browser.ml.menu" = false;
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
          "middlemouse.paste" = false;
          "permissions.default.shortcuts" = 2;
          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        };
        extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
          bitwarden
          consent-o-matic
          ff2mpv
          multi-account-containers
          onePassword
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

        search.default = "ddg";
        search.privateDefault = "ddg";
        search.force = true;
        search.engines =
          let
            nixIcon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
          in
          {
            nix-pkgs = {
              name = "Nix Packages";
              urls = [
                {
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
                }
              ];

              icon = nixIcon;
              definedAliases = [ "@np" ];
            };

            nix-opts = {
              name = "Nix Options";
              urls = [
                {
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
                }
              ];

              icon = nixIcon;
              definedAliases = [ "@no" ];
            };

            nixos-wiki = {
              name = "NixOS Wiki";
              urls = [
                {
                  template = "https://wiki.nixos.org/w/index.php";
                  params = [
                    {
                      name = "search";
                      value = "{searchTerms}";
                    }
                  ];
                }
              ];

              icon = nixIcon;
              definedAliases = [ "@nw" ];
            };

            google.metaData.alias = "@g";
            bing.metaData.hidden = true;
            ecosia.metaData.hidden = true;
            perplexity.metaData.hidden = true;
          };

        userChrome = # CSS
          ''
            /* toggle keyboard shortcuts permission indicator */
            #site-shortcuts-icon {
              list-style-image: url("chrome://browser/skin/quickactions.svg");
              /* forward the property/ies into the external SVG */
              -moz-context-properties: fill, fill-opacity;
              fill: currentColor;
              /* size & box model identical to native icons */
              width: 16px;
              height: 16px;
              margin: 3px;
            }

            /* hide empty tab notifications (e.g. translation) */
            #tab-notification-deck notification:empty {
              display: none !important;
            }

            /* Sidebery hide tab bar and side bar title
                if Sidebery is open in sidebar */
            #main-window:has(
              #sidebar-box[sidebarcommand*="${sideberyPlainId}"]:not([hidden="true"])
            ) {
              #TabsToolbar {
                display: none !important;
              }

              #sidebar-header {
                display: none !important;
              }

              #sidebar-box:not([userresizable="true"]) {
                width: 220px !important;
              }
            }
          '';

        userContent = # CSS
          ''
            @-moz-document domain(github.com) {
              /* fix double click in files not working reliably */
              .code-navigation-cursor {
                pointer-events: none;
              }
            }
          '';
      };

      nativeMessagingHosts = [
        pkgs.local.ff2mpv-native-client
        pkgs.kdePackages.plasma-browser-integration
      ];
    };
  };
}
