#!/usr/bin/env node
// BIT GUI Harness — Playwright-driven Electron REPL
// Usage: node harness/run.js

const { _electron: electron } = require("playwright");
const path = require("path");
const fs = require("fs");
const readline = require("readline");

const BIT_GUI = path.resolve(__dirname, "..");
const OUT_DIR = path.join(__dirname, "out");
fs.mkdirSync(OUT_DIR, { recursive: true });

let shotCounter = 0;
// Resume counter from existing files
try {
  const files = fs.readdirSync(OUT_DIR).filter((f) => /^\d{3}_/.test(f));
  if (files.length) {
    const nums = files.map((f) => parseInt(f.split("_")[0], 10));
    shotCounter = Math.max(...nums) + 1;
  }
} catch {}

let app, page;

async function screenshot(label) {
  const num = String(shotCounter++).padStart(3, "0");
  const fname = `${num}_${label || "shot"}.png`;
  const fpath = path.join(OUT_DIR, fname);
  await page.screenshot({ path: fpath });
  console.log(`  Screenshot: ${fname}`);
  return fname;
}

async function handleCommand(line) {
  const trimmed = line.trim();
  if (!trimmed) return;

  const parts = trimmed.match(/^(\S+)\s*(.*)/);
  if (!parts) return;
  const [, cmd, rest] = parts;

  try {
    switch (cmd) {
      case "shot":
        await screenshot(rest || "manual");
        break;

      case "click":
        await page.click(`[data-testid="${rest}"]`);
        console.log(`  Clicked: ${rest}`);
        await screenshot(`click_${rest}`);
        break;

      case "type": {
        const m = rest.match(/^(\S+)\s+"([^"]*)"/);
        if (!m) {
          console.log('  Usage: type <testid> "text"');
          break;
        }
        await page.fill(`[data-testid="${m[1]}"]`, m[2]);
        console.log(`  Typed "${m[2]}" into: ${m[1]}`);
        await screenshot(`type_${m[1]}`);
        break;
      }

      case "intent": {
        const text = rest.replace(/^"/, "").replace(/"$/, "");
        await page.fill('[data-testid="intent-text"]', text);
        await screenshot("intent");
        break;
      }

      case "act": {
        const m = rest.match(/^"([^"]*)"\s+(\S+)\s*(.*)/);
        if (!m) {
          console.log('  Usage: act "intent text" <command> <args>');
          break;
        }
        await page.fill('[data-testid="intent-text"]', m[1]);
        await handleCommand(`${m[2]} ${m[3]}`);
        break;
      }

      case "js": {
        const result = await page.evaluate(rest);
        console.log("  =>", JSON.stringify(result));
        break;
      }

      case "ipc": {
        // Send IPC message to renderer: ipc <channel> [json-args...]
        const m = rest.match(/^(\S+)\s*(.*)/);
        if (!m) { console.log("  Usage: ipc <channel> [json-args...]"); break; }
        const channel = m[1];
        const args = m[2] ? JSON.parse(m[2]) : undefined;
        await app.evaluate(({ BrowserWindow }, { channel, args }) => {
          const win = BrowserWindow.getAllWindows()[0];
          if (win) win.webContents.send(channel, args);
        }, { channel, args });
        await page.waitForTimeout(200); // let renderer process
        console.log(`  IPC: ${channel} ${m[2] || ""}`);
        break;
      }

      case "wait":
        await page.waitForSelector(`[data-testid="${rest}"]`, {
          timeout: 15000,
        });
        console.log(`  Found: ${rest}`);
        break;

      case "help":
        console.log(`
  Commands:
    shot <label>              Take screenshot
    click <testid>            Click element by data-testid
    type <testid> "text"      Fill element with text
    intent "text"             Set intent pane text + screenshot
    act "intent" cmd args     Set intent + execute + screenshot
    js <expression>           Evaluate JS in page
    ipc <channel> [json]      Send IPC to renderer
    wait <testid>             Wait for element
    help                      Show this help
    quit                      Exit
`);
        break;

      case "quit":
      case "exit":
      case "q":
        await app.close();
        process.exit(0);

      default:
        console.log(`  Unknown command: ${cmd}. Type 'help'.`);
    }
  } catch (err) {
    console.log(`  Error: ${err.message}`);
  }
}

async function main() {
  console.log("Launching Electron...");

  const width = parseInt(process.env.BITGUI_WINDOW_WIDTH || "1000", 10);
  const height = parseInt(process.env.BITGUI_WINDOW_HEIGHT || "1200", 10);

  app = await electron.launch({
    args: [path.join(BIT_GUI, "main.js"), "--disable-gpu", "--no-sandbox"],
    env: {
      ...process.env,
      BITGUI_WINDOW_WIDTH: String(width),
      BITGUI_WINDOW_HEIGHT: String(height),
      BITGUI_HARNESS: "1",
    },
  });

  page = await app.firstWindow();
  await page.waitForLoadState("domcontentloaded");
  await page.setViewportSize({ width, height });
  console.log(`Window title: ${await page.title()}`);

  // Initial screenshot
  await screenshot("initial");

  // Optional non-interactive script mode (useful in CI / tool-driven runs)
  // Provide either:
  // - BITGUI_HARNESS_SCRIPT=/path/to/commands.txt
  // - BITGUI_HARNESS_COMMANDS='cmd1\ncmd2\n...'
  const scriptPath = process.env.BITGUI_HARNESS_SCRIPT;
  const scriptInline = process.env.BITGUI_HARNESS_COMMANDS;
  if (scriptPath || scriptInline) {
    try {
      const script = scriptPath
        ? fs.readFileSync(scriptPath, "utf-8")
        : String(scriptInline || "");
      const cmds = script.split(/\r?\n/).map((s) => s.trim()).filter(Boolean);
      for (const cmd of cmds) {
        await handleCommand(cmd);
      }
    } catch (err) {
      console.error("Script failed:", err.message);
    }
    await app.close();
    process.exit(0);
  }

  const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout,
    prompt: "bit> ",
  });

  rl.prompt();
  rl.on("line", async (line) => {
    await handleCommand(line);
    rl.prompt();
  });
  rl.on("close", async () => {
    await app.close();
    process.exit(0);
  });
}

main().catch((err) => {
  console.error("Fatal:", err);
  process.exit(1);
});
