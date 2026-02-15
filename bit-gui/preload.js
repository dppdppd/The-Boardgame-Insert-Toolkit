const { contextBridge, ipcRenderer } = require("electron");

contextBridge.exposeInMainWorld("bitgui", {
  platform: process.platform,
  harness: !!process.env.BITGUI_HARNESS,

  // File I/O
  saveProject: (dirPath, projectJson, scadText) =>
    ipcRenderer.invoke("save-project", dirPath, projectJson, scadText),
  loadProject: (filePath) =>
    ipcRenderer.invoke("load-project", filePath),
  newProject: (dirPath) =>
    ipcRenderer.invoke("new-project", dirPath),

  // Lib management
  checkLibStaleness: (projectDir) =>
    ipcRenderer.invoke("check-lib-staleness", projectDir),
  updateLibs: (projectDir) =>
    ipcRenderer.invoke("update-libs", projectDir),

  // Import
  importScad: (filePath) =>
    ipcRenderer.invoke("import-scad", filePath),

  // OpenSCAD
  openInOpenScad: (projectDir) =>
    ipcRenderer.invoke("open-in-openscad", projectDir),

  // Dialogs
  showOpenDialog: () =>
    ipcRenderer.invoke("show-open-dialog"),
  showSaveDialog: () =>
    ipcRenderer.invoke("show-save-dialog"),
  showImportDialog: () =>
    ipcRenderer.invoke("show-import-dialog"),
});
