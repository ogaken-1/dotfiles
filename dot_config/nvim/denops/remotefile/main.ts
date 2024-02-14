import { Denops } from "https://deno.land/x/denops_core@v3.4.2/mod.ts";

export function main(denops: Denops) {
  denops.dispatcher = {
    getContent: async (url: unknown): Promise<string[]> => {
      if (typeof url !== "string") {
        return [];
      }
      const response = await fetch(url);
      if (response.body == null) {
        return [];
      }

      const content = await response.arrayBuffer();
      return (new TextDecoder()).decode(content).split("\n");
    },
  };
}
