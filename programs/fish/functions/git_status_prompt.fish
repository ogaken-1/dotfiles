function git_status_prompt
  set -l git_status_row (git status -s | string sub -l 2 | sort | uniq)
  for char in $git_status_row
    if [ $char = ' M' ]
      echo -n '!'
    else if [ $char = '??' ]
      echo -n '?'
    else if [ $char = ' D' ]
      echo -n 'x'
    else if [ $char = 'M ' ]
      echo -n '+'
    else if [ $char = 'A ' ]
      echo -n '+'
    end
  end
  printf "\n"
end
