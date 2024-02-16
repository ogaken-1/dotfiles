function dotnet-rmproj
  for project in (dotnet sln list | tail -n +3 | fzf -m)
     dotnet sln remove "$project"
  end
end
