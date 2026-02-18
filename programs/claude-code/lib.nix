let
  # Check if a value needs block-style YAML rendering
  isBlockValue =
    value:
    builtins.isAttrs value
    || (builtins.isList value
      && builtins.length value > 0
      && builtins.isAttrs (builtins.head value));

  # Convert a scalar Nix value to inline YAML
  scalarToYaml =
    value:
    if builtins.isBool value then
      if value then "true" else "false"
    else if builtins.isInt value || builtins.isFloat value then
      toString value
    else
      "\"${builtins.replaceStrings [ "\"" ] [ "\\\"" ] value}\"";

  # Convert a flat list to YAML flow sequence: [a, b, c]
  flowSequence =
    items:
    let
      elements = map scalarToYaml items |> builtins.concatStringsSep ", ";
    in
    "[${elements}]";

  # Render any block value (attrset or list of attrsets) at given indentation
  blockValue =
    indent: value:
    if builtins.isAttrs value then
      blockMapping indent value
    else if builtins.isList value && builtins.length value > 0 && builtins.isAttrs (builtins.head value) then
      blockSequence indent value
    else
      abort "blockValue: expected attrset or list of attrsets";

  # Render an attrset as YAML block mapping
  blockMapping =
    indent: attrs:
    builtins.attrNames attrs
    |> map (
      name:
      let
        val = builtins.getAttr name attrs;
      in
      if isBlockValue val then
        "${indent}${name}:\n${blockValue (indent + "  ") val}"
      else if builtins.isList val then
        "${indent}${name}: ${flowSequence val}"
      else
        "${indent}${name}: ${scalarToYaml val}"
    )
    |> builtins.concatStringsSep "\n";

  # Render a list of attrsets as YAML block sequence
  blockSequence =
    indent: items:
    let
      contentIndent = indent + "  ";
      renderItem =
        item:
        let
          allAttrs = builtins.attrNames item;
          # Sort attrs: scalar values first, block values last (improves readability)
          scalarAttrs = builtins.filter (name: !(isBlockValue (builtins.getAttr name item))) allAttrs;
          blockAttrs = builtins.filter (name: isBlockValue (builtins.getAttr name item)) allAttrs;
          attrs = scalarAttrs ++ blockAttrs;
          firstAttr = builtins.head attrs;
          restAttrs = builtins.tail attrs;
          firstVal = builtins.getAttr firstAttr item;
          firstLine =
            if isBlockValue firstVal then
              "${indent}- ${firstAttr}:\n${blockValue (contentIndent + "  ") firstVal}"
            else if builtins.isList firstVal && !(builtins.length firstVal > 0 && builtins.isAttrs (builtins.head firstVal)) then
              "${indent}- ${firstAttr}: ${flowSequence firstVal}"
            else
              "${indent}- ${firstAttr}: ${scalarToYaml firstVal}";
          restLines = map (
            name:
            let
              val = builtins.getAttr name item;
            in
            if isBlockValue val then
              "${indent}  ${name}:\n${blockValue (contentIndent + "  ") val}"
            else if builtins.isList val && !(builtins.length val > 0 && builtins.isAttrs (builtins.head val)) then
              "${indent}  ${name}: ${flowSequence val}"
            else
              "${indent}  ${name}: ${scalarToYaml val}"
          ) restAttrs;
        in
        builtins.concatStringsSep "\n" ([ firstLine ] ++ restLines);
    in
    map renderItem items |> builtins.concatStringsSep "\n";

  # Convert a top-level attrset to YAML front-matter string
  toYaml =
    attrs:
    builtins.attrNames attrs
    |> map (
      name:
      let
        val = builtins.getAttr name attrs;
      in
      if isBlockValue val then
        "${name}:\n${blockValue "  " val}"
      else if builtins.isList val then
        "${name}: ${flowSequence val}"
      else
        "${name}: ${scalarToYaml val}"
    )
    |> builtins.concatStringsSep "\n";

  # Build a markdown string with YAML front-matter
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
in
{
  inherit toYaml buildMarkdown;
  # Keep backward compatibility
  toYamlValue = scalarToYaml;
}
