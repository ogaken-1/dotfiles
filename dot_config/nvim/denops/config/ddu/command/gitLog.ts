import { Denops } from "../../../deps.ts";
import { getcwd } from "../util.ts";
import { Command } from "./main.ts";

type Params = {
  showAll: boolean;
};

export const command = ({ showAll }: Params): Command => {
  return {
    name: `git_log${showAll ? ":all" : ":branch"}`,
    exec: async (denops: Denops) => {
      return {
        sources: [
          {
            name: "git_log",
            options: {
              path: await getcwd(denops),
            },
            params: {
              showAll,
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
};
