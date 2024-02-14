import { Source as GhqSource } from "https://raw.githubusercontent.com/4513ECHO/ddu-source-ghq/7df8ab95f648ee06f8e3f0e80ee639908dcd2a16/denops/@ddu-sources/ghq.ts";

export class Source extends GhqSource {
  override kind = "git_repo";
}
