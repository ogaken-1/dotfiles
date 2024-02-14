import { Command } from "./main.ts";

export const command: Command = {
  name: "plugin",
  exec: () => {
    return {
      resume: false,
      sources: [
        {
          name: "plugin",
        },
      ],
    };
  },
  itemActions: {
    "x": "startTmux",
  },
};
