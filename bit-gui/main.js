const { app, BrowserWindow, ipcMain, dialog, Menu } = require("electron");
const path = require("path");
const fs = require("fs");
const { importScad } = require("./importer");
const { ensureLibrary, copyLibToDir } = require("./lib/library-manager");

// Prevent GPU-related crashes on Windows (packaged exe doesn't get --disable-gpu)
app.disableHardwareAcceleration();
app.commandLine.appendSwitch("no-sandbox");

let mainWindow;

// --- Recent files ---
const RECENT_FILE = path.join(app.getPath("userData"), "recent-files.json");
const MAX_RECENT = 10;

function loadRecent() {
  try {
    if (fs.existsSync(RECENT_FILE)) return JSON.parse(fs.readFileSync(RECENT_FILE, "utf-8"));
  } catch (_) {}
  return [];
}

function saveRecent(list) {
  try { fs.writeFileSync(RECENT_FILE, JSON.stringify(list), "utf-8"); } catch (_) {}
}

function addRecent(filePath) {
  let list = loadRecent().filter(f => f !== filePath);
  list.unshift(filePath);
  if (list.length > MAX_RECENT) list = list.slice(0, MAX_RECENT);
  saveRecent(list);
  rebuildMenu();
}

function openFilePath(filePath) {
  try {
    const content = fs.readFileSync(filePath, "utf-8");
    const project = importScad(content);
    mainWindow.webContents.send("menu-open", { data: project, filePath });
    addRecent(filePath);
  } catch (err) {
    console.error("Open failed:", err.message);
  }
}

function rebuildMenu() {
  const recentFiles = loadRecent();
  const recentSubmenu = recentFiles.length > 0
    ? [
        ...recentFiles.map(f => ({
          label: path.basename(f),
          sublabel: f,
          click: () => openFilePath(f),
        })),
        { type: "separator" },
        { label: "Clear Recent", click: () => { saveRecent([]); rebuildMenu(); } },
      ]
    : [{ label: "No Recent Files", enabled: false }];

  const menuTemplate = [
    {
      label: "File",
      submenu: [
        {
          label: "New",
          accelerator: "CmdOrCtrl+N",
          click: () => mainWindow.webContents.send("menu-new"),
        },
        {
          label: "Open...",
          accelerator: "CmdOrCtrl+O",
          click: async () => {
            const result = await dialog.showOpenDialog(mainWindow, {
              title: "Open SCAD File",
              filters: [{ name: "OpenSCAD", extensions: ["scad"] }],
              properties: ["openFile"],
            });
            if (!result.canceled) openFilePath(result.filePaths[0]);
          },
        },
        {
          label: "Open Recent",
          submenu: recentSubmenu,
        },
        {
          label: "Save As...",
          accelerator: "CmdOrCtrl+Shift+S",
          click: () => mainWindow.webContents.send("menu-save-as"),
        },
        { type: "separator" },
        { role: "quit" },
      ],
    },
    {
      label: "View",
      submenu: [
        {
          id: "hide-defaults",
          label: "Hide Defaults",
          type: "checkbox",
          checked: false,
          click: (menuItem) => mainWindow.webContents.send("menu-toggle-hide-defaults", menuItem.checked),
        },
        {
          id: "show-scad",
          label: "Show SCAD",
          type: "checkbox",
          checked: false,
          accelerator: "CmdOrCtrl+U",
          click: (menuItem) => mainWindow.webContents.send("menu-toggle-show-scad", menuItem.checked),
        },
      ],
    },
    {
      label: "Tools",
      submenu: [
        {
          label: "Open in OpenSCAD",
          accelerator: "CmdOrCtrl+E",
          click: () => mainWindow.webContents.send("menu-open-in-openscad"),
        },
      ],
    },
  ];
  const menu = Menu.buildFromTemplate(menuTemplate);
  Menu.setApplicationMenu(menu);
}

