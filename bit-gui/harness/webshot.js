#!/usr/bin/env node
// Headless screenshot generator for BIT GUI (no X server required).
//
// Usage:
//   node bit-gui/harness/webshot.js <scad-file> <out-png> [scrollY]

const fs = require("fs");
const path = require("path");
const { chromium } = require("playwright");

const { importScad } = require("../importer");

async function main() {
  const [, , scadPathArg, outPathArg, scrollYArg] = process.argv;
  if (!scadPathArg || !outPathArg) {
    console.error("Usage: node bit-gui/harness/webshot.js <scad-file> <out-png> [scrollY]");
    process.exit(2);
  }

  const scadPath = path.resolve(process.cwd(), scadPathArg);
  const outPath = path.resolve(process.cwd(), outPathArg);
  const scrollY = scrollYArg ? parseInt(scrollYArg, 10) : 0;

  const scadText = fs.readFileSync(scadPath, "utf-8");
  const project = importScad(scadText);

  const pending = { data: project, filePath: scadPath };

  const browser = await chromium.launch({ headless: true });
  const page = await browser.newPage({ viewport: { width: 1920, height: 1080 } });

  // Provide a minimal window.bitgui shim so the app can auto-load.
  await page.addInitScript((pendingLoad) => {
    let pending = pendingLoad;
    window.bitgui = {
      harness: false,
      platform: "webshot",
      getPendingLoad: async () => {
        const p = pending;
        pending = null;
        return p;
      },
      // Autosave calls saveFile(); stub it out.
      saveFile: async (filePath, _scadText, _needsBackup) => ({ ok: true, filePath }),
      saveFileAs: async () => ({ ok: false }),
      openFile: async () => ({ ok: false }),
      openInOpenScad: async () => ({ ok: true }),
      onMenuNew: () => {},
      onMenuOpen: () => {},
      onMenuSaveAs: () => {},
      onMenuOpenInOpenScad: () => {},
    };
  }, pending);

  const distIndex = path.resolve(__dirname, "..", "dist", "index.html");
  await page.goto("file://" + distIndex, { waitUntil: "domcontentloaded" });
  await page.waitForSelector('[data-testid="app-root"]', { timeout: 20000 });
  await page.waitForTimeout(300);

  if (scrollY > 0) {
    await page.evaluate((y) => window.scrollTo(0, y), scrollY);
    await page.waitForTimeout(150);
  }

  fs.mkdirSync(path.dirname(outPath), { recursive: true });
  await page.screenshot({ path: outPath });

  await browser.close();
  console.log(outPath);
}

main().catch((err) => {
  console.error("Fatal:", err);
  process.exit(1);
});
