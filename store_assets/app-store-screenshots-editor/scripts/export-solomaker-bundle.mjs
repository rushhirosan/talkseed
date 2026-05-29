#!/usr/bin/env node
/**
 * Start the editor (if needed), run Export bundle, extract ja 6.5" JPEGs for Solomaker.
 *
 * Usage (from app-store-screenshots-editor/):
 *   node scripts/export-solomaker-bundle.mjs
 *
 * Output: ../solomaker/01-hero.jpg … 05-group-discussion.jpg (5 slides, ja, 1284×2778)
 */
import { spawn } from "node:child_process";
import fs from "node:fs/promises";
import http from "node:http";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { execFile } from "node:child_process";
import { promisify } from "node:util";

const execFileAsync = promisify(execFile);
const __dirname = path.dirname(fileURLToPath(import.meta.url));
const EDITOR_ROOT = path.resolve(__dirname, "..");

// Use project-local browsers (avoids sandbox / arch mismatch with global cache).
process.env.PLAYWRIGHT_BROWSERS_PATH ??= path.join(EDITOR_ROOT, ".playwright-browsers");
const OUT_DIR = path.resolve(EDITOR_ROOT, "../solomaker");
const ZIP_DIR = path.resolve(EDITOR_ROOT, ".export-tmp");
const PORT = Number(process.env.PORT || 3000);
const BASE = `http://127.0.0.1:${PORT}`;

const SOLOMAKER_FILES = [
  { src: "01-hero.jpg", dest: "01-hero.jpg" },
  { src: "02-device-bottom.jpg", dest: "02-3d-dice.jpg" },
  { src: "03-device-bottom.jpg", dest: "03-session.jpg" },
  { src: "04-device-top.jpg", dest: "04-value-cards.jpg" },
  { src: "05-device-bottom.jpg", dest: "05-group-talk.jpg" },
];

function waitForServer(ms = 120_000) {
  const start = Date.now();
  return new Promise((resolve, reject) => {
    const tick = () => {
      const req = http.get(`${BASE}/api/project`, (res) => {
        res.resume();
        if (res.statusCode === 200) resolve();
        else if (Date.now() - start > ms) reject(new Error("Server timeout"));
        else setTimeout(tick, 500);
      });
      req.on("error", () => {
        if (Date.now() - start > ms) reject(new Error("Server timeout"));
        else setTimeout(tick, 500);
      });
    };
    tick();
  });
}

function startDevServer() {
  const child = spawn("npm", ["run", "dev", "--", "-p", String(PORT)], {
    cwd: EDITOR_ROOT,
    stdio: "ignore",
    env: { ...process.env, PORT: String(PORT) },
  });
  return child;
}

async function runExport() {
  const { chromium } = await import("playwright");
  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext({ acceptDownloads: true });
  const page = await context.newPage();

  console.log("Opening editor…");
  await page.goto(BASE, { waitUntil: "networkidle", timeout: 120_000 });

  const exportBtn = page.getByRole("button", { name: /Export bundle/i });
  await exportBtn.waitFor({ state: "visible", timeout: 60_000 });

  console.log("Exporting (all iPhone sizes × locales × slides — may take a few minutes)…");
  const downloadPromise = page.waitForEvent("download", { timeout: 600_000 });
  await exportBtn.click();

  await page
    .getByRole("button", { name: /^Exporting/i })
    .waitFor({ state: "visible", timeout: 30_000 })
    .catch(() => {});

  const download = await downloadPromise;
  await exportBtn.waitFor({ state: "visible", timeout: 600_000 });

  await fs.mkdir(ZIP_DIR, { recursive: true });
  const zipPath = path.join(ZIP_DIR, download.suggestedFilename());
  await download.saveAs(zipPath);
  await browser.close();
  console.log("Saved ZIP:", zipPath);
  return zipPath;
}

async function extractSolomaker(zipPath) {
  await fs.mkdir(OUT_DIR, { recursive: true });
  const extractDir = path.join(ZIP_DIR, "unzipped");
  await fs.rm(extractDir, { recursive: true, force: true });
  await fs.mkdir(extractDir, { recursive: true });
  await execFileAsync("unzip", ["-q", "-o", zipPath, "-d", extractDir]);

  const jaDir = path.join(extractDir, "ios", "iphone", "1284x2778", "ja");
  try {
    await fs.access(jaDir);
  } catch {
    throw new Error(`Expected ${jaDir} in ZIP — check export device is iPhone`);
  }

  for (const { src, dest } of SOLOMAKER_FILES) {
    const from = path.join(jaDir, src);
    const to = path.join(OUT_DIR, dest);
    await fs.copyFile(from, to);
    const stat = await fs.stat(to);
    const mb = (stat.size / (1024 * 1024)).toFixed(2);
    console.log(`  ${dest} (${mb} MB)`);
  }
}

async function main() {
  let devChild = null;

  try {
    try {
      await waitForServer(3_000);
      console.log(`Using existing dev server at ${BASE}`);
    } catch {
      console.log(`Starting dev server on port ${PORT}…`);
      devChild = startDevServer();
      await waitForServer(120_000);
    }

    const zipPath = await runExport();
    console.log("\nExtracting Solomaker set (ja, 6.5\")…");
    await extractSolomaker(zipPath);
    console.log(`\nDone → ${OUT_DIR}`);
  } finally {
    if (devChild) devChild.kill("SIGTERM");
  }
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
