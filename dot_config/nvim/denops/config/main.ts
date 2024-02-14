import { main as dduMain } from "./ddu/main.ts";
import { main as ddcMain } from "./ddc/main.ts";
import { Denops } from "../deps.ts";

export async function main(denops: Denops) {
  await ddcMain(denops);
  await dduMain(denops);
}