function createWindow() {
  const width = parseInt(process.env.BGSD_WINDOW_WIDTH || "1000", 10);
  const height = parseInt(process.env.BGSD_WINDOW_HEIGHT || "1200", 10);

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

  rebuildMenu();

  // Auto-load file from env or CLI arg
  const autoLoad = process.env.BGSD_OPEN || process.argv.find(a => a.endsWith(".scad"));
  if (autoLoad) {
    try {
      console.log("Auto-loading:", autoLoad);
      const content = fs.readFileSync(autoLoad, "utf-8");
      const proj = importScad(content);
      console.log("Parsed", proj.lines.length, "lines");
      pendingLoad = { data: proj, filePath: autoLoad };
      addRecent(autoLoad);
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

ipcMain.on("set-title", (_event, title) => {
  if (mainWindow) mainWindow.setTitle(title);
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
    addRecent(filePath);
    return { ok: true, filePath, data: project };
  } catch (err) {
    return { ok: false, error: err.message };
  }
});

ipcMain.handle("save-file", async (_event, filePath, scadText, needsBackup, profileId) => {
  try {
    if (needsBackup && fs.existsSync(filePath)) {
      const bakPath = filePath + ".bak";
      if (!fs.existsSync(bakPath)) {
        fs.copyFileSync(filePath, bakPath);
      }
    }
    atomicWrite(filePath, scadText);
    // Copy library files next to saved .scad so OpenSCAD includes resolve
    if (profileId) {
      try { await copyLibToDir(profileId, path.dirname(filePath)); } catch (e) {
        console.warn("Library copy failed (non-fatal):", e.message);
      }
    }
    return { ok: true, filePath };
  } catch (err) {
    return { ok: false, error: err.message };
  }
});

ipcMain.handle("save-file-as", async (_event, scadText, profileId) => {
  const result = await dialog.showSaveDialog(mainWindow, {
    title: "Save SCAD File",
    filters: [{ name: "OpenSCAD", extensions: ["scad"] }],
    defaultPath: "design.scad",
  });
  if (result.canceled) return { ok: false };
  try {
    atomicWrite(result.filePath, scadText);
    if (profileId) {
      try { await copyLibToDir(profileId, path.dirname(result.filePath)); } catch (e) {
        console.warn("Library copy failed (non-fatal):", e.message);
      }
    }
    return { ok: true, filePath: result.filePath };
  } catch (err) {
    return { ok: false, error: err.message };
  }
});

ipcMain.handle("open-in-openscad", async (_event, filePath, profileId) => {
  const { spawn } = require("child_process");
  if (!filePath || !fs.existsSync(filePath)) {
    return { ok: false, error: `File not found: ${filePath || "(no path)"}` };
  }

  // Ensure library files are next to the .scad before launching OpenSCAD
  if (profileId) {
    try { await copyLibToDir(profileId, path.dirname(filePath)); } catch (e) {
      console.warn("Library copy failed (non-fatal):", e.message);
    }
  }

  if (process.platform === "win32") {
    // On Windows, use 'start' to open via file association, or try known paths.
    const candidates = [
      "C:\\Program Files\\OpenSCAD\\openscad.exe",
      "C:\\Program Files (x86)\\OpenSCAD\\openscad.exe",
      "C:\\Program Files\\OpenSCAD (Nightly)\\openscad.exe",
    ];
    let cmd = candidates.find(c => fs.existsSync(c));
    if (cmd) {
      spawn(cmd, [filePath], { detached: true, stdio: "ignore" }).unref();
    } else {
      // Fallback: use 'start' to open with default .scad handler
      spawn("cmd", ["/c", "start", "", filePath], { detached: true, stdio: "ignore" }).unref();
    }
    return { ok: true };
  }

  // macOS / Linux
  const candidates = process.platform === "darwin"
    ? ["/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD", "openscad"]
    : ["/usr/bin/openscad", "/usr/local/bin/openscad", "/snap/bin/openscad", "openscad"];

  let cmd = null;
  for (const c of candidates) {
    if (c.includes("/")) {
      if (fs.existsSync(c)) { cmd = c; break; }
    } else { cmd = c; break; }
  }
  if (!cmd) return { ok: false, error: "OpenSCAD not found" };

  try {
    spawn(cmd, [filePath], { detached: true, stdio: "ignore" }).unref();
    return { ok: true };
  } catch (err) {
    return { ok: false, error: err.message };
  }
});

app.whenReady().then(createWindow);
app.on("window-all-closed", () => app.quit());

// Surface errors as a dialog instead of a silent crash
process.on("uncaughtException", (err) => {
  console.error("Uncaught exception:", err);
  try { dialog.showErrorBox("BGSD Error", err.stack || err.message); } catch (_) {}
  app.exit(1);
});
