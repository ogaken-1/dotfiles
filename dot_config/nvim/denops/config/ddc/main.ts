import { Denops } from "../../deps.ts";
import { patchFiletype, patchGlobal } from "./fn.ts";
import {
  bufferSource,
  cmdlineSource,
  lspSource,
  skkSource,
  ultisnipsSource,
  vimSource,
} from "./sources.ts";

export async function main(denops: Denops) {
  await patchGlobal(denops, {
    ui: "native" satisfies "native" | "pum",
    sources: [
      ultisnipsSource,
      lspSource(denops),
      skkSource,
      bufferSource,
    ],
    sourceOptions: {
      _: {
        dup: "keep",
      },
    },
    autoCompleteEvents: [
      "TextChangedI",
      "TextChangedP",
      "CmdlineChanged",
    ],
    backspaceCompletion: true,
    cmdlineSources: {
      ":": [
        cmdlineSource,
      ],
    },
  });
  await patchFiletype(denops, "vim", {
    sources: [
      ultisnipsSource,
      vimSource,
      skkSource,
      bufferSource,
    ],
  });
  await denops.batch(["ddc#enable"]);
}
