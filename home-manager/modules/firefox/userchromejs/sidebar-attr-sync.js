// Mirror #sidebar-box[sidebarcommand] onto the inner sidebar document
// (webext-panels.xhtml) so userChrome.css can target per-extension panels.
(() => {
  const doc = bWindow.document;
  const box = doc.getElementById("sidebar-box");
  const browser = doc.getElementById("sidebar");
  if (!box || !browser) {
    return;
  }

  const sync = () => {
    const inner = browser.contentDocument?.documentElement;
    if (!inner) {
      return;
    }
    inner.setAttribute("sidebarcommand", box.getAttribute("sidebarcommand") ?? "");
  };

  // switching panels (same document is reused for extension → extension)
  new bWindow.MutationObserver(sync).observe(box, {
    attributes: true,
    attributeFilter: ["sidebarcommand"],
  });
  // new inner document loaded (built-in panel → extension panel)
  browser.addEventListener("load", sync, true);
  doc.addEventListener("SidebarShown", sync);
  // sidebar already open before the loader's 100 ms delay
  sync();
})();
