import { GhqSource } from "../deps.ts";

export class Source extends GhqSource {
  override kind = "git_repo";
}
