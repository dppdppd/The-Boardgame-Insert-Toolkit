const { contextBridge, ipcRenderer } = require("electron");

contextBridge.exposeInMainWorld("bgsd", {
  getPendingLoad: () => ipcRenderer.invoke("get-pending-load"),
  platform: process.platform,
  harness: !!process.env.BGSD_HARNESS,

  setTitle: (title) => ipcRenderer.send("set-title", title),
  openFile: () => ipcRenderer.invoke("open-file"),
  saveFile: (filePath, scadText, needsBackup, profileId) => ipcRenderer.invoke("save-file", filePath, scadText, needsBackup, profileId),
  saveFileAs: (scadText, profileId) => ipcRenderer.invoke("save-file-as", scadText, profileId),
  openInOpenScad: (filePath, profileId) => ipcRenderer.invoke("open-in-openscad", filePath, profileId),

  // Menu event listeners
  onMenuNew: (callback) => ipcRenderer.on("menu-new", callback),
  onMenuOpen: (callback) => ipcRenderer.on("menu-open", (_event, data) => callback(data)),
  onMenuSaveAs: (callback) => ipcRenderer.on("menu-save-as", callback),
  onMenuOpenInOpenScad: (callback) => ipcRenderer.on("menu-open-in-openscad", callback),
  onMenuToggleHideDefaults: (callback) => ipcRenderer.on("menu-toggle-hide-defaults", (_event, checked) => callback(checked)),
  onMenuToggleShowScad: (callback) => ipcRenderer.on("menu-toggle-show-scad", (_event, checked) => callback(checked)),
});
