const { AddonManager } = ChromeUtils.importESModule(
  "resource://gre/modules/AddonManager.sys.mjs"
);

function getElem(elem) {
  return bWindow.document.getElementById(elem);
}

function cloneAsKeyboardEventInit(e) {
  return {
    key: e.key,
    code: e.code,
    keyCode: e.keyCode,
    charCode: e.charCode,
    which: e.which,
    location: e.location,
    repeat: e.repeat,
    isComposing: e.isComposing,
    ctrlKey: e.ctrlKey,
    shiftKey: e.shiftKey,
    altKey: e.altKey,
    metaKey: e.metaKey,
    bubbles: e.bubbles,
    cancelable: e.cancelable,
    composed: e.composed,
  };
}

function resendKey(browser, event, opts) {
  browser.messageManager.sendAsyncMessage("sendTrustedKey", {
    keyOptions: cloneAsKeyboardEventInit(event),
    opts,
  });
}

function keyCombo(e) {
  const altGr = e.getModifierState("AltGraph");
  return [
    !altGr && e.ctrlKey && "CTRL", // suppress phantom ctrl from AltGr
    !altGr && e.altKey && "ALT",
    e.shiftKey && "SHIFT",
    e.metaKey && "META",
    altGr && "ALTGR",
    e.key,
  ]
    .filter(Boolean)
    .join("+");
}
