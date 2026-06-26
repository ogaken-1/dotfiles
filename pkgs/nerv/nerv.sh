# shellcheck shell=bash  # shebang is inserted by writeShellApplication
minutes=30
refresh=false
no_images=false
cache_dir="${HOME}/.cache/nerv"
last_id_file="${cache_dir}/last_id"

bold=$'\033[1m'
cyan=$'\033[36m'
dim=$'\033[2m'
reset=$'\033[0m'

_jq_exit_file=""
_cleanup() {
  [[ -n "$_jq_exit_file" ]] && rm -f "$_jq_exit_file"
}
trap '_cleanup' INT TERM EXIT

usage() {
  cat <<EOF
Usage: nerv [-m N] [-r] [-I] [-h]

Fetch recent posts from unnerv.jp.

Options:
  -m, --minutes N   Fetch posts from the last N minutes (default: 30, ignored if cache exists)
  -r, --refresh     Ignore cache and fetch by time range
  -I, --no-images   Do not display images
  -h, --help        Show this help message
EOF
}

check_sixel_support() {
  [[ -t 1 ]] || return 1
  local saved da_response
  saved="$(stty -g </dev/tty)"
  stty -icanon -echo min 0 time 2 </dev/tty
  printf '\033[c' >/dev/tty
  da_response=""
  # shellcheck disable=SC2034  # -d 'c' is the delimiter arg, not a read target
  IFS= read -r -t 1 -d 'c' da_response </dev/tty || true
  # Drain any remaining DA response bytes to prevent them leaking into the shell prompt
  while IFS= read -r -N 1 -t 0.05 _ </dev/tty 2>/dev/null; do :; done || true
  stty "$saved" </dev/tty
  local sixel_re='[?;]4(;|$)'
  [[ "$da_response" =~ $sixel_re ]]
}

display_image() {
  local url="$1" tmpfile
  tmpfile="$(mktemp)"
  if curl -sf --max-time 10 --connect-timeout 5 "$url" -o "$tmpfile" 2>/dev/null; then
    img2sixel "$tmpfile" 2>/dev/null || true
  fi
  rm -f "$tmpfile"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -m | --minutes)
      if [[ -z "${2-}" ]]; then
        echo "Error: -m/--minutes requires a numeric argument" >&2
        usage >&2
        exit 1
      fi
      minutes="$2"
      shift 2
      ;;
    -r | --refresh)
      refresh=true
      shift
      ;;
    -I | --no-images)
      no_images=true
      shift
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

mkdir -p "$cache_dir"

api="https://unnerv.jp/api/v1/timelines/public?local=true&limit=40"
last_id=""

if [[ "$refresh" == false && -f "$last_id_file" ]]; then
  last_id="$(<"$last_id_file")"
  if [[ -n "$last_id" ]]; then
    api="${api}&since_id=${last_id}"
  fi
fi

response="$(curl -sf --compressed "$api" 2>/dev/null)" || {
  echo "Error: Failed to fetch from API." >&2
  exit 1
}

error_msg="$(echo "$response" | jq -r 'if type == "object" then .error // empty else empty end')"
if [[ -n "$error_msg" ]]; then
  echo "Error: API returned an error: ${error_msg}" >&2
  exit 1
fi

# Update last_id with the newest post ID (first element in array)
new_id="$(echo "$response" | jq -r '.[0].id // empty')"
if [[ -n "$new_id" ]]; then
  echo "$new_id" > "$last_id_file"
fi

tz_offset=$(date +%z | awk '{h=substr($0,2,2)*3600+substr($0,4,2)*60; print (substr($0,1,1)=="+"?h:-h)}')
tz_name=$(date +%Z)

if [[ -z "$last_id" ]]; then
  cutoff="$(date -u -d "${minutes} minutes ago" +%Y-%m-%dT%H:%M:%S)"
else
  cutoff=""
fi

if [[ "$no_images" == false ]] && ! check_sixel_support; then
  no_images=true
fi

if [[ "$no_images" == false ]] && ! command -v img2sixel &>/dev/null; then
  no_images=true
fi

_jq_exit_file="$(mktemp)"
found_posts=false
# shellcheck disable=SC2154  # nerv_jq is injected by the Nix writeShellApplication wrapper
while IFS= read -r post; do
  found_posts=true
  text="$(echo "$post" | jq -r '.text')"
  printf '%s\n' "$text"
  if [[ "$no_images" == false ]]; then
    while IFS= read -r url; do
      [[ -z "$url" ]] && continue
      display_image "$url"
    done < <(echo "$post" | jq -r '.images[]?')
  fi
  printf '%s---%s\n' "$dim" "$reset"
done < <(echo "$response" | jq -crf "$nerv_jq" \
  --arg cutoff "$cutoff" \
  --arg bold "$bold" \
  --arg cyan "$cyan" \
  --arg reset "$reset" \
  --arg tz_offset "$tz_offset" \
  --arg tz_name "$tz_name"; printf '%d\n' "$?" > "$_jq_exit_file")

_jq_exit="$(cat "$_jq_exit_file")"
rm -f "$_jq_exit_file"
_jq_exit_file=""
if [[ "$_jq_exit" != "0" ]]; then
  echo "Error: Failed to parse posts from API response" >&2
  exit 1
fi

if [[ "$found_posts" == false ]]; then
  if [[ -z "$last_id" ]]; then
    echo "No posts in the last ${minutes} minutes."
  else
    echo "No new posts since last check."
  fi
fi
