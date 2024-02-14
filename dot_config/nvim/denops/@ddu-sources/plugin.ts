import { GatherArguments } from "https://deno.land/x/ddu_vim@v3.3.3/base/source.ts";
import { BaseSource, Item } from "https://deno.land/x/ddu_vim@v3.3.3/types.ts";
import { ActionData } from "https://raw.githubusercontent.com/KentoOgata/ddu-kind-git_repo/0.1.0/denops/@ddu-kinds/git_repo/types.ts";

type SourceParams = Record<string | number | symbol, never>;

type DeinPlugin = {
  name: string;
  path: string;
};

function isDeinPlugin(x: unknown): x is DeinPlugin {
  return x != null && typeof x === "object" &&
    "path" in x && x.path != null &&
    typeof x.path === "string" && "name" in x && x.name != null &&
    typeof x.name === "string";
}

/**
 * Get typed keys
 */
function keys<T extends object>(x: T) {
  return (Array.isArray(x) ? x.keys() : Object.keys(x)) as (keyof T)[];
}

function isDeinPlugins(x: unknown): x is Record<string, DeinPlugin> {
  if (!(x != null && typeof x === "object")) {
    return false;
  }
  for (const key of keys(x)) {
    if (typeof key !== "string") {
      return false;
    }
    if (!isDeinPlugin(x[key])) {
      return false;
    }
  }

  return true;
}

export class Source extends BaseSource<SourceParams, ActionData> {
  kind = "git_repo";

  gather(
    { denops }: GatherArguments<SourceParams>,
  ): ReadableStream<Item<ActionData>[]> {
    return new ReadableStream({
      start: async (controller) => {
        try {
          const plugins = await denops.call("dein#get");
          if (!isDeinPlugins(plugins)) {
            return;
          }
          const items: Item<ActionData>[] = [];
          for (const name in plugins) {
            const { path } = plugins[name];
            items.push({
              word: name,
              action: {
                path: path,
              },
            });
          }
          controller.enqueue(items);
        } finally {
          controller.close();
        }
      },
    });
  }
  params(): SourceParams {
    return {};
  }
}
