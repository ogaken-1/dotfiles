minutes=30
refresh=false
cache_dir="${HOME}/.cache/nerv"
last_id_file="${cache_dir}/last_id"

bold=$'\033[1m'
cyan=$'\033[36m'
dim=$'\033[2m'
reset=$'\033[0m'

usage() {
  cat <<EOF
Usage: nerv [-m N] [-r] [-h]

Fetch recent posts from unnerv.jp.

Options:
  -m, --minutes N   Fetch posts from the last N minutes (default: 30, ignored if cache exists)
  -r, --refresh     Ignore cache and fetch by time range
  -h, --help        Show this help message
EOF
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

result="$(echo "$response" | jq -rf "$nerv_jq" \
  --arg cutoff "$cutoff" \
  --arg bold "$bold" \
  --arg cyan "$cyan" \
  --arg dim "$dim" \
  --arg reset "$reset" \
  --arg tz_offset "$tz_offset" \
  --arg tz_name "$tz_name")"

if [[ "$result" == "NO_POSTS" ]]; then
  if [[ -z "$last_id" ]]; then
    echo "No posts in the last ${minutes} minutes."
  else
    echo "No new posts since last check."
  fi
else
  echo "$result"
fi
