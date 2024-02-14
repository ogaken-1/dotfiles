import { join } from "https://deno.land/std@0.192.0/path/mod.ts";
import { Denops } from "https://deno.land/x/denops_core@v5.0.0/mod.ts";
import { e } from "https://deno.land/x/denops_std@v5.0.1/variable/environment.ts";

export async function main(denops: Denops) {
  denops.dispatcher = {
    ...denops.dispatcher,
    "ddc-setup": async () => {
      await denops.call(
        "ddc#custom#load_config",
        join(await e.get(denops, "DEIN_CONFIG_DIR"), "ddc.ts"),
      );
      await denops.call("ddc#enable");
    },
  };

  await denops.cmd(
    `au VimRc InsertEnter * ++once call denops#notify('${denops.name}', 'ddc-setup', [])`,
  );
}
