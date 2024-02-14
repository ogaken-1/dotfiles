import { PublicSourceOptions, UserSource } from "../../deps.ts";

export type Converter = "converter_fuzzy" | "converter_kind_labels";
export type Sorter = "sorter_fuzzy" | "sorter_rank";
export type Matcher = "matcher_fuzzy" | "skkeleton" | "matcher_head";

export type SourceOptions = PublicSourceOptions & {
  matchers: Matcher[];
  sorters: Sorter[];
  converters: Converter[];
};

export type SourceConfig = UserSource & {
  options: Partial<SourceOptions>;
};
