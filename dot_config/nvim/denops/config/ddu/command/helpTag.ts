import { Command } from "./main.ts";

export const command: Command = {
  name: "help_tag",
  exec: () => {
    return {
      resume: false,
      sources: [
        {
          name: "help",
        },
      ],
    };
  },
};
