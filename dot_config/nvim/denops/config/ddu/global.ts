import {
  ActionArguments,
  ActionFlags,
  DduItem,
  DduOptions,
  Denops,
  echoerr,
  FfParams,
  GitStatusActionData,
} from "../../deps.ts";
import { denopsCallback } from "../callback.ts";

type Empty = Record<string | number | symbol, never>;

export async function globalConfig(
  denops: Denops,
): Promise<Partial<DduOptions>> {
  return {
    ui: "ff",
    uiParams: {
      ff: {
        startFilter: true,
        prompt: "> ",
        split: "floating",
        floatingBorder: "single",
        filterSplitDirection: "floating",
        filterFloatingPosition: "top",
        previewFloating: true,
        previewFloatingBorder: "single",
        previewFloatingTitle: "Preview",
        highlights: {
          floating: "NormalFloat",
          floatingBorder: "FloatBorder",
        },
        autoAction: {
          name: "preview",
        },
      } satisfies Partial<FfParams>,
    },
    sourceOptions: {
      _: {
        matchers: ["matcher_fzf"],
        sorters: ["sorter_fzf"],
        converters: ["converter_devicon"],
      },
      help: {
        converters: [],
      },
      rg: {
        matchers: [],
        sorters: [],
        converters: ["converter_hl_dir"],
        volatile: true,
      },
      line: {
        matchers: ["matcher_substring"],
        sorters: [],
        converters: [],
      },
      file_external: {
        converters: ["converter_hl_dir", "converter_devicon"],
      },
      deno_module: {
        volatile: true,
        columns: ["filename"],
      },
      git_status: {
        converters: [
          "converter_devicon",
          "converter_hl_dir",
          "converter_git_status",
        ],
      },
      git_branch: {
        columns: [
          "git_branch_head",
          "git_branch_remote",
          "git_branch_name",
          "git_branch_upstream",
          "git_branch_author",
          "git_branch_date",
        ],
      },
    },
    kindOptions: {
      file: {
        defaultAction: "open",
      },
      help: {
        defaultAction: "open",
      },
      lsp: {
        defaultAction: "open",
      },
      lsp_codeAction: {
        defaultAction: "apply",
      },
      ui_select: {
        defaultAction: "select",
      },
      action: {
        defaultAction: "do",
      },
      deno_module: {
        defaultAction: "resolve",
      },
      git_status: {
        defaultAction: "open",
        actions: {
          commit: await denopsCallback(
            denops,
            async () => {
              await denops.batch(["ddu#ui#do_action", "quit"]);
              await denops.cmd("Gin commit");
              return ActionFlags.None;
            },
          ),
          unstage: await denopsCallback(
            denops,
            async ([args]: unknown[]) => {
              const { items } = args as ActionArguments<Empty>;
              const files: Map<string, string[]> = new Map();
              for (const item of items) {
                if (!isGitStatusKindItem(item)) {
                  continue;
                }
                const { worktree, path } = item.action;
                const paths = files.get(worktree);
                files.set(worktree, paths == null ? [path] : [...paths, path]);
              }
              if (files.size === 0) {
                return ActionFlags.Persist;
              }
              const tasks: Promise<Deno.CommandStatus>[] = [];
              for (const worktree of files.keys()) {
                const paths = files.get(worktree);
                if (paths == null) {
                  continue;
                }
                const { status } = new Deno.Command("git", {
                  args: [
                    "-C",
                    worktree,
                    "restore",
                    "--staged",
                    "--",
                    ...paths,
                  ],
                }).spawn();
                tasks.push(status);
              }
              for (const status of await Promise.all(tasks)) {
                if (!status.success) {
                  await echoerr(
                    denops,
                    `Git restore action failed with exit code ${status.code}`,
                  );
                }
              }
              return ActionFlags.RefreshItems;
            },
          ),
        },
      },
      git_branch: {
        defaultAction: "switch",
      },
      git_repo: {
        defaultAction: "find",
      },
    },
    kindParams: {
      file: {
        trashCommand: ["trash"],
      },
    },
    filterParams: {
      matcher_fzf: {
        highlightMatched: "Search",
      },
      matcher_substring: {
        highlightMatched: "Search",
      },
      converter_hl_dir: {
        hlGroup: "String",
      },
    },
    sourceParams: {
      file_external: {
        cmd: ["fd", "-t", "file"],
      },
      buffer: {
        orderby: "asc",
      },
      lsp_references: {
        includeDeclaration: false,
      },
    },
  };
}

type GitStatusKindItem = DduItem & {
  kind: "git_status";
  action: GitStatusActionData;
};

function isGitStatusActionData(x: unknown): x is GitStatusActionData {
  return x != null && typeof x === "object" && "status" in x &&
    typeof x.status === "string" && "path" in x && typeof x.path === "string" &&
    "worktree" in x && typeof x.worktree === "string";
}

function isGitStatusKindItem(item: DduItem): item is GitStatusKindItem {
  return item.kind === "git_status" && isGitStatusActionData(item.action);
}
