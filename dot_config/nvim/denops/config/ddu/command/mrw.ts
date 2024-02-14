import { Command } from "./main.ts";

export const command: Command = {
  name: "mrw",
  exec: () => {
    return {
      resume: false,
      uiParams: {
        ff: {
          startFilter: false,
        },
      },
      sources: [
        {
          name: "mr",
          params: {
            kind: "mrw",
          },
        },
      ],
    };
  },
};
