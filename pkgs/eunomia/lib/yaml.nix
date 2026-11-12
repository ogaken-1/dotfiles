# YAML front-matter rendering, ported from programs/claude-code/lib.nix (toYaml).
# Differences from the original: scalars escape backslashes and control characters (newline, tab,
# carriage return) as well as double quotes, null is rendered as `null`, and empty attrsets / lists
# (also as list elements) are rendered as `{}` / `[]`.
let
  # A non-empty attrset, or a list that has at least one non-empty attrset, needs block style.
  isBlockValue =
    value:
    (builtins.isAttrs value && value != { })
    || (builtins.isList value && builtins.any (item: builtins.isAttrs item && item != { }) value);

  # Double-quoted YAML scalar. A raw newline would be folded into a space by the parser, so every
  # character that is special inside double quotes is escaped.
  quote =
    string:
    "\"${
      builtins.replaceStrings
        [
          "\\"
          "\""
          "\n"
          "\t"
          "\r"
        ]
        [
          "\\\\"
          "\\\""
          "\\n"
          "\\t"
          "\\r"
        ]
        string
    }\"";

  # Convert a scalar Nix value to inline YAML
  scalarToYaml =
    value:
    if value == null then
      "null"
    else if builtins.isBool value then
      if value then "true" else "false"
    else if builtins.isInt value then
      toString value
    else if builtins.isFloat value then
      # toString would give "1.500000"
      builtins.toJSON value
    else
      quote value;

  # Inline (flow) rendering of any value that is not rendered in block style.
  flowValue =
    value:
    if builtins.isList value then
      "[${map flowValue value |> builtins.concatStringsSep ", "}]"
    else if builtins.isAttrs value then
      if value == { } then
        "{}"
      else
        "{${
          builtins.attrNames value
          |> map (name: "${name}: ${flowValue (builtins.getAttr name value)}")
          |> builtins.concatStringsSep ", "
        }}"
    else
      scalarToYaml value;

  # Render any block value (non-empty attrset or list holding attrsets) at given indentation
  blockValue =
    indent: value:
    if builtins.isAttrs value then
      blockMapping indent value
    else
      blockSequence indent value;

  # One `key: value` entry. `prefix` starts the first line; `childIndent` is the indentation of a block value.
  entry =
    prefix: childIndent: name: value:
    if isBlockValue value then
      "${prefix}${name}:\n${blockValue childIndent value}"
    else
      "${prefix}${name}: ${flowValue value}";

  # Render an attrset as YAML block mapping
  blockMapping =
    indent: attrs:
    builtins.attrNames attrs
    |> map (name: entry indent (indent + "  ") name (builtins.getAttr name attrs))
    |> builtins.concatStringsSep "\n";

  # Render a list as YAML block sequence
  blockSequence =
    indent: items: map (renderItem indent) items |> builtins.concatStringsSep "\n";

  renderItem =
    indent: item:
    if builtins.isAttrs item && item != { } then
      let
        contentIndent = indent + "  ";
        allAttrs = builtins.attrNames item;
        # Sort attrs: scalar values first, block values last (improves readability)
        scalarAttrs = builtins.filter (name: !(isBlockValue (builtins.getAttr name item))) allAttrs;
        blockAttrs = builtins.filter (name: isBlockValue (builtins.getAttr name item)) allAttrs;
        attrs = scalarAttrs ++ blockAttrs;
        render = prefix: name: entry prefix (contentIndent + "  ") name (builtins.getAttr name item);
      in
      builtins.concatStringsSep "\n" (
        [ (render "${indent}- " (builtins.head attrs)) ]
        ++ map (render "${indent}  ") (builtins.tail attrs)
      )
    else
      "${indent}- ${flowValue item}";

  # Convert a top-level attrset to a YAML mapping string (no trailing newline)
  toYaml = attrs: blockMapping "" attrs;
in
{
  inherit toYaml scalarToYaml;
}
