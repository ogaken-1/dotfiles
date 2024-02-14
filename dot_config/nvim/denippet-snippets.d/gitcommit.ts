import { Denops } from "https://deno.land/x/denops_core@v5.0.0/mod.ts";
// import * as fn from "https://deno.land/x/denops_std@v5.2.0/function/mod.ts";

type PromiseOr<T> = Promise<T> | T;

type Snippet = {
  prefix: string | string[];
  body: (denops: Denops) => PromiseOr<string[]>;
};

export const snippets: Record<string, Snippet> = {
  coAuthoredBy: {
    prefix: "Co-authored-by",
    body: () => {
      return [
        "Co-authored-by: $1 <$2>$0",
      ];
    },
  },
};
