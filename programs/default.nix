let
  dir = ./.;
in
builtins.readDir dir
|> builtins.attrNames
|> builtins.filter (name: name != "default.nix")
|> map (name: dir + "/${name}")
