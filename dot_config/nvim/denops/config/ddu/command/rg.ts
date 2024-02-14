import { Denops } from "../../../deps.ts";
import { getcwd } from "../util.ts";
import { Command } from "./main.ts";

export const command: Command = {
  name: "rg",
  exec: async (denops: Denops) => {
    return {
      resume: false,
      sources: [
        {
          name: "rg",
          options: {
            path: await getcwd(denops),
          },
        },
      ],
    };
  },
};
