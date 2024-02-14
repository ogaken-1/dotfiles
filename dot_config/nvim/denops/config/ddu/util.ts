import { Denops, fn } from "../../deps.ts";

export function currentWorktree(denops: Denops): Promise<string | undefined>;
export async function currentWorktree(denops: Denops) {
  return await denops.dispatch(
    "gin",
    "util:worktree",
    await fn.bufname(denops),
  ).catch(() => undefined);
}
