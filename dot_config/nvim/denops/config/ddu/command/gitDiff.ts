import { Command } from "./main.ts";

export const command: Command = {
  name: "git_diff",
  exec: () => {
    return {
      sources: [
        {
          name: "git_diff",
        },
      ],
    };
  },
  itemActions: {
    ["<<"]: "applyPatch",
  },
};
