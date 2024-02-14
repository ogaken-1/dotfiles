import { Command } from "./main.ts";

export const command: Command = {
  name: "lsp_codeAction",
  exec: () => {
    return {
      name: "_",
      resume: false,
      uiParams: {
        ff: {
          startFilter: false,
        },
      },
      sources: [
        {
          name: "lsp_codeAction",
        },
      ],
    };
  },
};
