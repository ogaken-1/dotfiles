import {
  autocmd,
  DduOptions,
  Denops,
  echoerr,
  is,
  map,
} from "../../../deps.ts";
import { command as file } from "./file.ts";
import { command as buffer } from "./buffer.ts";
import { command as rg } from "./rg.ts";
import { command as grepHelp } from "./grepHelp.ts";
import { command as mrw } from "./mrw.ts";
import { command as helpTag } from "./helpTag.ts";
import { command as configFile } from "./configFile.ts";
import { command as codeAction } from "./codeAction.ts";
import { command as line } from "./line.ts";
import { command as implementation } from "./implementation.ts";
import { command as refenrece } from "./reference.ts";
import { command as gitStatus } from "./gitStatus.ts";
import { command as ghq } from "./ghq.ts";
import { command as plugin } from "./plugin.ts";
import { command as gitBranch } from "./gitBranch.ts";
import { command as resume } from "./resume.ts";
import { command as gitLog } from "./gitLog.ts";

export type Command = {
  name: string;
  exec: (denops: Denops) => Promise<Partial<DduOptions>> | Partial<DduOptions>;
  /**
   * Keymaps of itemActions
   */
  itemActions?: Record<string, string>;
};

export async function addCommand(denops: Denops) {
  const commands = [
    file,
    buffer,
    rg,
    grepHelp,
    mrw,
    helpTag,
    configFile,
    codeAction,
    line,
    implementation,
    refenrece,
    gitStatus,
    ghq,
    plugin,
    gitBranch,
    resume,
    gitLog,
  ];

  await defCommand(denops, commands);
}

async function defCommand(denops: Denops, commands: Command[]) {
  denops.dispatcher = {
    ...denops.dispatcher,
    ["ddu:exec"]: async (command: unknown) => {
      if (!is.String(command)) {
        await echoerr(denops, "string argument is expeceted.");
        return;
      }
      const exec = denops.dispatcher[`ddu:${command}:exec`];
      if (exec == null) {
        await echoerr(denops, `Command "${command}" is not found.`);
        return;
      }
      await exec();
    },
  };

  denops.dispatcher = {
    ...denops.dispatcher,
    ["ddu:complete"]: () => {
      return commands.map((c) => (c.name)).join("\n");
    },
  };

  await denops.cmd(
    [
      "function! DduCmdlineComplete(...) abort",
      `return denops#request('${denops.name}', 'ddu:complete', [])`,
      "endfunction",
    ].join("\n"),
  );

  await denops.cmd(
    [
      "command",
      "-nargs=1",
      "-complete=custom,DduCmdlineComplete",
      "Ddu",
      `call denops#notify('${denops.name}', 'ddu:exec', [<f-args>])`,
    ].join(" "),
  );

  for (const command of commands) {
    addDispatcher(denops, command);
  }
}

function addDispatcher(denops: Denops, command: Command) {
  const nmap = async (keys: string, itemAction: string) => {
    await map(
      denops,
      keys,
      `<Cmd>call ddu#ui#do_action('itemAction', #{ name: '${itemAction}' })<CR>`,
      { mode: "n", buffer: true, nowait: true },
    );
  };

  denops.dispatcher = {
    ...denops.dispatcher,
    [`ddu:${command.name}:exec`]: async () => {
      await autocmd.define(
        denops,
        "FileType",
        "ddu-ff",
        `call denops#request('${denops.name}', 'ddu:${command.name}:mapKeys', [])`,
        { once: true },
      );
      await denops.dispatch("ddu", "start", await command.exec(denops));
    },
    [`ddu:${command.name}:mapKeys`]: async () => {
      for (const keys in command.itemActions) {
        await nmap(keys, command.itemActions[keys]);
      }
    },
  };
}
