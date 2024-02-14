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

export async function patchBuffer(denops: Denops, opts: Partial<DdcOptions>) {
  await denops.batch(["ddc#custom#patch_buffer", opts]);
}

export function getCurrent(denops: Denops): Promise<DdcOptions>;
export async function getCurrent(denops: Denops) {
  return await denops.call("ddc#custom#get_current");
}
