import { Denops } from "https://deno.land/x/denops_std@v5.0.1/mod.ts";
import * as opt from "https://deno.land/x/denops_std@v5.0.1/option/mod.ts";
import { globalConfig } from "./ff/global.ts";
import { DduOptions } from "https://deno.land/x/ddu_vim@v3.5.1/types.ts";

export async function main(denops: Denops) {
  await denops.batch(["ddu#custom#patch_global", globalConfig()]);
  await watchVimSize(denops);
}

async function watchVimSize(denops: Denops) {
  denops.dispatcher = {
    ...denops.dispatcher,
    notifyVimSize: async () => {
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

      await denops.batch([
        "ddu#custom#patch_global",
        {
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
        } satisfies Partial<DduOptions>,
      ]);
    },
  };

  await denops.dispatcher.notifyVimSize();

  await denops.cmd(
    `au VimRc VimResized * call denops#notify('${denops.name}', 'notifyVimSize', [])`,
  );
}
