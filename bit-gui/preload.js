const { contextBridge, ipcRenderer } = require("electron");

contextBridge.exposeInMainWorld("bitgui", {
  getPendingLoad: () => ipcRenderer.invoke("get-pending-load"),
  platform: process.platform,
  harness: !!process.env.BITGUI_HARNESS,

  setTitle: (title) => ipcRenderer.send("set-title", title),
  openFile: () => ipcRenderer.invoke("open-file"),
  saveFile: (filePath, scadText, needsBackup) => ipcRenderer.invoke("save-file", filePath, scadText, needsBackup),
  saveFileAs: (scadText) => ipcRenderer.invoke("save-file-as", scadText),
  openInOpenScad: (filePath) => ipcRenderer.invoke("open-in-openscad", filePath),

  // Menu event listeners
  onMenuNew: (callback) => ipcRenderer.on("menu-new", callback),
  onMenuOpen: (callback) => ipcRenderer.on("menu-open", (_event, data) => callback(data)),
  onMenuSaveAs: (callback) => ipcRenderer.on("menu-save-as", callback),
  onMenuOpenInOpenScad: (callback) => ipcRenderer.on("menu-open-in-openscad", callback),
  onMenuToggleHideDefaults: (callback) => ipcRenderer.on("menu-toggle-hide-defaults", (_event, checked) => callback(checked)),
});
