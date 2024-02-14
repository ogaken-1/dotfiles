import { Denops } from "../../../deps.ts";
import { getcwd } from "../util.ts";
import { Command } from "./main.ts";

export const command: Command = {
  name: "files",
  exec: async (denops: Denops) => {
    return {
      ui: "ff",
      resume: false,
      sources: [
        {
          name: "file_external",
          options: {
            path: await getcwd(denops),
          },
        },
      ],
    };
  },
  itemActions: {
    d: "trash",
    x: "quickfix",
  },
};
