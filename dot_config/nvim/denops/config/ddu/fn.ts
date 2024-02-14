import { DduOptions } from "../../deps.ts";
import { Denops } from "../../deps.ts";

export async function patchGlobal(denops: Denops, opts: Partial<DduOptions>) {
  await denops.batch(["ddu#custom#patch_global", opts]);
}
