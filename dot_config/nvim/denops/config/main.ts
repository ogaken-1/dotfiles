import { main as dduMain } from "./ddu/main.ts";
import { Denops } from "../deps.ts";

export async function main(denops: Denops) {
  await dduMain(denops);
}
