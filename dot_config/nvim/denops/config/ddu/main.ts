import { Denops } from "https://deno.land/x/denops_std@v5.0.1/mod.ts";
import { global } from "./ff/global.ts";

export async function main(denops: Denops) {
  await denops.batch(["ddu#custom#patch_global", global()]);
}
