{
  lib,
  pkgs,
  # list of keyset element ids to remove
  nativeShortcutsRemoved ? [ ],
  # attrs of keyset element id to attrs of attribute to new value
  nativeShortcutChanges ? { },

  # attrs of key combo (CTRL+Key) to js
  # available variables:
  #   bWindow: browser window
  #   event: keydown event
  shortcuts ? { },

  # attrs of host to js snippet to run in website context
  # window is website window, but code may run in privileged context
  websiteInjections ? { },
}:
let
  inherit (builtins) readFile isAttrs;
  inherit (lib)
    pipe
    hasInfix
    concatStringsSep
    mapAttrsToList
    ;

  websiteInjectionFrameScript = pipe websiteInjections [
    (mapAttrsToList (
      host: injection: # javascript
      ''
        "${host}": function(window) {
          ${injection}
        }
      ''
    ))
    (
      props: # javascript
      ''
        const websiteInjections = {
          ${concatStringsSep ",\n" props}
        };

        const observer = {
          observe(subject, topic, data) {
            if (topic === "content-document-global-created") {
              const window = subject;
              websiteInjections[window.location.host]?.(window);
            }
          }
        };

        Services.obs.addObserver(observer, "content-document-global-created");

        addEventListener("unload", () => {
          Services.obs.removeObserver(observer, "content-document-global-created");
        });
      '')
  ];

  frameScriptPaths = [
    ./frame-scripts/message-listeners.js
    {
      name = "Website Injections";
      content = websiteInjectionFrameScript;
    }
  ];

  frameScriptRegistration = pipe frameScriptPaths [
    (map (
      script:
      if isAttrs script then
        script
      else
        {
          name = script;
          content = readFile script;
        }
    ))

    (map (
      { name, content }:
      if hasInfix "//" content then
        throw "Firefox userChrome.js: Comments are not allowed in frame scripts: " + name
      else
        content
    ))

    (map (
      content: # javascript
      ''
        Services.mm.loadFrameScript("data:,(" + function() {
          ${content}
        } + ")()", true);
      ''
    ))

    (concatStringsSep "\n")
  ];

  shortcutRegistration = pipe shortcuts [
    (mapAttrsToList (
      key: content: # javascript
      ''
        case "${key}":
          (function() {
            ${content}
          })();
          break;
      ''
    ))
    (
      cases: # javascript
      ''
        bWindow.document.addEventListener("keydown", event => {
          switch (keyCombo(event)) {
            ${concatStringsSep "\n" cases}
          }
        }, {capture: true});
      '')
  ];

  nativeShortcutsRemovedRegistration = pipe nativeShortcutsRemoved [
    (map (id: "getElem('${id}')?.remove();"))
    (concatStringsSep "\n")
  ];

  nativeShortcutsChangesRegistration = pipe nativeShortcutChanges [
    (mapAttrsToList (
      key: changes:
      pipe changes [
        (mapAttrsToList (attr: newValue: "key.setAttribute('${attr}', '${newValue}');"))
        (
          attrChanges: # javascript
          ''
            key = getElem('${key}');
            ${concatStringsSep "\n" attrChanges}
          '')
      ]
    ))
    (
      keyChanges: # javascript
      ''
        let key;
        ${concatStringsSep "\n" keyChanges}
      '')
  ];
in
# javascript
''
  // runs in browser window context. (bWindow is the browser window object)
  function runInWindow(bWindow){
    bWindow.console.log("---------------- Loading userChrome.js in " + bWindow.location + " ----------------");

    ${frameScriptRegistration}

    ${readFile ./utils.js}

    ${nativeShortcutsRemovedRegistration}
    ${nativeShortcutsChangesRegistration}

    ${shortcutRegistration}
    ${readFile ./toggle-site-shortcuts.js}

    bWindow.console.log("---------------- Loading userChrome.js finished ----------------");
  }

  ${readFile ./user-chome-js-loader.js}
''
