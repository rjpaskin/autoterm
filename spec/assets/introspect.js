function run(ARGV) {
  var systemEvents = Application("System Events");

  function rubyify(key) {
    return key.replace(/([a-z\d])([A-Z]+)/g, "$1_$2")
      .toLowerCase().replace(/^is_(.+)/, "$1?");
  }

  function serialize(object, attributes) {
    return attributes.reduce(function(acc, attribute) {
      acc[rubyify(attribute)] = object[attribute]();

      return acc;
    }, {});
  }

  function serializeWindow(win, isCurrent) {
    var output = serialize(win, [
      "id", "alternateIdentifier", "index", "name", "bounds", "frontmost"
    ]);

    return Object.assign(output, {
      "current?": isCurrent,
      current_tab: "tab-" + win.currentTab().index(),
      tabs: win.tabs().map(function(tab) { return "tab-" + tab.index() })
    });
  }

  function serializeTab(tab, winId, isCurrent) {
    return {
      id: "tab-" + tab.index(),
      index: tab.index(),
      "current?": isCurrent,
      window: winId,
      sessions: tab.sessions().map(function(session) { return session.id() })
    }
  }

  function serializeSession(session, winId, tabId, isCurrent) {
    var output = serialize(session, [
      "id", "name", "isProcessing", "columns", "rows",
      "contents", "tty", "uniqueID", "profileName"
    ]);

    return Object.assign(output, {
      is_current: isCurrent,
      window: winId,
      tab: tabId,
    });
  }

  var app = Application("iTerm");

  var windows  = [],
      tabs     = [],
      sessions = [];

  var currentWindow = app.currentWindow();
  var currentWindowId = currentWindow && currentWindow.id();

  app.windows().forEach(function(win) {
    windows.push(serializeWindow(win, win.id() === currentWindowId));

    var currentTab = win.currentTab();

    win.tabs().forEach(function(tab) {
      tabs.push(serializeTab(tab, win.id(), tab.index() === currentTab.index()));

      var currentSession = tab.currentSession();

      tab.sessions().forEach(function(session) {
        sessions.push(serializeSession(session, win.id(), "tab-" + tab.index(), session.id() === currentSession.id()));
      });
    });
  });

  return JSON.stringify({
    windows: windows,
    tabs: tabs,
    sessions: sessions,
  });
}
