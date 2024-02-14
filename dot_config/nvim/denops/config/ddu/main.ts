import { autocmd, Denops, map, opt } from "../../deps.ts";
import { globalConfig } from "./global.ts";
import { patchGlobal } from "./call.ts";
import { addCommand } from "./command/main.ts";

export async function main(denops: Denops) {
  await patchGlobal(denops, await globalConfig(denops));
  await watchVimSize(denops, "VimRc");
  addCommand(denops);
  await defineFinderKeymaps(denops);
}

async function watchVimSize(denops: Denops, augroup: string) {
  const fn = "notifyVimSize";
  denops.dispatcher = {
    ...denops.dispatcher,
    [fn]: async () => {
      const lines = await opt.lines.get(denops);
      const columns = await opt.columns.get(denops);

      const winHeight = Math.floor(lines * 0.8);
      const winRow = Math.floor(lines * 0.1);
      const winWidth = Math.floor(columns * 0.8);
      const winCol = Math.floor(columns * 0.1);

      const [
        previewSplit,
        previewHeight,
        previewWidth,
      ] = columns < 200
        ? ["horizontal", Math.floor(winHeight / 2), winWidth]
        : ["vertical", winHeight, Math.floor(winWidth / 2)];

      await patchGlobal(denops, {
        uiParams: {
          ff: {
            winHeight,
            winRow,
            winWidth,
            winCol,
            previewWidth,
            previewHeight,
            previewSplit,
          },
        },
      });
    },
  };

  await denops.dispatcher[fn]();

  await denops.cmd(
    `au ${augroup} VimResized * call denops#notify('${denops.name}', '${fn}', [])`,
  );
}

const uiActions: Record<string, string> = {
  ["<CR>"]: "itemAction",
  ["i"]: "openFilterWindow",
  ["q"]: "quit",
  ["<Space>"]: "toggleSelectItem",
  ["<C-Space>"]: "toggleAllItems",
  ["p"]: "toggleAutoAction",
  ["l"]: "expandItem",
  ["h"]: "collapseItem",
  ["a"]: "chooseAction",
};

async function doUiMaps(denops: Denops) {
  for (const keys in uiActions) {
    await map(
      denops,
      keys,
      `<Cmd>call ddu#ui#do_action('${uiActions[keys]}')<CR>`,
      { mode: "n", buffer: true, nowait: true },
    );
  }
}

async function defineFinderKeymaps(denops: Denops) {
  denops.dispatcher = {
    ...denops.dispatcher,
    ["ddu:ff:keyMaps"]: async () => {
      await doUiMaps(denops);
    },
    ["ddu:ff-filter:keyMaps"]: async () => {
      await map(
        denops,
        "<CR>",
        "<Esc><Cmd>call ddu#ui#do_action('closeFilterWindow')<CR>",
        { mode: "i", buffer: true, nowait: true },
      );
      await map(
        denops,
        "<CR>",
        "<Cmd>call ddu#ui#do_action('closeFilterWindow')<CR>",
        { mode: "n", buffer: true, nowait: true },
      );
      await map(
        denops,
        "q",
        "<Cmd>call ddu#ui#do_action('quit')<CR>",
        { mode: "n", buffer: true, nowait: true },
      );
    },
  };

  await autocmd.define(
    denops,
    "FileType",
    "ddu-ff",
    `call denops#request('${denops.name}', 'ddu:ff:keyMaps', [])`,
    { group: "VimRc" },
  );
  await autocmd.define(
    denops,
    "FileType",
    "ddu-ff-filter",
    `call denops#request('${denops.name}', 'ddu:ff-filter:keyMaps', [])`,
    { group: "VimRc" },
  );
}
