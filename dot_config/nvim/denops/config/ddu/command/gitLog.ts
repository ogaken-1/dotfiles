import { Denops } from "../../../deps.ts";
import { getcwd } from "../util.ts";
import { Command } from "./main.ts";

export const command: Command = {
  name: "git_log",
  exec: async (denops: Denops) => {
    return {
      sources: [
        {
          name: "git_log",
          options: {
            path: await getcwd(denops),
          },
          params: {
            showAll: true,
          },
        },
      ],
      kindOptions: {
        git_commit: {
          defaultAction: "insert",
        },
      },
    };
  },
  itemActions: {
    ["c"]: "cherryPick",
  },
};
