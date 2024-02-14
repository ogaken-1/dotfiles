import { Command } from "./main.ts";

export const command: Command = {
  name: "ghq",
  exec: () => {
    return {
      resume: false,
      sources: [
        {
          name: "ghq",
        },
      ],
    };
  },
};
