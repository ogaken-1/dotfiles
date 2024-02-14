import { Command } from "./main.ts";

export const command: Command = {
  name: "line",
  exec: () => {
    return {
      resume: false,
      sources: [
        {
          name: "line",
        },
      ],
    };
  },
};
