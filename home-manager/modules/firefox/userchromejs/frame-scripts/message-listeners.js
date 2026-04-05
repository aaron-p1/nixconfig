const Cc = Components.classes;
const Ci = Components.interfaces;

addMessageListener("sendTrustedKey", ({ data: { keyOptions, opts } }) => {
  const win = Services.focus.focusedWindow ?? content;
  const tip = Cc["@mozilla.org/text-input-processor;1"].createInstance(
    Ci.nsITextInputProcessor,
  );

  const handler = {
    onNotify(_tip, _notification) {
      return true;
    },
  };

  const ok = tip.beginInputTransaction(win, handler);
  if (!ok) {
    win.console.error(
      "ConfigJS: TIP transaction not acquired — another TIP holds it",
    );
    return;
  }

  const ev = new win.KeyboardEvent("", { ...keyOptions, view: win });

  const try_event = (fn) => {
    try {
      tip[fn](ev);
    } catch (e) {
      if (e.result !== 0x80040111) throw e;
    }
  };

  if (!opts) {
    try_event("keydown");
    try_event("keyup");
  }

  if (opts?.down) {
    try_event("keydown");
  }
  if (opts?.up) {
    try_event("keyup");
  }
});
