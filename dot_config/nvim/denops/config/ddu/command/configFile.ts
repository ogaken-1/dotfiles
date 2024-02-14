import { join } from "https://deno.land/std@0.203.0/path/mod.ts";
import { Denops, vars } from "../../../deps.ts";
import { Command } from "./main.ts";

export const command: Command = {
  name: "config_file",
  exec: async (denops: Denops) => {
    return {
      resume: false,
      sources: [
        {
          name: "file_external",
          options: {
            path: join(await vars.e.get(denops, "XDG_DATA_HOME"), "chezmoi"),
          },
        },
      ],
    };
  },
};
