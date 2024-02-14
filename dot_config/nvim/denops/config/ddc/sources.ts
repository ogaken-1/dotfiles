import { Denops } from "../../deps.ts";
import { denopsCallback } from "../callback.ts";
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
    mark: "[ultisnips]",
    sorters: ["sorter_rank"],
    matchers: ["matcher_head"],
    converters: [],
    ignoreCase: true,
  },
  params: {
    expandSnippets: true,
  },
};

export const lspSource = async (denops: Denops): Promise<SourceConfig> => {
  return {
    name: "nvim-lsp",
    params: {
      snippetEngine: await denopsCallback(
        denops,
        async ([body]: unknown[]) => {
          await denops.call("vsnip#anonymous", body);
        },
      ),
      enableResolveItem: true,
      enableAdditionalTextEdit: true,
      confirmBehavior: "replace",
    },
    options: {
      matchers: ["matcher_fuzzy"],
      sorters: ["sorter_lsp-kind", "sorter_fuzzy"],
      ignoreCase: true,
      mark: "[LS]",
      converters: ["converter_fuzzy", "converter_kind_labels"],
      minAutoCompleteLength: 1,
      forceCompletionPattern: "\\.",
    },
  };
};

export const cmdlineSource: SourceConfig = {
  name: "cmdline",
  options: {
    ...basicSourceOptions,
    minAutoCompleteLength: 1,
    keywordPattern: "[a-zA-Z0-9#\_]+",
  },
};

export const vimSource: SourceConfig = {
  name: "necovim",
  options: {
    ...basicSourceOptions,
    mark: "[Vim]",
  },
};
