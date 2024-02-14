import {
  BaseSource,
  GatherArguments,
  GitRepoActionData,
  Item,
} from "../deps.ts";

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

export class Source extends BaseSource<SourceParams, GitRepoActionData> {
  kind = "git_repo";

  gather(
    { denops }: GatherArguments<SourceParams>,
  ): ReadableStream<Item<GitRepoActionData>[]> {
    return new ReadableStream({
      start: async (controller) => {
        try {
          const plugins = await denops.call("dein#get");
          if (!isDeinPlugins(plugins)) {
            return;
          }
          const items: Item<GitRepoActionData>[] = [];
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
