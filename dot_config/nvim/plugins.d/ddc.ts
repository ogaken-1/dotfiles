import { ConfigArguments } from "https://deno.land/x/ddc_vim@v4.0.4/base/config.ts";
import {
  BaseConfig,
  SourceOptions,
  UserSource,
} from "https://deno.land/x/ddc_vim@v4.0.4/types.ts";
import { Denops } from "https://deno.land/x/denops_core@v5.0.0/mod.ts";

const basicSourceOptions: Partial<SourceOptions> = {
  matchers: ["matcher_fuzzy"],
  sorters: ["sorter_fuzzy"],
  converters: ["converter_fuzzy"],
  ignoreCase: true,
};

const skkSource: UserSource = {
  name: "skkeleton",
  options: {
    mark: "[SKK]",
    matchers: ["skkeleton"],
    isVolatile: true,
  },
};

const bufferSource: UserSource = {
  name: "buffer",
  options: {
    ...basicSourceOptions,
    mark: "[Buffer]",
    keywordPattern: "[a-zA-Z0-9-\_]+",
  },
  params: {
    fromAltBuf: true,
  },
};

const generalSources: UserSource[] = [
  skkSource,
  bufferSource,
];

const lspSource = (denops: Denops): UserSource => {
  return {
    name: "nvim-lsp",
    params: {
      snippetEngine: async (body: unknown) => {
        await denops.call("vsnip#anonymous", body);
        return await Promise.resolve();
      },
      enableResolveItem: true,
      enableAdditionalTextEdit: true,
      confirmBehavior: "replace",
    },
    options: {
      ...basicSourceOptions,
      mark: "[LS]",
      converters: ["converter_fuzzy", "converter_kind_labels"],
      minAutoCompleteLength: 1,
    },
  };
};

const cmdlineSource: UserSource = {
  name: "cmdline",
  options: {
    ...basicSourceOptions,
  },
};

const vimSource: UserSource = {
  name: "necovim",
  options: {
    ...basicSourceOptions,
    mark: "[Vim]",
  },
};

export class Config extends BaseConfig {
  async config(_args: ConfigArguments): Promise<void> {
    const { denops, contextBuilder } = _args;
    contextBuilder.patchGlobal({
      ui: "native" satisfies "native" | "pum",
      sources: [
        lspSource(denops),
        ...generalSources,
      ],
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
    contextBuilder.patchFiletype("vim", {
      sources: [
        vimSource,
        ...generalSources,
      ],
    });

    return await Promise.resolve();
  }
}
