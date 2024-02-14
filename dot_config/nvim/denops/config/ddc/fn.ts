import { DdcOptions } from "../../deps.ts";
import { Denops } from "../../deps.ts";

export async function patchGlobal(denops: Denops, opts: Partial<DdcOptions>) {
  await denops.batch(["ddc#custom#patch_global", opts]);
}

export async function patchFiletype(
  denops: Denops,
  filetype: string,
  opts: Partial<DdcOptions>,
) {
  await denops.batch(["ddc#custom#patch_filetype", filetype, opts]);
}
