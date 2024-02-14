import { ConfigArguments } from "https://deno.land/x/ddc_vim@v4.0.4/base/config.ts";
import {
  BaseConfig,
  SourceOptions,
  UserSource,
} from "https://deno.land/x/ddc_vim@v4.0.4/types.ts";

const basicSourceOptions: Partial<SourceOptions> = {
  matchers: ["matcher_fuzzy"],
  sorters: ["sorter_fuzzy"],
  converters: ["converter_fuzzy"],
  ignoreCase: true,
};

const generalSources: UserSource[] = [
  {
    name: "skkeleton",
    options: {
      mark: "[SKK]",
      matchers: ["skkeleton"],
      isVolatile: true,
    },
  },
  {
    name: "buffer",
    options: {
      ...basicSourceOptions,
      mark: "[Buffer]",
      keywordPattern: "[a-zA-Z0-9-\_]+",
    },
    params: {
      fromAltBuf: true,
    },
  },
];

export class Config extends BaseConfig {
  async config(_args: ConfigArguments): Promise<void> {
    const { denops, contextBuilder } = _args;
    contextBuilder.patchGlobal({
      ui: "native" satisfies "native" | "pum",
      sources: [
        {
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
        },
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
          {
            name: "cmdline",
            options: {
              ...basicSourceOptions,
            },
          },
        ],
      },
    });
    contextBuilder.patchFiletype("vim", {
      sources: [
        {
          name: "necovim",
          options: {
            ...basicSourceOptions,
            mark: "[Vim]",
          },
        },
        ...generalSources,
      ],
    });

    return await Promise.resolve();
  }
}
