import { Command } from "./main.ts";

export const command: Command = {
  name: "buffer",
  exec: () => {
    return {
      resume: false,
      sources: [
        "buffer",
      ],
    };
  },
};
