function osc_133 -a contents
  if [ -z "$contents" ]
    echo 'osc_133: usage: osc_133 <contents>'
    return 1
  end
  printf '\033]133;%s\007' $conents
end
