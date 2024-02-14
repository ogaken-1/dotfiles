import { Command } from "./main.ts";

export const command: Command = {
  name: "lsp_implementation",
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
          name: "lsp_definition",
          params: {
            method: "textDocument/implementation",
          },
        },
      ],
    };
  },
};
