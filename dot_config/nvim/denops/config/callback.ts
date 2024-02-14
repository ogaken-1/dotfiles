import { Denops, is, uuid1 } from "../deps.ts";

/**
 * callbackはSerialize/Deserialize可能な引数しか受けとれないので注意
 */
export async function denopsCallback(
  denops: Denops,
  callback: (args: unknown[]) => unknown,
) {
  const method = `callback:${uuid1.generate()}`;
  denops.dispatcher = {
    ...denops.dispatcher,
    [method]: async (...args: unknown[]) => {
      return await callback(args);
    },
  };

  const callbackId = await denops.eval(
    `denops#callback#register({ ... -> denops#request('${denops.name}', '${method}', a:000) })`,
  );

  if (!is.String(callbackId)) {
    throw new Error("denops#callback#register() returned not string value.");
  }

  return callbackId;
}
