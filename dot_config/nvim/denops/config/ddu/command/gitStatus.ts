import { Denops } from "../../../deps.ts";
import { getcwd } from "../util.ts";
import { Command } from "./main.ts";

export const command: Command = {
  name: "git_status",
  exec: async (denops: Denops) => {
    return {
      resume: false,
      sources: [
        {
          name: "git_status",
          options: {
            path: await getcwd(denops),
          },
        },
      ],
      uiParams: {
        ff: {
          startAutoAction: true,
          startFilter: false,
        },
      },
    };
  },
  itemActions: {
    ["<<"]: "add",
  },
};
