import { Denops } from "https://deno.land/x/denops_core@v5.0.0/mod.ts";
import { main as dduMain } from "./ddu/main.ts";
import { main as ddcMain } from "./ddc/main.ts";

export async function main(denops: Denops) {
  await ddcMain(denops);
  await dduMain(denops);
}
