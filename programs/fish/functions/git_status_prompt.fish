function git_status_prompt
  # Collect git status codes (first 2 characters of each line)
  set -l git_status_codes (git status -s | string sub -l 2 | sort -u)

  # Flags for each status type
  set -l staged_added 0
  set -l staged_modified 0
  set -l staged_deleted 0
  set -l staged_renamed 0
  set -l unstaged_modified 0
  set -l unstaged_deleted 0
  set -l untracked 0

  # First pass: detect which statuses exist
  for code in $git_status_codes
    # Staged changes (first character)
    switch (string sub -l 1 "$code")
      case 'A'
        set staged_added 1
      case 'M'
        set staged_modified 1
      case 'D'
        set staged_deleted 1
      case 'R'
        set staged_renamed 1
    end

    # Unstaged changes (second character)
    switch (string sub -s 2 -l 1 "$code")
      case 'M'
        set unstaged_modified 1
      case 'D'
        set unstaged_deleted 1
    end

    # Untracked files
    if [ "$code" = '??' ]
      set untracked 1
    end
  end

  # Second pass: output in the specified order

  # Staged (green): A → M → D → R
  if [ $staged_added -eq 1 ]
    sgr color:green 'A'
  end
  if [ $staged_modified -eq 1 ]
    sgr color:green 'M'
  end
  if [ $staged_deleted -eq 1 ]
    sgr color:green 'D'
  end
  if [ $staged_renamed -eq 1 ]
    sgr color:green 'R'
  end

  # Unstaged (yellow): M → D
  if [ $unstaged_modified -eq 1 ]
    sgr color:yellow 'M'
  end
  if [ $unstaged_deleted -eq 1 ]
    sgr color:yellow 'D'
  end

  # Untracked (red): ?
  if [ $untracked -eq 1 ]
    sgr color:red '?'
  end
end
