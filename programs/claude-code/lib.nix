let
  # Convert a Nix value to YAML format
  toYamlValue =
    value:
    if builtins.isBool value then
      if value then "true" else "false"
    else if builtins.isInt value || builtins.isFloat value then
      toString value
    else
      "\"${value}\"";

  # Convert an attribute set to YAML front-matter lines
  toYaml =
    attrs:
    builtins.attrNames attrs
    |> map (name: "${name}: ${toYamlValue (builtins.getAttr name attrs)}")
    |> builtins.concatStringsSep "\n";
in
{
  inherit toYamlValue toYaml;

  # Build a markdown string with YAML front-matter
  # Usage:
  #   buildMarkdown {
  #     front-matter = { name = "Example"; user-invocable = true; };
  #     body = ./path/to/content.xml;
  #   }
  buildMarkdown =
    {
      front-matter,
      body,
    }:
    let
      yaml = toYaml front-matter;
      bodyContent = builtins.readFile body;
    in
    "---\n${yaml}\n---\n\n${bodyContent}";
}
