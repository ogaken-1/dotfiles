function sgr -a command -a content
  if [ -z "$command" ]
    echo 'sgr: command is required.'
    return 1
  end

  switch "$command"
    case 'color:yellow'
      printf '\033[33m'
    case 'color:blue'
      printf '\033[34m'
    case 'color:magenta'
      printf '\033[35m'
    case 'color:cyan'
      printf '\033[36m'
    case '*'
      echo "sgr: command '$command' is not supported."
      return 1
  end

  printf "$content"
  printf '\033[0m'
end
