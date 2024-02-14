import { autocmd, DdcOptions, Denops } from "../../deps.ts";
import { getContext, setContext } from "../context.ts";
import { getCurrent, patchBuffer, patchFiletype, patchGlobal } from "./call.ts";
import {
  bufferSource,
  cmdlineSource,
  lspSource,
  skkSource,
  ultisnipsSource,
  vimSource,
} from "./sources.ts";

type MyDdc = DdcOptions & {
  ui: "native" | "pum";
};

export async function main(denops: Denops) {
  await patchGlobal<MyDdc>(denops, {
    specialBufferCompletion: false,
    ui: "native",
    sources: [
      ultisnipsSource,
      lspSource(denops),
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
      bufferSource,
    ],
  });

  await addSkkSource(denops);

  await denops.batch(["ddc#enable"]);
}

async function addSkkSource(denops: Denops) {
  denops.dispatcher = {
    enableSkkAutoComplete: async () => {
      setContext(denops, {
        sources: (await getCurrent(denops)).sources,
      });
      await patchBuffer(denops, {
        sources: [
          skkSource,
        ],
      });
    },
    disableSkkAutoComplete: async () => {
      const x = getContext(denops);
      if (x?.sources == null) {
        return;
      }
      await patchBuffer(denops, {
        sources: x.sources,
      });
    },
  };

  await autocmd.group(denops, "VimRc", (helper) => {
    helper.define(
      "User",
      "skkeleton-enable-post",
      `call denops#notify('${denops.name}', 'enableSkkAutoComplete', [])`,
    );
    helper.define(
      "User",
      "skkeleton-disable-post",
      `call denops#notify('${denops.name}', 'disableSkkAutoComplete', [])`,
    );
  });
}
