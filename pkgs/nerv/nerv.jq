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

[.[] | select($cutoff == "" or .created_at >= $cutoff)]
| if length == 0 then
  "NO_POSTS"
else
  .[]
  | "\($bold)\(.created_at | sub("\\.[0-9]+Z$"; "Z") | strptime("%Y-%m-%dT%H:%M:%SZ") | mktime + ($tz_offset | tonumber) | strftime("%Y-%m-%d %H:%M:%S") + " " + $tz_name)\($reset) \($cyan)@\(.account.acct)\($reset)\n\(.content | decode_html)\n\($dim)---\($reset)"
end
