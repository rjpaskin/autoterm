var systemEvents = Application("System Events");

if (systemEvents.applicationProcesses.byName("iTerm2").exists()) {
  Application("iTerm").quit();
}
