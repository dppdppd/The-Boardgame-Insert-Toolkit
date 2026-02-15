const { app, BrowserWindow, ipcMain, dialog } = require("electron");
const path = require("path");
const fs = require("fs");
const { importScad } = require("./importer");

let mainWindow;

// Bundled libs live next to the main lib file (project root)
const PROJECT_ROOT = path.resolve(__dirname, "..");
const BUNDLED_LIBS = [
  "boardgame_insert_toolkit_lib.4.scad",
  "bit_functions_lib.4.scad",
];

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

// --- Helpers ---

function atomicWrite(filePath, content) {
  const tmp = filePath + ".tmp";
  fs.writeFileSync(tmp, content, "utf-8");
  fs.renameSync(tmp, filePath);
}

function copyLibs(destDir) {
  const libDir = path.join(destDir, "lib");
  fs.mkdirSync(libDir, { recursive: true });
  for (const lib of BUNDLED_LIBS) {
    const src = path.join(PROJECT_ROOT, lib);
    const dst = path.join(libDir, lib);
    if (fs.existsSync(src)) {
      fs.copyFileSync(src, dst);
    }
  }
}

function computeChecksum(filePath) {
  const crypto = require("crypto");
  const content = fs.readFileSync(filePath);
  return "sha256:" + crypto.createHash("sha256").update(content).digest("hex");
}

function getLibChecksums(projectDir) {
  const checksums = {};
  const libDir = path.join(projectDir, "lib");
  for (const lib of BUNDLED_LIBS) {
    const p = path.join(libDir, lib);
    if (fs.existsSync(p)) {
      checksums[lib] = computeChecksum(p);
    }
  }
  return checksums;
}

function getBundledChecksums() {
  const checksums = {};
  for (const lib of BUNDLED_LIBS) {
    const p = path.join(PROJECT_ROOT, lib);
    if (fs.existsSync(p)) {
      checksums[lib] = computeChecksum(p);
    }
  }
  return checksums;
}

// --- IPC Handlers ---

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

ipcMain.handle("new-project", async (_event, dirPath) => {
  try {
    fs.mkdirSync(dirPath, { recursive: true });
    copyLibs(dirPath);
    const checksums = getLibChecksums(dirPath);
    return { ok: true, checksums };
  } catch (err) {
    return { ok: false, error: err.message };
  }
});

ipcMain.handle("check-lib-staleness", async (_event, projectDir) => {
  try {
    const projectChecksums = getLibChecksums(projectDir);
    const bundledChecksums = getBundledChecksums();
    const stale = [];
    for (const lib of BUNDLED_LIBS) {
      if (projectChecksums[lib] && bundledChecksums[lib] &&
          projectChecksums[lib] !== bundledChecksums[lib]) {
        stale.push(lib);
      }
      if (!projectChecksums[lib] && bundledChecksums[lib]) {
        stale.push(lib);
      }
    }
    return { ok: true, stale, bundledChecksums };
  } catch (err) {
    return { ok: false, error: err.message };
  }
});

ipcMain.handle("update-libs", async (_event, projectDir) => {
  try {
    // Backup old libs
    const libDir = path.join(projectDir, "lib");
    const backupDir = path.join(libDir, "_old", new Date().toISOString().replace(/[:.]/g, "-"));
    fs.mkdirSync(backupDir, { recursive: true });
    for (const lib of BUNDLED_LIBS) {
      const p = path.join(libDir, lib);
      if (fs.existsSync(p)) {
        fs.copyFileSync(p, path.join(backupDir, lib));
      }
    }
    // Copy new libs
    copyLibs(projectDir);
    const checksums = getLibChecksums(projectDir);
    return { ok: true, checksums };
  } catch (err) {
    return { ok: false, error: err.message };
  }
});

ipcMain.handle("import-scad", async (_event, filePath) => {
  try {
    const content = fs.readFileSync(filePath, "utf-8");
    const project = importScad(content);
    return { ok: true, data: project };
  } catch (err) {
    return { ok: false, error: err.message };
  }
});

ipcMain.handle("show-import-dialog", async () => {
  const result = await dialog.showOpenDialog(mainWindow, {
    title: "Import SCAD File",
    filters: [{ name: "OpenSCAD", extensions: ["scad"] }],
    properties: ["openFile"],
  });
  if (result.canceled) return { ok: false };
  return { ok: true, filePath: result.filePaths[0] };
});

ipcMain.handle("open-in-openscad", async (_event, projectDir) => {
  const { exec } = require("child_process");
  const scadFile = path.join(projectDir, "design.scad");
  if (!fs.existsSync(scadFile)) {
    return { ok: false, error: "design.scad not found" };
  }
  // Try common OpenSCAD locations
  const candidates = process.platform === "win32"
    ? [
        "C:\\Program Files\\OpenSCAD\\openscad.exe",
        "C:\\Program Files (x86)\\OpenSCAD\\openscad.exe",
        "openscad",
      ]
    : [
        "/usr/bin/openscad",
        "/usr/local/bin/openscad",
        "/snap/bin/openscad",
        "/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD",
        "openscad",
      ];

  let cmd = null;
  for (const c of candidates) {
    try {
      if (c.includes("/") || c.includes("\\")) {
        if (fs.existsSync(c)) { cmd = c; break; }
      } else {
        cmd = c; break; // bare command — let PATH resolve it
      }
    } catch {}
  }

  if (!cmd) return { ok: false, error: "OpenSCAD not found" };

  try {
    exec(`"${cmd}" "${scadFile}"`);
    return { ok: true };
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
