import { ConfigArguments } from "https://deno.land/x/ddc_vim@v4.0.4/base/config.ts";
import {
  BaseConfig,
  SourceOptions as PublicSourceOptions,
  UserSource,
} from "https://deno.land/x/ddc_vim@v4.0.4/types.ts";
import { Denops } from "https://deno.land/x/denops_core@v5.0.0/mod.ts";

type Converter = "converter_fuzzy" | "converter_kind_labels";
type Sorter = "sorter_fuzzy";
type Matcher = "matcher_fuzzy" | "skkeleton";

type SourceOptions = PublicSourceOptions & {
  matchers: Matcher[];
  sorters: Sorter[];
  converters: Converter[];
};

type SourceConfig = UserSource & {
  options: Partial<SourceOptions>;
};

const basicSourceOptions: Partial<SourceOptions> = {
  matchers: ["matcher_fuzzy"],
  sorters: ["sorter_fuzzy"],
  converters: ["converter_fuzzy"],
  ignoreCase: true,
};

const skkSource: SourceConfig = {
  name: "skkeleton",
  options: {
    mark: "[SKK]",
    matchers: ["skkeleton"],
    isVolatile: true,
  },
};

const bufferSource: SourceConfig = {
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

const ultisnipsSource: SourceConfig = {
  name: "ultisnips",
  options: {
    ...basicSourceOptions,
    mark: "[ultisnips]",
  },
  params: {
    expandSnippets: true,
  },
};

const lspSource = (denops: Denops): SourceConfig => {
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

const cmdlineSource: SourceConfig = {
  name: "cmdline",
  options: {
    ...basicSourceOptions,
  },
};

const vimSource: SourceConfig = {
  name: "necovim",
  options: {
    ...basicSourceOptions,
    mark: "[Vim]",
  },
};

export class Config extends BaseConfig {
  async config({
    denops,
    contextBuilder,
  }: ConfigArguments): Promise<void> {
    contextBuilder.patchGlobal({
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
    contextBuilder.patchFiletype("vim", {
      sources: [
        ultisnipsSource,
        vimSource,
        skkSource,
        bufferSource,
      ],
    });

    return await Promise.resolve();
  }
}
