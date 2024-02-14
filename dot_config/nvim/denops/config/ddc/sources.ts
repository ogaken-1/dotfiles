import { Denops } from "../../deps.ts";
import { SourceConfig, SourceOptions } from "./types.ts";

const basicSourceOptions: Partial<SourceOptions> = {
  matchers: ["matcher_fuzzy"],
  sorters: ["sorter_fuzzy"],
  converters: ["converter_fuzzy"],
  ignoreCase: true,
};

export const skkSource: SourceConfig = {
  name: "skkeleton",
  options: {
    mark: "[SKK]",
    matchers: ["skkeleton"],
    isVolatile: true,
  },
};

export const bufferSource: SourceConfig = {
  name: "buffer",
  options: {
    ...basicSourceOptions,
    dup: "ignore",
    mark: "[Buffer]",
    keywordPattern: "[a-zA-Z0-9-\_]+",
  },
  params: {
    fromAltBuf: true,
  },
};

export const ultisnipsSource: SourceConfig = {
  name: "ultisnips",
  options: {
    ...basicSourceOptions,
    mark: "[ultisnips]",
  },
  params: {
    expandSnippets: true,
  },
};

export const lspSource = (denops: Denops): SourceConfig => {
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

export const cmdlineSource: SourceConfig = {
  name: "cmdline",
  options: {
    ...basicSourceOptions,
  },
};

export const vimSource: SourceConfig = {
  name: "necovim",
  options: {
    ...basicSourceOptions,
    mark: "[Vim]",
  },
};
