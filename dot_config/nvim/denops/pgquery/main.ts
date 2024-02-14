import { Client } from "https://deno.land/x/postgres@v0.17.0/mod.ts";
import { Denops } from "../deps.ts";
import { is } from "../deps.ts";

export function main(denops: Denops) {
  denops.dispatcher = {
    queryObject: async (maybeQuery: unknown): Promise<unknown> => {
      if (!is.String(maybeQuery)) {
        throw Error("Query must be a string");
      }
      const client = new Client();
      await client.connect();
      try {
        const result = await client.queryObject(maybeQuery);
        return result.rows;
      } finally {
        client.end();
      }
    },
  };
}
