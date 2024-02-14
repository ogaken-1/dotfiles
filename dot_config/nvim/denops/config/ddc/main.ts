import { Denops } from "../../deps.ts";
import {
  bufferSource,
  cmdlineSource,
  lspSource,
  skkSource,
  ultisnipsSource,
  vimSource,
} from "./sources.ts";

export async function main(denops: Denops) {
  await denops.batch([
    "ddc#custom#patch_global",
    {
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
    },
  ]);
  await denops.batch([
    "ddc#custom#patch_filetype",
    "vim",
    {
      sources: [
        ultisnipsSource,
        vimSource,
        skkSource,
        bufferSource,
      ],
    },
  ]);
  await denops.batch(["ddc#enable"]);
}
