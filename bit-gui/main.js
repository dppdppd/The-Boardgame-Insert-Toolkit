const { app, BrowserWindow, ipcMain, dialog } = require("electron");
const path = require("path");
const fs = require("fs");
const { importScad } = require("./importer");

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

  // Auto-load file from env or CLI arg
  const autoLoad = process.env.BITGUI_OPEN || process.argv.find(a => a.endsWith(".scad"));
  if (autoLoad) {
    try {
      console.log("Auto-loading:", autoLoad);
      const content = fs.readFileSync(autoLoad, "utf-8");
      const proj = importScad(content);
      console.log("Parsed", proj.data.length, "elements");
      pendingLoad = { data: proj, filePath: autoLoad };
    } catch (err) {
      console.error("Auto-load failed:", err.message);
    }
  }
}

// --- Helpers ---

function atomicWrite(filePath, content) {
  const tmp = filePath + ".tmp";
  fs.writeFileSync(tmp, content, "utf-8");
  fs.renameSync(tmp, filePath);
}

// --- Auto-load state ---
let pendingLoad = null;

ipcMain.handle("get-pending-load", () => {
  const p = pendingLoad;
  pendingLoad = null;
  return p;
});

// --- IPC Handlers ---

ipcMain.handle("open-file", async () => {
  const result = await dialog.showOpenDialog(mainWindow, {
    title: "Open SCAD File",
    filters: [{ name: "OpenSCAD", extensions: ["scad"] }],
    properties: ["openFile"],
  });
  if (result.canceled) return { ok: false };
  try {
    const filePath = result.filePaths[0];
    const content = fs.readFileSync(filePath, "utf-8");
    const project = importScad(content);
    return { ok: true, filePath, data: project };
  } catch (err) {
    return { ok: false, error: err.message };
  }
});

ipcMain.handle("save-file", async (_event, filePath, scadText, needsBackup) => {
  try {
    if (needsBackup && fs.existsSync(filePath)) {
      const bakPath = filePath + ".bak";
      if (!fs.existsSync(bakPath)) {
        fs.copyFileSync(filePath, bakPath);
      }
    }
    atomicWrite(filePath, scadText);
    return { ok: true };
  } catch (err) {
    return { ok: false, error: err.message };
  }
});

ipcMain.handle("save-file-as", async (_event, scadText) => {
  const result = await dialog.showSaveDialog(mainWindow, {
    title: "Save SCAD File",
    filters: [{ name: "OpenSCAD", extensions: ["scad"] }],
    defaultPath: "design.scad",
  });
  if (result.canceled) return { ok: false };
  try {
    atomicWrite(result.filePath, scadText);
    return { ok: true, filePath: result.filePath };
  } catch (err) {
    return { ok: false, error: err.message };
  }
});

ipcMain.handle("open-in-openscad", async (_event, filePath) => {
  const { exec } = require("child_process");
  if (!fs.existsSync(filePath)) {
    return { ok: false, error: "File not found" };
  }
  const candidates = process.platform === "win32"
    ? ["C:\\Program Files\\OpenSCAD\\openscad.exe", "openscad"]
    : ["/usr/bin/openscad", "/usr/local/bin/openscad", "/snap/bin/openscad",
       "/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD", "openscad"];

  let cmd = null;
  for (const c of candidates) {
    if (c.includes("/") || c.includes("\\")) {
      if (fs.existsSync(c)) { cmd = c; break; }
    } else { cmd = c; break; }
  }
  if (!cmd) return { ok: false, error: "OpenSCAD not found" };

  try {
    exec(`"${cmd}" "${filePath}"`);
    return { ok: true };
  } catch (err) {
    return { ok: false, error: err.message };
  }
});

app.whenReady().then(createWindow);
app.on("window-all-closed", () => app.quit());
