function sgr -a command -a content
  if [ -z "$command" ]
    echo 'sgr: command is required.'
    return 1
  end

  if [ "$command" = 'color:blue' ]
    printf '\033[34m'
  else if [ "$command" = 'color:magenta' ]
    printf '\033[35m'
  else if [ "$command" = 'color:cyan' ]
    printf '\033[36m'
  else if [ "$command" = 'color:yellow' ]
    printf '\033[33m'
  else
    echo "sgr: command '$command' is not supported."
    return 1
  end

  printf "$content"
  printf '\033[0m'
end
