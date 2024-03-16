import { Denops } from "https://deno.land/x/denops_core@v6.0.5/mod.ts";
import { Server } from "./server.ts";
import * as vim from "https://deno.land/x/denops_std@v6.4.0/function/mod.ts";
import { assert, is } from "https://deno.land/x/unknownutil@v3.17.0/mod.ts";
import { LSP } from "https://deno.land/x/denops_lsputil@v0.9.4/deps.ts";
import { applyTextEdits } from "https://deno.land/x/denops_lsputil@v0.9.4/mod.ts";

const isContext = is.RecordOf(
  is.OptionalOf((x): x is Server => x instanceof Server),
  is.String,
);

export function main(denops: Denops) {
  denops.dispatcher = {
    startServer: async () => {
      assert(denops.context, isContext);
      const cwd = await vim.getcwd(denops);
      const server = denops.context[cwd];
      if (server != null) {
        return;
      }
      denops.context[cwd] = new Server(cwd);
    },
    format: async (bufnr: unknown): Promise<void> => {
      assert(denops.context, isContext);
      if (!is.Number(bufnr)) {
        return;
      }
      const cwd = await vim.getcwd(denops);
      const server = denops.context[cwd];
      if (server == null) {
        return;
      }
      const content = await vim.getbufline(denops, bufnr, 1, "$");
      const bufname = await vim.bufname(denops, bufnr);
      const filePath = await vim.fnamemodify(denops, bufname, ":p");
      const next = await server.formatFile(content.join("\n"), filePath);
      if (!next.ok) {
        return;
      }
      const textEdit: LSP.TextEdit = {
        range: {
          start: {
            line: 0,
            character: 0,
          },
          end: {
            line: content.length,
            character: content[content.length - 1].length,
          },
        },
        newText: next.text.join("\n"),
      };
      await applyTextEdits(denops, bufnr, [textEdit]);
    },
  };
}
