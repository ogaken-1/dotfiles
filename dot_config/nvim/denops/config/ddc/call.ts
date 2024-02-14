import { DdcOptions } from "../../deps.ts";
import { Denops } from "../../deps.ts";

export async function patchGlobal<TOption extends DdcOptions = DdcOptions>(
  denops: Denops,
  opts: Partial<TOption>,
) {
  await denops.batch(["ddc#custom#patch_global", opts]);
}

export async function patchFiletype<TOption extends DdcOptions = DdcOptions>(
  denops: Denops,
  filetype: string,
  opts: Partial<TOption>,
) {
  await denops.batch(["ddc#custom#patch_filetype", filetype, opts]);
}

export async function patchBuffer<TOption extends DdcOptions = DdcOptions>(
  denops: Denops,
  opts: Partial<TOption>,
) {
  await denops.batch(["ddc#custom#patch_buffer", opts]);
}

export function getCurrent(denops: Denops): Promise<DdcOptions>;
export async function getCurrent(denops: Denops) {
  return await denops.call("ddc#custom#get_current");
}
