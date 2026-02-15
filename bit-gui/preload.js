const { contextBridge, ipcRenderer } = require("electron");

contextBridge.exposeInMainWorld("bitgui", {
  // File I/O will go here in Phase 2
  platform: process.platform,
});
