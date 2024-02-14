import { Command } from "./main.ts";

export const command: Command = {
  name: "resume",
  exec: () => {
    return {
      resume: true,
      name: "default",
      uiParams: {
        ff: {
          startFilter: false,
        },
      },
    };
  },
};
