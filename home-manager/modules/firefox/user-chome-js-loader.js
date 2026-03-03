// Based on:
// https://www.userchrome.org/what-is-userchrome-js.html#combinedloader
/* Single function userChrome.js loader to run the above init function (no external scripts)
  derived from https://www.reddit.com/r/firefox/comments/kilmm2/ */
const { Services } = globalThis;
const regex =
  /^(chrome:(?!\/\/(global\/content\/commonDialog|browser\/content\/webext-panels)\.x?html)|about:(?!blank))/i;

class ConfigJS {
  constructor() {
    Services.obs.addObserver(this, "domwindowopened", false);
  }

  observe(aSubject) {
    aSubject.console.log(
      "ConfigJS: DOM Window opened:",
      aSubject.location.href,
    );

    if (aSubject.document.isUncommittedInitialDocument) {
      aSubject.addEventListener(
        "DOMContentLoaded",
        () =>
          aSubject.parent.addEventListener(
            "DOMContentLoaded",
            this.handleEvent.bind(this),
            { once: true },
          ),
        { once: true },
      );
    } else {
      aSubject.console.log(
        "ConfigJS: Document is already loaded:",
        aSubject.location.href,
      );
    }
  }

  async handleEvent(aEvent) {
    const document = aEvent.originalTarget;
    const window = document.defaultView;
    const location = window.location;

    window.console.log("ConfigJS: Current URL:", location.href);

    if (regex.test(location.href)) {
      // wait for 100 ms
      await new Promise((resolve) => window.setTimeout(resolve, 100));

      window.console.log(
        "ConfigJS: URL matches regex, running in window:",
        location.href,
      );
      if (window.gBrowser) {
        window.console.log("ConfigJS: Found gBrowser, running in window");
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
