// Based on:
// https://www.userchrome.org/what-is-userchrome-js.html#combinedloader
/* Single function userChrome.js loader to run the above init function (no external scripts)
  derived from https://www.reddit.com/r/firefox/comments/kilmm2/ */
const { Services } = globalThis;
const regex =
  /^(chrome:(?!\/\/(global\/content\/commonDialog|browser\/content\/webext-panels)\.x?html)|about:(?!blank))/i;

class ConfigJS {
  constructor() {
    Services.obs.addObserver(this, "chrome-document-global-created", false);
  }

  observe(aSubject) {
    aSubject.addEventListener("DOMContentLoaded", this.handleEvent.bind(this), {
      once: true,
    });
  }

  handleEvent(aEvent) {
    const document = aEvent.originalTarget;
    const window = document.defaultView;
    const location = window.location;

    if (regex.test(location.href)) {
      if (window._gBrowser) {
        runInWindow(window);
      }
    }
  }
}

try {
  if (!Services.appinfo.inSafeMode) {
    new ConfigJS();
  }
} catch (ex) {
  console.error("Failed to initialize ConfigJS:", ex);
}
