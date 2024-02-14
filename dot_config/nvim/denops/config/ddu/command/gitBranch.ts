import { Denops, fn } from "../../../deps.ts";
import { currentWorktree } from "../util.ts";
import { Command } from "./main.ts";

export const command: Command = {
  name: "git_branch",
  exec: async (denops: Denops) => {
    return {
      resume: false,
      sources: [
        {
          name: "git_branch",
          options: {
            path: await currentWorktree(denops) ?? await fn.getcwd(denops),
          },
        },
      ],
      uiParams: {
        ff: {
          startAutoAction: true,
        },
      },
    };
  },
};
