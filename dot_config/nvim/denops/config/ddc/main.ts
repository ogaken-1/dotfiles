import { autocmd, CompletionItem, DdcOptions, Denops, fn } from "../../deps.ts";
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

type LspKind = typeof CompletionItem.Kind[keyof typeof CompletionItem.Kind];

const priority: LspKind[] = [
  "Keyword",
  "Snippet",
  "Variable",
  "Field",
  "Property",
  "Method",
  "Function",
  "Constructor",
  "Class",
  "Interface",
  "Module",
  "Unit",
  "Value",
  "Enum",
  "Color",
  "File",
  "Reference",
  "Folder",
  "EnumMember",
  "Constant",
  "Struct",
  "Event",
  "Operator",
  "TypeParameter",
  "Text",
];

export async function main(denops: Denops) {
  const ui = Deno.env.get("NVIM_DDC_UI");
  if (!(ui === "native" || ui === "pum")) {
    throw new Error(`Invalid ddc ui name: ${ui}`);
  }
  await patchGlobal<MyDdc>(denops, {
    specialBufferCompletion: false,
    ui,
    sources: [
      ultisnipsSource,
      await lspSource(denops),
      bufferSource,
    ],
    sourceOptions: {
      _: {
        dup: "keep",
      },
    },
    filterParams: {
      ["sorter_lsp-kind"]: {
        priority,
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

  if (Deno.env.get("NVIM_CMDLINE") === "ddc") {
    if (await fn.mode(denops, 1) === "c") {
      await denops.call("ddc#enable_cmdline_completion");
    }

    await denops.cmd(
      `au VimRc CmdlineEnter * call ddc#enable_cmdline_completion()`,
    );
  }
}

async function addSkkSource(denops: Denops) {
  denops.dispatcher = {
    ...denops.dispatcher,
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
