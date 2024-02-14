import { Command } from "./main.ts";

export const command: Command = {
  name: "lsp_reference",
  exec: () => {
    return {
      resume: false,
      uiParams: {
        ff: {
          startAutoAction: true,
          startFilter: false,
        },
      },
      sources: [
        {
          name: "lsp_references",
        },
      ],
    };
  },
};
