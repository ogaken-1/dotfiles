function sgr -a command -a content
  if [ -z "$command" ]
    echoerr 'sgr: command is required.'
    return 1
  end

  switch "$command"
    case 'color:*'
      set -l colors 'black' 'red' 'green' 'yellow' 'blue' 'magenta' 'cyan' 'white'
      set -l color (echo "$command" | awk -F ':' '{ print $2 }')
      if set -l idx (contains -i "$color" $colors)
        printf '\033[3%dm' (echo "$idx - 1" | bc)
      else
        echoerr "color: '$color' is invalid."
        return 1
      end
    case '*'
      echoerr "sgr: command '$command' is not supported."
      return 1
  end

  printf "$content"
  printf '\033[0m'
end
