import { Denops, UserSource } from "../deps.ts";

export type Context = {
  sources?: UserSource[];
};

function isContext(x: unknown): x is Context {
  return x != null && typeof x === "object" &&
    (("sources" in x && Array.isArray(x.sources)) || !("sources" in x));
}

export function getContext(denops: Denops): Context | undefined {
  const x = denops.context[denops.name];
  if (!isContext(x)) {
    return;
  }

  return x;
}

export function setContext(denops: Denops, ctx: Partial<Context>) {
  const currentContext = getContext(denops);
  if (currentContext == null) {
    denops.context[denops.name] = ctx;
  } else {
    denops.context[denops.name] = {
      ...currentContext,
      ...ctx,
    };
  }
}
