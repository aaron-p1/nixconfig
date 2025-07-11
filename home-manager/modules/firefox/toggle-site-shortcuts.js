// comment first line to fix inserting into main js
(() => {
  /* —--- Settings —------------------------------------------ */
  const TOGGLE_KEY = "j"; // key that flips the permission
  const CTRL = true; // whether to require Ctrl key (true/false)
  const PREF = "permissions.default.shortcuts";
  const ICON_ID = "site-shortcuts-icon"; // element ID for the indicator
  // "chrome://browser/skin/quickactions.svg"; // or any 16×16 SVG

  /* —--- Helper: create / remove the indicator icon —---------- */
  function showIcon() {
    let icon = win.document.getElementById(ICON_ID);
    if (icon) {
      icon.hidden = false;
      return;
    }

    icon = win.document.createXULElement("image");
    icon.id = ICON_ID;
    icon.setAttribute(
      "tooltiptext",
      "This site is allowed to override browser shortcuts (ctrl+j to toggle)",
    );

    /* Insert immediately to the right of the URL field but before built-in buttons */
    const iconsBox = win.document.getElementById("identity-box");
    iconsBox.appendChild(icon);
  }

  function hideIcon() {
    const icon = win.document.getElementById(ICON_ID);
    if (icon) icon.remove();
  }

  /* —--- Pref logic —----------------------------------- */
  function isAllowed() {
    return Services.prefs.getIntPref(PREF, 2) === 1;
  }

  function allow() {
    Services.prefs.setIntPref(PREF, 1);
  }

  function block() {
    Services.prefs.setIntPref(PREF, 2);
  }

  function togglePermission() {
    isAllowed() ? block() : allow();
    updateUI();
  }

  /* —--- UI sync —-------------------------------------------- */
  function updateUI() {
    isAllowed() ? showIcon() : hideIcon();
  }

  /* —--- Global key listener (capture phase) —--------------- */
  win.document.addEventListener(
    "keydown",
    (evt) => {
      if (
        evt.key === TOGGLE_KEY &&
        evt.ctrlKey === CTRL &&
        !evt.altKey &&
        !evt.shiftKey &&
        !evt.metaKey
      ) {
        evt.preventDefault();
        evt.stopPropagation();
        togglePermission();
      }
    },
    true,
  );

  /* —--- Keep indicator correct on navigation / tab switch —-- */
  win.gBrowser.tabContainer.addEventListener("TabSelect", () => {
    block();
    updateUI();
  });

  const progressListener = {
    onLocationChange() {
      if (flags & Ci.nsIWebProgressListener.LOCATION_CHANGE_SAME_DOCUMENT)
        return; // ignore history.pushState, #fragment, etc.
      // new real document → reset
      block();
      updateUI();
    },
    QueryInterface: ChromeUtils.generateQI(["nsIWebProgressListener"]),
  };
  win.gBrowser.addProgressListener(progressListener);

  updateUI();
})();
