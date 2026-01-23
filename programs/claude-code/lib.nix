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
  # Optional `order` parameter specifies key ordering; remaining keys are appended alphabetically
  toYaml =
    {
      attrs,
      order ? null,
    }:
    let
      allKeys = builtins.attrNames attrs;
      orderedKeys =
        if order == null then
          allKeys
        else
          let
            # Filter order list to only include keys that exist in attrs
            existingOrderedKeys = builtins.filter (k: builtins.hasAttr k attrs) order;
            # Get remaining keys not in order list, sorted alphabetically
            remainingKeys = builtins.filter (k: !(builtins.elem k order)) allKeys;
          in
          existingOrderedKeys ++ remainingKeys;
    in
    builtins.concatStringsSep "\n" (
      map (name: "${name}: ${toYamlValue (builtins.getAttr name attrs)}") orderedKeys
    );
in
{
  inherit toYamlValue toYaml;

  # Build a markdown string with YAML front-matter
  # Usage:
  #   buildMarkdown {
  #     front-matter = { name = "Example"; user-invocable = true; };
  #     body = ./path/to/content.xml;
  #     order = [ "name" "user-invocable" ];  # optional key ordering
  #   }
  buildMarkdown =
    {
      front-matter,
      body,
      order ? null,
    }:
    let
      yaml = toYaml {
        attrs = front-matter;
        inherit order;
      };
      bodyContent = builtins.readFile body;
    in
    "---\n${yaml}\n---\n\n${bodyContent}";
}
