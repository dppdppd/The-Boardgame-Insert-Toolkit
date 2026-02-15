const { contextBridge, ipcRenderer } = require("electron");

contextBridge.exposeInMainWorld("bitgui", {
  platform: process.platform,
  harness: !!process.env.BITGUI_HARNESS,

  // File I/O
  saveProject: (dirPath, projectJson, scadText) =>
    ipcRenderer.invoke("save-project", dirPath, projectJson, scadText),

  loadProject: (filePath) =>
    ipcRenderer.invoke("load-project", filePath),

  // Dialogs
  showOpenDialog: () =>
    ipcRenderer.invoke("show-open-dialog"),

  showSaveDialog: () =>
    ipcRenderer.invoke("show-save-dialog"),
});
