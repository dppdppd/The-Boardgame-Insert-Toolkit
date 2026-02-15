const { contextBridge, ipcRenderer } = require("electron");

contextBridge.exposeInMainWorld("bitgui", {
  getPendingLoad: () => ipcRenderer.invoke("get-pending-load"),
  platform: process.platform,
  harness: !!process.env.BITGUI_HARNESS,

  openFile: () => ipcRenderer.invoke("open-file"),
  saveFile: (filePath, scadText, needsBackup) => ipcRenderer.invoke("save-file", filePath, scadText, needsBackup),
  saveFileAs: (scadText) => ipcRenderer.invoke("save-file-as", scadText),
  openInOpenScad: (filePath) => ipcRenderer.invoke("open-in-openscad", filePath),
});
