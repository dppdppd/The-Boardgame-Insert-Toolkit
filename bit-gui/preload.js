const { contextBridge } = require("electron");

contextBridge.exposeInMainWorld("bitgui", {
  platform: process.platform,
  harness: !!process.env.BITGUI_HARNESS,
});
