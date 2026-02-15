const { app, BrowserWindow } = require("electron");
const path = require("path");

let mainWindow;

function createWindow() {
  const width = parseInt(process.env.BITGUI_WINDOW_WIDTH || "1200", 10);
  const height = parseInt(process.env.BITGUI_WINDOW_HEIGHT || "900", 10);

  mainWindow = new BrowserWindow({
    width,
    height,
    webPreferences: {
      nodeIntegration: false,
      contextIsolation: true,
      preload: path.join(__dirname, "preload.js"),
    },
  });

  // Load the built frontend
  mainWindow.loadFile(path.join(__dirname, "dist", "index.html"));
}

app.whenReady().then(createWindow);

app.on("window-all-closed", () => {
  app.quit();
});
