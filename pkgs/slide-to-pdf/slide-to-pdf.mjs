#!/usr/bin/env node

import { chromium } from "playwright-core";
import { resolve, basename } from "node:path";

const args = process.argv.slice(2);
if (args.length < 1 || args.length > 2) {
  console.error(`Usage: ${basename(process.argv[1])} <input.html> [output.pdf]`);
  process.exit(1);
}

const inputHtml = resolve(args[0]);
const outputPdf = args[1] ? resolve(args[1]) : inputHtml.replace(/\.html$/, ".pdf");

try {
  const browser = await chromium.launch();
  const page = await browser.newPage();
  await page.goto(`file://${inputHtml}`);
  await page.waitForLoadState("networkidle");
  // Mermaid等の非同期描画をポーリングで待機（最大2秒）
  await page
    .waitForFunction(
      () => {
        const containers = document.querySelectorAll('[class*="mermaid"]');
        if (containers.length === 0) return true;
        return Array.from(containers).every((el) => el.querySelector("svg"));
      },
      { timeout: 2000 },
    )
    .catch(() => {
      console.error("警告: Mermaid描画の待機がタイムアウトしました。描画なしで続行します。");
    });
  // 全スライドを印刷レイアウトに強制変換
  await page.evaluate(() => {
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
  await page.pdf({
    path: outputPdf,
    width: "1920px",
    height: "1080px",
    printBackground: true,
  });
  await browser.close();
  console.log(`PDF出力完了: ${outputPdf}`);
} catch (err) {
  console.error("PDF出力エラー:", err.message);
  process.exit(1);
}
