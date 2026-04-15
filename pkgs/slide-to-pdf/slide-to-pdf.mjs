#!/usr/bin/env node

import { remote } from "webdriverio";
import { resolve, basename } from "node:path";
import { writeFile } from "node:fs/promises";
import { readFileSync } from "node:fs";
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

const manifestPath = process.env.SLIDE_FONTS_MANIFEST;
const fontManifest = manifestPath ? JSON.parse(readFileSync(manifestPath, "utf8")) : [];

// Start chromedriver as a subprocess, inheriting env (including FONTCONFIG_FILE)
const driver = spawn(chromedriverPath, [`--port=${port}`], {
  stdio: "ignore",
  env: process.env,
});

// Wait for chromedriver to start
await new Promise((r) => setTimeout(r, 500));

function buildFontFaceCss(manifest) {
  return manifest
    .map((e) => {
      const weight = Array.isArray(e.weight) ? `${e.weight[0]} ${e.weight[1]}` : e.weight;
      const family = JSON.stringify(e.family);
      return `@font-face { font-family: ${family}; font-weight: ${weight}; font-style: ${e.style}; src: url("file://${e.path}") format("truetype"); }`;
    })
    .join("\n");
}

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
          "--font-render-hinting=none",
          "--allow-file-access-from-files",
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

    // Inject local @font-face rules and strip CDN links so that webfont
    // resolution uses Nix-managed local fonts instead of fonts.googleapis.com.
    const fontFaceCss = buildFontFaceCss(fontManifest);
    await browser.execute((css) => {
      document
        .querySelectorAll('link[href*="fonts.googleapis.com"], link[href*="fonts.gstatic.com"]')
        .forEach((el) => el.remove());
      if (css) {
        const style = document.createElement("style");
        style.textContent = css;
        document.head.appendChild(style);
      }
    }, fontFaceCss);

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

    // Screenshot-first hack: force Chromium to embed webfonts in the PDF
    // (puppeteer/puppeteer#422).
    await browser.takeScreenshot();

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
