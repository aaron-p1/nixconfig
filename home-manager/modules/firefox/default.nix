{ config, lib, pkgs, ... }:
let
  inherit (builtins) head match readFile toJSON;
  inherit (lib) replaceStrings mkEnableOption mkIf;

  cfg = config.within.firefox;

  toPlainAddonId = addonId: head (match "^\\{(.*)}$" addonId);

  sidebery = pkgs.nur.repos.rycee.firefox-addons.sidebery;
  sideberyId = toPlainAddonId sidebery.addonId;

  # needed because in the js file, template strings are removed for some reason
  toJsString = replaceStrings [ "\n" ] [ "" ];

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
          win.console.log("---------------- Loading userChrome.js in " + win.location + " ----------------");

          function getElem(elem){
            return win.document.getElementById(elem);
          }

          function toggleSidebar(cmd) {
            const controller = win.SidebarController;

            if (!controller) {
              return;
            }

            if (controller.currentID === cmd && controller.isOpen) {
              controller.hide();
            } else {
              controller.show(cmd);
            }
          }

          // make Esc focus website
          {
            function focusWebsite(event) {
              if (event.key !== "Escape") {
                return;
              }

              // for some reason, Sidebery search input needs over 100 ms delay
              // ctrl+f search, etc. only needs 10 ms
              const time = win.document.activeElement.id === "sidebar" ? 150 : 10;

              win.setTimeout(() => {
                const browser = win.gBrowser.selectedBrowser

                if (win.document.activeElement === browser) {
                  return;
                }

                browser.focus()
              }, time)
            }

            win.document.addEventListener("keydown", focusWebsite, true);
          }

          // ctrl+alt+shift+l will load current page with http
          {
            function loadHttp(event) {
              if (!event.ctrlKey || !event.altKey || !event.shiftKey || event.key !== 'L') {
                return;
              }

              const browser = win.gBrowser.selectedBrowser
              const url = browser.currentURI.spec

              if (url.startsWith("https://")) {
                const principal = Services.scriptSecurityManager.getSystemPrincipal()
                const uri = Services.io.newURI(url.replace("https://", "http://"))

                browser.loadURI(uri, {triggeringPrincipal: principal})
              }
            }

            win.document.addEventListener("keydown", loadHttp, true);
          }

          // alt+s to toggle "userresizable" attribute on #sidebar-box
          {
            function toggleSidebarResizable(event) {
              if (!event.altKey || event.key !== 's') {
                return;
              }

              event.preventDefault();

              const sidebarBox = win.document.getElementById("sidebar-box");

              if (!sidebarBox) {
                return;
              }

              const isResizable = sidebarBox.getAttribute("userresizable") === "true";
              sidebarBox.setAttribute("userresizable", isResizable ? "false" : "true");
            }

            win.document.addEventListener("keydown", toggleSidebarResizable, true);
          }

          // alt+c to toggle sidebar "viewGenaiChatSidebar"
          {
            function toggleChatSidebar(event) {
              if (!event.altKey || event.key !== 'c') {
                return;
              }

              event.preventDefault();

              toggleSidebar("viewGenaiChatSidebar");
            }

            win.document.addEventListener("keydown", toggleChatSidebar, true);
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

          // ctrl+s will be used for Sidebery search
          getElem("key_savePage")?.remove();

          // ctrl+s should always focus Sidebery search in sidebar
          {
            function focusSideberySearch(event) {
              if (!event.ctrlKey || event.key !== 's') {
                return;
              }

              if (!win.document.querySelector('#sidebar-box[sidebarcommand*="${sideberyId}"]:not([hidden="true"])')) {
                return;
              }

              if (win.sidebar) {
                Services.focus.moveFocus(win.sidebar, null, null, Services.focus.FLAG_BYKEY)
                win.sidebar.document.getElementById("webext-panels-browser").focus()
              }
            }

            win.document.addEventListener("keydown", focusSideberySearch, true);
          }

          // inject javascript into websites
          {
            const injection = '${
              toJsString # javascript
              ''
                (function() {
                  const injections = {
                    /**
                     * Remove keybindings outside of editor on app.asana.com
                     * @param {Window} window
                     */
                    removeAsanaBindings(window) {
                      if (window.location.hostname !== "app.asana.com") {
                        return;
                      }

                      window.document.addEventListener("keydown", e => {
                        if (e.target && !e.target.className.toLowerCase().includes("editor")) {
                          e.stopImmediatePropagation();
                        }
                      }, true);
                    },

                    /**
                     * Add media controls to app.idagio.com
                     * @param {Window} window
                     */
                    addIdagioMediaControls(window) {
                      if (window.location.hostname !== "app.idagio.com") {
                        return;
                      }

                      window.document.addEventListener("DOMContentLoaded", () => {
                        /* I need the normal js context, so inject script element */
                        let scriptElem = window.document.createElement("script");
                        scriptElem.type = "text/javascript";

                        scriptElem.text = "${
                          replaceStrings [ ''"'' ] [ ''\\\\"'' ]
                          (toJsString # javascript
                            ''
                              const buttonIndices = {
                                prev: 1,
                                play: 2,
                                next: 3
                              };

                              function getButton(type) {
                                const mediaButtons = window.document.querySelector(
                                  "div[class^=player-PlayerControls__controls--]"
                                );

                                if (!mediaButtons) {
                                  window.console.error("mediabuttons not found");
                                  return;
                                }

                                const result = mediaButtons.children[buttonIndices[type]];

                                if (!result) {
                                  window.console.error(type + " button not found");
                                  return;
                                }

                                return result;
                              }

                              window.setInterval(() => {
                                const playerInfoElement = window.document.querySelector(
                                  "div[class^=player-PlayerInfo__infoEl--]"
                                );

                                if (!playerInfoElement) {
                                  return;
                                }

                                const [artistElem, _, recordingElem, trackElem] = playerInfoElement.children;

                                if (!artistElem || !recordingElem || !trackElem) {
                                  return;
                                }

                                const artist = artistElem.textContent;
                                const recording = recordingElem.textContent;
                                const track = trackElem.children[1].textContent;

                                window.navigator.mediaSession.metadata = new window.MediaMetadata({
                                  title: recording + " - " + track,
                                  artist: artist
                                });
                              }, 1000);

                              window.navigator.mediaSession.setActionHandler("play", () => {
                                getButton("play")?.click();
                              });
                              window.navigator.mediaSession.setActionHandler("pause", () => {
                                getButton("play")?.click();
                              });
                              window.navigator.mediaSession.setActionHandler("previoustrack", () => {
                                getButton("prev")?.click();
                              });
                              window.navigator.mediaSession.setActionHandler("nexttrack", () => {
                                getButton("next")?.click();
                              });
                            '')
                        }";

                        window.document.head.appendChild(scriptElem);
                      });
                    },
                  };

                  var observer = {
                    observe(subject, topic, data) {
                      if (topic === "content-document-global-created") {
                        let window = subject;

                        try {
                          for (const [name, injection] of Object.entries(injections)) {
                            injection(window);
                          }
                        } catch (e) {
                          window.console.error(e);
                        }
                      }
                    }
                  };

                  Services.obs.addObserver(observer, "content-document-global-created");

                  addEventListener("unload", () => {
                    Services.obs.removeObserver(observer, "content-document-global-created");
                  });
                })()
              ''
            }';

            // Load the frame script into all existing and future content processes
            Services.mm.loadFrameScript("data:,(" + win.encodeURIComponent(injection) + ")", true);
          }
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
        settings = let
          mlSelectionPromptPrefix = ''
            I'm on a website with the title “%tabTitle%” and I have the following content selected: <<EOSEL
            %selection|12000%
            EOSEL
          '';
        in {
          "browser.aboutConfig.showWarning" = false;
          "browser.download.always_ask_before_handling_new_types" = true;
          "browser.download.improvements_to_download_panel" = false;
          "browser.download.start_downloads_in_tmp_dir" = true;

          "browser.ml.chat.enabled" = true;
          "browser.ml.chat.prompt.prefix" = mlSelectionPromptPrefix;
          "browser.ml.chat.prompts.0" = toJSON {
            priority = 100;
            label = "Summarize";
            value = ''
              Please summarize the selection using precise and concise language.
              Use headers and bulleted lists in the summary, to make it scannable.
              Maintain the meaning and factual accuracy.
            '';
          };
          "browser.ml.chat.prompts.1" = toJSON {
            priority = 90;
            label = "Explain";
            value = ''
              Please explain the key concepts in this selection, using simple words.
              Also, use examples.
            '';
          };
          "browser.ml.chat.prompts.2" = toJSON {
            priority = 80;
            label = "Simplify language";
            value = ''
              Please simplify the selection using easy-to-understand language.
              Use short sentences and common words.
              Maintain the meaning and factual accuracy.
            '';
          };
          "browser.ml.chat.prompts.3" = toJSON { targeting = "false"; };
          "browser.ml.chat.provider" =
            "https://chatgpt.com/?temporary-chat=true";
          "browser.ml.chat.shortcuts" = false;
          "browser.ml.chat.shortcuts.custom" = true;

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
        extensions = with pkgs.nur.repos.rycee.firefox-addons; [
          bitwarden
          consent-o-matic
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
          "Ecosia".metaData.hidden = true;
        };

        userChrome = # CSS
          ''
            /* hide empty tab notifications (e.g. translation) */
            #tab-notification-deck notification:empty {
              display: none !important;
            }

            /* chat sidebar */
            #main-window:has(
              #sidebar-box[sidebarcommand="viewGenaiChatSidebar"]:not([hidden="true"])
            ) {
              #sidebar-header {
                display: none !important;;
              }

              #sidebar-box:not([userresizable="true"]) {
                width: 750px !important;
              }
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

              #sidebar-box:not([userresizable="true"]) {
                width: 220px !important;
              }

              /** change style of sidebar splitter:
               * - same dark border as top navigator toolbox
               * - dragging hit box should stay the same
               */
              #sidebar-splitter {
                width: 6px !important;
                margin-right: -5px !important;
                z-index: 4 !important;
                background: transparent !important;
                border: none !important;
                border-left: 1px solid var(--chrome-content-separator-color) !important;
              }

              /** Don't show top right search input.
               * Used with focusSideberySearch function.
               */
              #customizationui-widget-panel[viewId*="${sideberyId}"] {
                display: none !important;
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

            @-moz-document domain(github.com) {
              /* fix double click in files not working reliably */
              .code-navigation-cursor {
                pointer-events: none;
              }
            }
          '';
      };

      nativeMessagingHosts =
        [ pkgs.local.ff2mpv-native-client pkgs.plasma-browser-integration ];
    };
  };
}
