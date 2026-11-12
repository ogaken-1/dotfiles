# Origin path convention: src/<kinddir>/<name>.xml. The kind and the name of an entity come from
# the path only; `key`, `cc:name` and `level` in the file are optional and must agree with it.
{
  # Bash function definitions, to be interpolated into the build scripts that loop over the origins
  # (validate, facts, prompts). `eunomia_origin_id <path relative to src>` sets `origin_kind`
  # (skill | agent | command | memory) and `origin_name`, or prints "<path>: <reason>" and returns 1
  # when the path is off the convention.
  shellFunctions = ''
    eunomia_origin_id() {
      local rel=$1 dir rest name
      case "$rel" in
        */*) ;;
        *) echo "$rel: not under a kind directory (expected skills, agents, commands or memory)" >&2; return 1 ;;
      esac
      dir=''${rel%%/*}
      rest=''${rel#*/}
      case "$dir" in
        skills) origin_kind=skill ;;
        agents) origin_kind=agent ;;
        commands) origin_kind=command ;;
        memory) origin_kind=memory ;;
        *) echo "$rel: unknown kind directory '$dir' (expected skills, agents, commands or memory)" >&2; return 1 ;;
      esac
      case "$rest" in
        */*) echo "$rel: nested directories are not allowed (expected $dir/<name>.xml)" >&2; return 1 ;;
      esac
      name=''${rest%.xml}
      case "$name" in
        "" | . | .. | *[!A-Za-z0-9_.-]*)
          echo "$rel: invalid name '$name' (allowed: [A-Za-z0-9_.-]+, not . or ..)" >&2
          return 1
          ;;
      esac
      if [ "$origin_kind" = memory ] && [ "$name" != user ] && [ "$name" != project ]; then
        echo "$rel: memory name must be 'user' or 'project' (got '$name')" >&2
        return 1
      fi
      origin_name=$name
    }
  '';
}
