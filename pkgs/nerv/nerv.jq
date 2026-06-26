def decode_html:
  gsub("<br\\s*/?>|</p>|</div>"; "\n")
  | gsub("<[^>]*>"; "")
  | gsub("&#39;"; "'")
  | gsub("&amp;"; "&")
  | gsub("&lt;"; "<")
  | gsub("&gt;"; ">")
  | gsub("&quot;"; "\"")
  | gsub("&nbsp;"; " ")
  | gsub("&#[0-9]+;"; "")
  | gsub("&#x[0-9a-fA-F]+;"; "")
  | ltrimstr("\n")
  | rtrimstr("\n");

def format_timestamp:
  sub("\\.[0-9]+Z$"; "Z")
  | strptime("%Y-%m-%dT%H:%M:%SZ")
  | mktime + ($tz_offset | tonumber)
  | strftime("%Y-%m-%d %H:%M:%S") + " " + $tz_name;

def format_header:
  "\($bold)\(.created_at | format_timestamp)\($reset) \($cyan)@\(.account.acct)\($reset)";

[.[] | select($cutoff == "" or .created_at >= $cutoff)]
| if length == 0 then
  empty
else
  .[]
  | {
      text: "\(format_header)\n\(.content // "" | decode_html)",
      images: [.media_attachments[]? | select(.type == "image") | (.preview_url // .url)]
    }
end
