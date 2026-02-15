const { app, BrowserWindow, ipcMain, dialog } = require("electron");
const path = require("path");
const fs = require("fs");

let mainWindow;

function createWindow() {
  const width = parseInt(process.env.BITGUI_WINDOW_WIDTH || "800", 10);
  const height = parseInt(process.env.BITGUI_WINDOW_HEIGHT || "600", 10);

  mainWindow = new BrowserWindow({
    width,
    height,
    webPreferences: {
      nodeIntegration: false,
      contextIsolation: true,
      preload: path.join(__dirname, "preload.js"),
    },
  });

  mainWindow.loadFile(path.join(__dirname, "dist", "index.html"));
}

// --- IPC Handlers ---

// Atomic write: write to .tmp then rename
function atomicWrite(filePath, content) {
  const tmp = filePath + ".tmp";
  fs.writeFileSync(tmp, content, "utf-8");
  fs.renameSync(tmp, filePath);
}

ipcMain.handle("save-project", async (_event, dirPath, projectJson, scadText) => {
  try {
    fs.mkdirSync(dirPath, { recursive: true });
    atomicWrite(path.join(dirPath, "project.bitgui.json"), projectJson);
    atomicWrite(path.join(dirPath, "design.scad"), scadText);
    return { ok: true };
  } catch (err) {
    return { ok: false, error: err.message };
  }
});

ipcMain.handle("load-project", async (_event, filePath) => {
  try {
    const content = fs.readFileSync(filePath, "utf-8");
    return { ok: true, data: JSON.parse(content) };
  } catch (err) {
    return { ok: false, error: err.message };
  }
});

ipcMain.handle("show-open-dialog", async () => {
  const result = await dialog.showOpenDialog(mainWindow, {
    title: "Open BIT Project",
    filters: [{ name: "BIT Project", extensions: ["bitgui.json"] }],
    properties: ["openFile"],
  });
  if (result.canceled) return { ok: false };
  return { ok: true, filePath: result.filePaths[0] };
});

ipcMain.handle("show-save-dialog", async () => {
  const result = await dialog.showOpenDialog(mainWindow, {
    title: "Choose Project Folder",
    properties: ["openDirectory", "createDirectory"],
  });
  if (result.canceled) return { ok: false };
  return { ok: true, dirPath: result.filePaths[0] };
});

app.whenReady().then(createWindow);

app.on("window-all-closed", () => {
  app.quit();
});
