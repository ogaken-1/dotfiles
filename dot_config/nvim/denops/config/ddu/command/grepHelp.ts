import { Denops, fn } from "../../../deps.ts";
import { Command } from "./main.ts";

export const command: Command = {
  name: "grep_help",
  exec: (denops: Denops) => {
    return {
      resume: false,
      sources: [
        {
          name: "rg",
          params: {
            paths: fn.globpath(denops, "doc/*.txt", true, true),
          },
        },
      ],
    };
  },
};
