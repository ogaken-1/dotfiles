#!/usr/bin/env node

import { remote } from "webdriverio";
import { resolve, basename } from "node:path";
import { writeFile } from "node:fs/promises";
import { spawn } from "node:child_process";

const debug = process.argv.includes("--debug");
const positionalArgs = process.argv.slice(2).filter((a) => !a.startsWith("--"));
if (positionalArgs.length < 1 || positionalArgs.length > 2) {
  console.error(`Usage: ${basename(process.argv[1])} [--debug] <input.html> [output.pdf]`);
  process.exit(1);
}

const inputHtml = resolve(positionalArgs[0]);
const outputPdf = positionalArgs[1] ? resolve(positionalArgs[1]) : inputHtml.replace(/\.html$/, ".pdf");

const chromedriverPath = process.env.CHROMEDRIVER_PATH || "chromedriver";
const chromiumPath = process.env.CHROMIUM_PATH || "chromium";
const port = 9515;

// Start chromedriver as a subprocess, inheriting env (including FONTCONFIG_FILE)
const driver = spawn(chromedriverPath, [`--port=${port}`], {
  stdio: "ignore",
  env: process.env,
});

// Wait for chromedriver to start
await new Promise((r) => setTimeout(r, 500));

try {
  const browser = await remote({
    logLevel: debug ? "info" : "silent",
    hostname: "localhost",
    port,
    path: "/",
    capabilities: {
      browserName: "chrome",
      "goog:chromeOptions": {
        binary: chromiumPath,
        args: [
          "--headless=new",
          "--disable-gpu",
          "--no-sandbox",
          "--user-agent=Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36",
        ],
      },
    },
  });

  try {
    await browser.url(`file://${inputHtml}`);

    // Wait for document to be fully loaded
    await browser.waitUntil(
      async () => await browser.execute(() => document.readyState === "complete"),
      { timeout: 10000 },
    );

    // Wait for Mermaid and other async rendering (up to 2 seconds)
    await browser
      .waitUntil(
        async () =>
          await browser.execute(() => {
            const containers = document.querySelectorAll('[class*="mermaid"]');
            if (containers.length === 0) return true;
            return Array.from(containers).every((el) => el.querySelector("svg"));
          }),
        { timeout: 2000, interval: 100 },
      )
      .catch(() => {
        console.error("警告: Mermaid描画の待機がタイムアウトしました。描画なしで続行します。");
      });

    // Wait for all web fonts to finish loading
    await browser.waitUntil(
      async () => await browser.execute(() => document.fonts.status === "loaded"),
      { timeout: 10000, interval: 200 },
    );

    // Convert all slides to print layout
    await browser.execute(() => {
      document.body.style.overflow = "visible";
      document.body.style.background = "#fff";
      document.body.style.display = "block";
      document.body.style.width = "auto";
      document.body.style.height = "auto";
      const container = document.getElementById("slide-container");
      if (container) {
        container.style.position = "static";
        container.style.width = "auto";
        container.style.height = "auto";
        container.style.overflow = "visible";
        container.style.transform = "none";
      }
      const nav = document.getElementById("slide-nav");
      if (nav) nav.style.display = "none";
      document.querySelectorAll(".slide").forEach((s) => {
        s.classList.remove("active");
        s.style.display = "block";
        s.style.position = "relative";
        s.style.top = "auto";
        s.style.left = "auto";
        s.style.transform = "none";
        s.style.pageBreakAfter = "always";
        s.style.pageBreakInside = "avoid";
        s.style.marginBottom = "0";
      });
    });

    // Generate PDF using W3C WebDriver Print API
    // 1920px / 96dpi = 20in = 50.8cm, 1080px / 96dpi = 11.25in = 28.575cm
    const pdfBase64 = await browser.printPage(
      "landscape", // orientation
      1,           // scale
      true,        // background
      50.8,        // width (cm)
      28.575,      // height (cm)
      0,           // top margin
      0,           // bottom margin
      0,           // left margin
      0,           // right margin
      false,       // shrinkToFit
    );

    await writeFile(outputPdf, Buffer.from(pdfBase64, "base64"));
    console.log(`PDF出力完了: ${outputPdf}`);
  } finally {
    await browser.deleteSession();
  }
} catch (err) {
  console.error("PDF出力エラー:", err.message);
  process.exit(1);
} finally {
  driver.kill();
}
