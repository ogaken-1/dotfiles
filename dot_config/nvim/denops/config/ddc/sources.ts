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

export const lspSource: SourceConfig = {
  name: "nvim-lsp",
  params: {
    enableResolveItem: false,
    enableAdditionalTextEdit: false,
    confirmBehavior: "insert",
  },
  options: {
    matchers: ["matcher_fuzzy"],
    sorters: ["sorter_fuzzy", "sorter_lsp-kind"],
    ignoreCase: true,
    mark: "[LS]",
    converters: ["converter_fuzzy", "converter_kind_labels"],
    minAutoCompleteLength: 1,
    forceCompletionPattern: "\\.",
  },
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
