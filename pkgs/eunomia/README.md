# eunomia: Claude Code 設定管理

Claude Code のスキル・エージェント・コマンド・CLAUDE.md を XML の原本から Nix で生成し、参照切れ・削除済みツールの参照・規範の衝突を `nix flake check` で検出する。

## 何をするものか

Claude Code の設定は Markdown のプロンプトの集まりで、互いに名前で参照し合う（スキルがエージェントへ委任する、CLAUDE.md がツールを禁止する、など）。スキルを消しても参照が残る、ツールが削除される、CLAUDE.md の禁止事項とスキルの前提が矛盾する、といった壊れ方は Markdown のままでは検出できない。

eunomia は次の 3 つをする。

1. 原本（`cc` 名前空間の XML）からプロンプト（`skills/` `agents/` `commands/` `CLAUDE.md`）を生成する。
2. 原本から参照と規範の事実を抽出し、Claude Code の版ごとの事実（プラットフォームプロファイル）と合わせて Datalog（Soufflé、`checks.dl`）で検査する。
3. 生成結果を home-manager の `programs.claude-code` に渡すモジュールを返す。

非目標: LLM が規範を守るかの検証、規範の文言の意味解析。

## 使い方（最小例）

原本は 1 エンティティ 1 ファイルで、置き場所が名前と種類を決める（`src/<kinddir>/<name>.xml`、§原本の置き場所）。`src/skills/hello.xml`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<cc:skill xmlns:cc="urn:eunomia:claude-code:v1">
  <cc:frontMatter>
    <cc:description>Greets the user.</cc:description>
  </cc:frontMatter>
  <cc:prompt>
    <rules>
      <rule><cc:prohibition key="no-plan-mode" invoke="tool:EnterPlanMode">EnterPlanModeは使用禁止</cc:prohibition></rule>
      <rule>Use <cc:useTool ref="tool:Read"/> to read files.</rule>
    </rules>
  </cc:prompt>
</cc:skill>
```

Nix 側（`pkgs` は nixpkgs。flake の出力には出していないので、パスから import する）:

```nix
let
  eunomia = import ./pkgs/eunomia/lib { inherit pkgs; };
  cc = eunomia.mkClaudeConfig {
    src = ./src;
    platform = eunomia.platforms."claude-code-2.1.317";
    memory = null; # memory/user.xml を置かないなら null
  };
in
{
  imports = [ cc.homeManagerModule ]; # home-manager のモジュール
  # flake-parts の perSystem なら: checks = pkgs.lib.mapAttrs' (n: v: pkgs.lib.nameValuePair "claude-code-${n}" v) cc.checks;
}
```

生成物（`cc.prompts`）はこうなる。`skills/hello/SKILL.md`:

```
---
name: "hello"
description: "Greets the user."
---

    <rules>
      <rule>EnterPlanModeは使用禁止</rule>
      <rule>Use Read to read files.</rule>
    </rules>
```

本文は原本の空白をそのまま保つ（先頭と末尾の空行だけ除く）。

このリポジトリ自体の検査は、ルートで `nix flake check`（個別なら `nix build .#checks.<system>.eunomia-rules` など）。

## 構成

```
checks.dl            Soufflé の検査ルール
schema/cc.xsd        原本の XSD
xslt/to-prompt.xsl   原本 -> プロンプト本文
xslt/to-frontmatter.xsl  原本 -> YAML front-matter
xslt/check-origin.xsl  原本がパスから導いた種類・名前と食い違わないかの検査
xslt/to-facts.xsl    原本 -> 事実（XSD で見えない誤りは失敗させる）
lib/default.nix      mkClaudeConfig と platforms（公開 API）
lib/{prompts,facts,profile,yaml}.nix  生成・事実抽出・プロファイル変換・YAML
lib/origin.nix       原本のパス（<kinddir>/<name>.xml）から種類と名前を導く（シェル関数）
lib/validate.nix     パス規約・XSD・パスとの一致の検証（validateOrigins。facts / prompts / checks.schema が共有）
lib/relations.nix    事実の 8 種の relation 名（唯一の定義）
platforms/*.nix      プラットフォームプロファイル（Claude Code の版ごと）
tests/               回帰テスト（flake の checks に eunomia-* として登録）
```

```
src/<kinddir>/<name>.xml ─ パス規約 + xmllint --schema cc.xsd + check-origin.xsl（validateOrigins）▶ check: schema
  ├─ to-prompt.xsl + to-frontmatter.xsl ─▶ cc.prompts ─▶ check: prompts（= cc.prompts）
  └─ to-facts.xsl ─▶ defined / ref / scope_parent / norm / override / mention ─┐
     プロファイル + mcp + permissionsAllow + hooks + extra ─▶ 同 8 種 ─────────┴▶ souffle checks.dl ▶ check: refs
```

## 原本の置き場所

原本の置き場所は `src/<kinddir>/<name>.xml`。エンティティの種類と名前はこのパスだけで決まる。

| kinddir | 種類 | name |
|---|---|---|
| `skills` | skill | ファイル名から `.xml` を除いたもの（`[A-Za-z0-9_.-]+`。`.` と `..` は不可） |
| `agents` | agent | 同上 |
| `commands` | command | 同上 |
| `memory` | memory | `user` か `project`（level に当たる） |

- 次の配置はエラー（`validateOrigins`、つまり `schema` check が `<パス>: <理由>` を表示して失敗する）: kinddir がない・未知、さらに深い階層、name が規則に合わない、memory の name が user / project 以外。
- ルート要素は `cc:skill` / `cc:agent` / `cc:command` / `cc:memory` のまま書く。kinddir と食い違えばエラー。
- ルートの `key`（`<kind>:<name>`）、`cc:frontMatter` の `cc:name`、`cc:memory` の `level` は省略できる。書いた場合はパスから導いた値と一致しなければエラー（`<パス>: key 'skill:bar' does not match 'skill:foo' derived from the path` のように、どのファイルの何が食い違うかを表示する）。
- facts の key、出力先のパス、front-matter の `name`、規範のグローバルキー、memory の既定 scope はすべてパスから導いた値で決まる。`cc:name` を省略した front-matter の `name` はファイル名から出す。
- パスから導いた kind と name は、`lib/origin.nix` のシェル関数が求めて `xsltproc --stringparam` で各 XSLT に渡す（`to-facts.xsl` は `kind` / `name`、`to-frontmatter.xsl` は `name`、`check-origin.xsl` は `kind` / `name`）。
- `src` のルート自体は任意のパスでよい（空白を含んでもよい）。

## 原本の語彙

名前空間 `urn:eunomia:claude-code:v1`。ルートは `cc:skill` / `cc:agent` / `cc:command` / `cc:memory`（§原本の置き場所）。

| 要素 | 内容 |
|---|---|
| `cc:frontMatter` | skill / agent / command に必須。memory には置けない。子要素は `name`（省略可。ファイル名から導く）`description` `model` `memory` `skills` `tools` `disallowedTools` `field`（この順序で固定。`field` は `name` 属性つきで複数可） |
| `cc:prompt` | プロンプト本文。名前空間を持たない任意の要素・テキストを置ける（`<workflow>` `<rules>` など自由）。`cc:phase` や `cc:step` のような cc 要素はない |
| 参照要素 | `cc:useSkill ref="skill:x"`、`cc:useTool ref="tool:x"`、`cc:delegate agent="agent:x" [role="…"]`、`cc:seeAlso ref="<kind>:x"` |
| 規範要素 | `cc:obligation` / `cc:prohibition` / `cc:permission`（§規範モデル） |
| `cc:override` | `over` と `under`（どちらも `<entity key>#<norm key>`） |
| `cc:literal` | 中身をそのまま出力し、未注釈の参照の検査から除外する（§未注釈の参照）。中身はテキストと名前空間なしの要素だけで、cc 要素は置けない。`cc:prompt` と規範要素の中に置ける |

- 参照の値は `<kind>:<name>` の単一値（kind は `skill | agent | command | tool`。`seeAlso` は 4 種すべて可）。カンマ区切りの複数値は XSD で拒否する。複数あるときは要素を並べる。
- front-matter の `skills` / `tools` / `disallowedTools` は `<cc:item ref="…"/>` を並べる（ref として抽出される）。値に改行は含められない。
- `cc:prompt` の中の cc 要素（規範・参照・override）は名前空間なしの要素の深くにも置ける。深い位置の未宣言の cc 要素など XSD で見えない誤りは to-facts.xsl が検出して失敗する（§XSD の限界）。

## 規範モデル

規範要素は `cc:prompt` 内のどこにでも直接置ける（ラッパーは不要）。属性:

| 属性 | 内容 |
|---|---|
| `key` | 必須。ファイル内で一意（`xs:unique`）。書式は小文字英数字とハイフン。グローバルキーは `<entity key>#<norm key>` |
| `invoke` | 対象（`<kind>:<name>`）。省略した規範は検査対象外で、プロンプトの文言になるだけ |
| `actor` | 主体（`agent:<n>`）。省略時は agent エンティティでは自身（`agent:<n>`）、それ以外は `agent:*`（その scope にいる全員） |
| `scope` | 適用範囲（`scope:…`）。省略時はエンティティの既定: skill `scope:skill:<n>`、command `scope:command:<n>`、agent `scope:agent:<n>`、memory `scope:memory:<level>`。明示した scope は既知の scope でなければ `broken_ref`（書き間違いの検出） |

modality は要素名で決まる（obligation = O、prohibition = F、permission = P）。

```xml
<cc:prohibition key="no-enter-plan-mode" actor="agent:main" invoke="tool:EnterPlanMode">EnterPlanModeは使用禁止</cc:prohibition>
<cc:override over="skill:plan-workflow#exit-via-exitplanmode" under="memory:user#no-enter-plan-mode"/>
```

- **scope の包含**（`scope_parent(子, 親)` は「親の規範が子にも及ぶ」）: skill / command の既定 scope は `scope:session` の子。`scope:session` と各エージェントの scope は、プロファイルに従って `scope:memory:user` / `scope:memory:project` の子になる。
- **scope の重なり**: 2 つの scope は「両方が適用される scope c が存在する」とき重なる（`within(c, a)` かつ `within(c, b)`。`within` は反射的なので祖先と子孫の組も含む）。user と project の CLAUDE.md（`scope:memory:user` / `scope:memory:project`）は、どちらも `scope:session` に適用されるので重なる。別々のスキル（`scope:skill:a` と `scope:skill:b`）は共通の適用先がないので重ならない。`within` の基点は、規範が使う scope と `scope_parent` に現れる scope。
- **既知の scope**: エンティティの既定 scope（to-facts.xsl が `defined("scope", …)` を出す）と、`scope_parent` に現れる scope（checks.dl が定義）。規範の明示的な `scope` と `cc:override` の `over` / `under`（規範キー）は ref として出るので、存在しないものは `broken_ref`（種別 `scope` / `norm`）になる。
- **override**: 明示したものだけ有効。推移閉包は取らない。`priority` のような暗黙の優先順位は持たない。
- **actor の一致**: 2 つの actor が等しい、またはどちらかが `agent:*`。省略した actor（`agent:*`）の規範は、その scope にいるすべての actor（サブエージェントを含む）に適用される。
- **conflict**: actor が一致し、同じ target について、scope が重なる 2 つの規範が O と F、または P と F の組で、override で解決されていないもの。義務は前提行為（プロファイルの `requires`）も義務として含意するため、「A の義務」と「A の前提 B の禁止」も衝突する。
- 動作例（`tests/e2e`）: memory の `EnterPlanMode` 禁止と、skill の `ExitPlanMode` 義務は、`requires ExitPlanMode → EnterPlanMode` により衝突する。

## プロンプト生成

`to-prompt.xsl`（本文）と `to-frontmatter.xsl`（front-matter）の規則:

- `cc:prompt` の配下を出力する。名前空間なしの要素・属性・テキスト・コメントはそのまま。
- 規範要素（`cc:obligation` / `cc:prohibition` / `cc:permission`）は中身だけが出力され、要素自体は消える。既存のタグの内側に埋め込めば、移行前のプロンプトとバイト単位で同じになる（`<rule><cc:obligation …>本文</cc:obligation></rule>`）。`tests/prompts` の ask.xml は現行の ask の本文と一致することを確認した原本。
- 参照要素は kind 接頭辞を除いた名前がテキストとして出る（`ref="skill:serena-usage"` → `serena-usage`、`agent="agent:explore"` → `explore`）。`cc:override` は何も出力しない。`cc:literal` は中身だけが出る。
- front-matter は YAML。キー順は `name` `description`、残りは原本の順、最後に `extraFrontMatter`。`to-frontmatter.xsl` は原本由来のキーだけを出し、`---` の区切りと `extraFrontMatter` の連結は `lib/prompts.nix` のシェルが行う（`xsltproc --stringparam` は `'` と `"` を両方含む文字列を受け取れないため）。スカラーは `"` で囲み、`"` `\` と改行・タブ・復帰（`\n` `\t` `\r`）をエスケープする。`skills` / `tools` / `disallowedTools` はフロー形式（`["a", "b"]`）、`field` は `name` 属性をキーにした 1 行になる。
- hooks のようにストアパスを含む値は原本に書かず、`mkClaudeConfig` の `extraFrontMatter."<root key>"` で渡す（Nix の attrset を YAML にする。真偽値と数値は引用符なし、`null` は `null`、空の attrset / リストは `{}` / `[]`）。原本由来のキーと `extraFrontMatter` のキーが重なるとビルドが失敗する（`<root key>: key '<key>' is defined by both the origin and extraFrontMatter`）。

出力先: `skills/<n>/SKILL.md`、`agents/<n>.md`、`commands/<n>.md`、`memory/<n>.md`（front-matter なしで本文のみ）。出力パスが重複する、`extraFrontMatter` のキーに対応する原本がない、といった場合はビルドが失敗する。

## 事実と Soufflé ルール

`to-facts.xsl` が原本から、`lib/profile.nix` がプロファイルと宣言から、次の 8 種の事実（`facts/<relation>.facts`、TSV）を作る。識別子はすべて `kind:name` の完全形。

```
defined(Kind, Name, File)         # 原本のルート / プロファイル / mcp / extra。File は src からの相対パス、プロファイル由来は "claude-code-<版>"、extra は "extra"
                                  # Kind="flag" はプラットフォームのフラグ（commandsAreSkills）。true なら checks.dl が command:<n> から skill:<n> も導出する
                                  # 加えて Kind="norm"（全規範要素のグローバルキー）と Kind="scope"（エンティティの既定 scope。scope_parent の scope は checks.dl が "scope_parent" で定義）
ref(Src, Kind, Name, File)        # 参照要素、front-matter の skills/tools/disallowedTools、permissionsAllow（ツール部分と、Skill(x) / Agent(x) の引数）、hooks の matcher
                                  # 加えて Kind="norm"（cc:override の over/under。Src はルートの key）と Kind="scope"（規範の明示的な @scope。Src は規範のグローバルキー）
scope_parent(Child, Parent)
norm(Key, Modality, Actor, Action, Target, Scope)    # invoke のある規範のみ。Action は常に cc:invoke。Actor の省略は "agent:*"
override(Over, Under)
requires(Act, Pre)                # プロファイル
removed(Name, Successor)          # プロファイル。後継なしは "-"
mention(Src, Name, File)          # 原本。印なしで書かれたツール・スキル・エージェント・コマンドの名前（Name は "tool:<名前>" など完全形）。プロファイル側は常に空
```

`checks.dl` の出力は 4 つ。どれかが空でなければ check は失敗する。

- `broken_ref`: 定義のない参照（削除済みと分かっているものは除く）。種別は `skill` / `agent` / `command` / `tool`（通常の参照）、`norm`（override の規範キー）、`scope`（規範の明示的な scope）、`target`（規範の invoke 先）、`actor`（規範の actor。`agent:*` は除く）。
- `removed_ref`: 削除済みの名前への参照。後継が出るので、タイプミスと仕様変更を見分けられる。
- `conflict`: 衝突した規範の組。内部の `conflict_raw` を `a < b`（辞書順）に正規化して 1 組 1 行で出す。
- `unannotated_ref`: 原本に印（`cc:useTool` など）なしで書かれたツール・スキル・エージェント・コマンドの名前（`mention` そのまま。§未注釈の参照）。

## 未注釈の参照

参照は `cc:useTool` などで印を付けたものだけが検査される。印のないツール名は、旧い名前や削除済みの名前でも検出されない。そこで、原本の `cc:prompt` の中に印なしで書かれたツール名を `unannotated_ref` として列挙し、1 件でもあれば `refs` check を失敗させる。直し方は 2 通り。

- 参照のつもりなら `<cc:useTool ref="tool:Glob"/>` にする（`broken_ref` / `removed_ref` で検査される）。
- 名前そのものを書きたいなら `<cc:literal>Glob</cc:literal>` で囲む（中身はそのまま出力され、検査から除外される）。

**対象**: `cc:prompt` の中の、`cc:literal` の外にある
- テキストノード（`cc:obligation` などの本文を含む）
- 名前空間を持たない要素の属性値（`cc:` 要素の属性、つまり `ref` `key` `invoke` などは対象外）

`cc:frontMatter`（すでに参照として検査される）とコメントは対象外。`to-facts.xsl` が対象のテキストと属性値を（タブと改行を空白に置き換えて）`text\t<src>\t<file>\t<文字列>` / `attr\t…` の行で出し、`lib/facts.nix` の awk が次のトークンを `mention` にする（ツール名の完全形は `tool:<名前>`）。

1. `mcp__[A-Za-z0-9_-]+` に一致するものすべて。
2. プロファイルの `tools` と `removed` のキーで、前後が ASCII の英数字・`_` でないもの（`GlobalConfig` や `Glob_x` の `Glob` は拾わない）。

普通の英単語と区別できない名前（プロファイルの `ambiguousToolNames`。2.1.317: `Read` `Edit` `Write` `Bash` `Agent` `Skill` `Monitor` `Workflow` `Artifact`）は、次の場合だけ検出する。
- テキストでバッククォートに囲まれている（`` `Read` ``）。
- 属性値を `/` `,` 空白で区切った部分のどれかが、その名前と完全に一致する（`name="Write/Edit"`、`name="Bash"`）。

属性値は全体だけでなく、同じ区切りの各部分も調べる。名前が実在するかどうかはここでは見ない（印のない名前は検査の外にあるので、実在していても未注釈として出る）。

### スキル・エージェント・コマンドの名前

ツール名と同じ場所（`cc:prompt` のテキストと、名前空間を持たない要素の属性値。`cc:literal` とコメントは除く）で、次の書き方も未注釈の参照として検出する。`mention` には `skill:<name>` / `agent:<name>` / `command:<name>` の完全形で入る（実在する名前でも、印がなければ報告する）。日本語・英語のパターンの name は `[a-z][a-z0-9_.-]*`（小文字の kebab-case のみ。§既知の制約）、`/<name>` は `[A-Za-z0-9][A-Za-z0-9_.-]*`。

| 書き方 | kind | 検出する条件 |
|---|---|---|
| `<name>スキル` / `<name>エージェント` | skill / agent | 常に。name の直前が ASCII の英数字・`_`・`-` でないこと（英数字が続く場合は、その連なり全体が name になる。`xfeedbackスキル` は `skill:xfeedback`。`_x` `-x` で始まるものは拾わない） |
| `<name>コマンド`、`<name> skill` / `<name> agent` / `<name> command`（英語。単語境界、キーワードは大文字小文字を区別しない） | 同上（`<name>コマンド` は command） | 日本語の `<name>コマンド` も英語と同じ条件（`catコマンド` `findコマンド` のようにシェルのコマンドを指す書き方を拾わないため）。name に `-` を含む、name が src で定義されている、またはプロファイルで定義されている（組み込みスキル・組み込みエージェント）とき。`the skill` や `sub agent` のような一般的な語は拾わない。name 末尾が `.` のもの（文末）も拾わない |
| `/<name>`（スラッシュコマンド） | command（`command:<name>` が src で定義されているとき）、skill（`commandsAreSkills` が true で `skill:<name>` が定義されているとき） | その定義があるときだけ。`/tmp` のようなパスや、直前が英数字・`/`・`.`・`~` のもの（`src/ask`）、直後が `/` のものは拾わない |

直し方は、ツール名と同じく印を付けるか `cc:literal` で囲むかの 2 通り。印は `cc:useSkill`（skill）、`cc:delegate`（agent）、`cc:seeAlso`（どの kind でも）。日本語の書き方は名前の部分だけを置き換えればよく、生成されるテキストは変わらない。

```xml
<!-- 変更前: feedbackスキル が未注釈の参照として報告される -->
<rule>feedbackスキルで記録する</rule>
<!-- 変更後: 参照として検査される（出力は「feedbackスキルで記録する」のまま） -->
<rule><cc:useSkill ref="skill:feedback"/>スキルで記録する</rule>
<!-- エージェントは cc:delegate、コマンドは cc:seeAlso -->
<rule><cc:delegate agent="agent:explore"/>エージェントに委任する</rule>
<rule><cc:seeAlso ref="command:ask"/>コマンドを使う</rule>
```

`/ask` のようなスラッシュ表記は、`/<cc:seeAlso ref="command:ask"/>` のように名前部分だけを置き換えるか、`<cc:literal>/ask</cc:literal>` にする。

`permissions.allow` の `Skill(<x>)` / `Agent(<x>)` の引数は、未注釈の参照とは別に、skill / agent への参照（参照元は `settings:permissions.allow`）として検査する（§Nix API の `permissionsAllow`）。

## 失敗時の表示

`mkClaudeConfig` の `refsReport` と `refs` check が出す形式（ソート済み）:

```
参照切れ: skill:plan-workflow -> skill:ghost (skills/plan-workflow.xml, 種別: skill)
参照切れ: skill:plan-workflow#read-first -> scope:sesion (skills/plan-workflow.xml, 種別: scope)
参照切れ: skill:plan-workflow -> memory:user#no-such-norm (skills/plan-workflow.xml, 種別: norm)
削除済み（後継: tool:Agent）: agent:bad -> tool:Task
削除済み（後継なし）: agent:bad -> tool:TodoWrite
規範の衝突: memory:user#no-enter-plan-mode <-> skill:plan-workflow#exit-via-exitplanmode
未注釈の参照: skill:plan-workflow -> tool:Glob (skills/plan-workflow.xml)
要約: 参照切れ 3 件、削除済み 2 件、規範の衝突 1 件、未注釈の参照 1 件（合計 7 件）
全文は nix log <drv> か、mkClaudeConfig の refsReport をビルドして見る
```

末尾の 2 行は件数の要約と全文の見方。`nix build` は失敗したビルドログの末尾 25 行しか表示しないので、報告が長くても件数が見えるよう最後に置く。問題がなければ報告は空のまま（要約も出ない）。

## プラットフォームプロファイル

Claude Code の仕様に依存する事実を 1 版 1 ファイル（`platforms/claude-code-<版>.nix`）にまとめる。`platforms` はこのディレクトリから自動で作られる。

| フィールド | 内容 |
|---|---|
| `claudeCode` / `probedAt` | 版と調べた日 |
| `tools` | 定義済みツール名 |
| `ambiguousToolNames` | 普通の英単語と区別できないツール名のリスト（省略可）。未注釈の参照の検査で、バッククォート付きのテキストか属性値の部分の完全一致のときだけ検出する（§未注釈の参照）。`tools` か `removed` に含まれる名前だけを書く |
| `removed` | 削除済みツール。値は後継ツール名、`null` は後継なし。2.1.317 は `TodoWrite` `TaskOutput`（後継なし）、`Glob` `Grep`（後継 `Bash`。検索は Bash の find / grep で行う）、`Task`（後継 `Agent`） |
| `builtinSkills` | 組み込みスキル名のリスト（省略可）。`defined("skill", "skill:<n>", <ラベル>)` になる。2.1.317 は 2026-11-12 にメインセッションで確認した 17 個（`code-review` `simplify` など） |
| `commandsAreSkills` | `true`（省略時は false）のとき、カスタムコマンド `command:<n>` を `skill:<n>` としても定義済みにする（Skill ツールからコマンドを呼べるため）。プロファイルは `defined("flag", "commandsAreSkills", <ラベル>)` を出し、`checks.dl` が `command:` を `skill:` に読み替えて導出する（コマンド名は評価時には分からないため） |
| `requires` | `{ act; pre; }` のリスト。`act` は `pre` を前提にする（2.1.317: `ExitPlanMode` → `EnterPlanMode`） |
| `mcpNaming` | `direct` / `plugin` / `connector` の完全名の組み立て関数 |
| `agents` | 組み込みエージェントごとの `userMemory` / `projectMemory`（CLAUDE.md を継承するか）。`null` は未測定で、継承ありとみなす（衝突の見逃しより誤検出を選ぶ） |
| `customAgents` | カスタムエージェント（src の `cc:agent` と `extra.agents`）に当てる同じ組 |

- `autoMemory` はプロファイルに持たない（原本の外で実行時に書かれるため、検査の事実にならない）。
- 生成される事実: `defined`（tools、mcp の完全名、agents のキーと `agent:main`、`builtinSkills`、`commandsAreSkills` のフラグ）、`requires`、`removed`、`scope_parent`（`scope:session` は常に両 memory の子。各エージェントは継承フラグに従う）。組み込みエージェント名は大文字小文字を区別する（`Explore`、`Plan`）。
- 2.1.317 の実測では general-purpose と statusline-setup は継承あり、`Explore` は継承なし。継承はバージョンで変わるため、原本ではなくプロファイルに持たせる。

運用: Claude Code を更新したら新版のプロファイルを複製して作り、`platform` を差し替えて `nix flake check` を実行する。削除されたツールは `removed_ref`、継承の変化は `conflict` の増減として列挙される。原本を直すか、`cc:override` で意図を明示する。

## Nix API

`mkClaudeConfig` の引数:

| 引数 | 内容 |
|---|---|
| `src` | 必須。原本 XML のディレクトリ（再帰的に `*.xml` を読む） |
| `platform` | 必須。`eunomia.platforms."claude-code-<版>"` |
| `mcp` | `{ <server> = { plugin = "hm"; tools = [ … ]; }; }`。`plugin` を指定すると `mcp__plugin_<plugin>_<server>__<tool>`、`connector = true` なら `mcp__claude_ai_<server>__<tool>`、どちらもなければ `mcp__<server>__<tool>` で tool として定義する |
| `permissionsAllow` | `settings.permissions.allow` の値。ツール部分（`Bash(git status *)` なら `Bash`）を ref として検査する。`Skill(<x>)` の引数は skill への参照、`Agent(<x>)` の引数は agent への参照としても検査する（`Skill(execute)` で `execute` が未定義なら `broken_ref`。`Agent(Explore)` は組み込みエージェントなので通る）。引数が名前（`[A-Za-z0-9][A-Za-z0-9_.-]*`）全体でなければ（`Skill(foo:*)`、`Skill(foo *)` など）検査しない |
| `hooks` | `settings.hooks` の値。`matcher`（`\|` 区切り）を ref として検査する |
| `extra` | 原本の外で管理するもの。`extra.<skills\|agents\|commands\|tools\|memory>.<name>` のうち、配置するものだけが defined になる。値が `null` の名前は配置されず、defined にもならない（その名前への参照は `broken_ref`）。`extra.skills.<name> = <path>` はスキルのディレクトリとして `skills/<name>` に、`extra.agents.<name> = <path>` / `extra.commands.<name> = <path>` は Markdown ファイルとして `agents/<name>.md` / `commands/<name>.md` にコピーされる。src 由来の同名の出力とぶつかるとビルド失敗 |
| `extraFrontMatter` | `{ "<root key>" = <attrset>; }`。その原本の front-matter の末尾に YAML で追加する。原本と同じキーを書くとビルド失敗 |
| `memory` | `"user"`（既定）か `null` だけを受け付ける（それ以外は評価時に throw）。`"user"` のとき `memory/user.md` を `~/.claude/CLAUDE.md` にし、`memory/user.xml` が無くて `memory/user.md` が生成されなければ `prompts` のビルドが失敗する。`null` なら CLAUDE.md を触らない。project 用の memory（`memory/project.xml`）は `prompts` に生成するが、home-manager では配置しない |

返り値:

| 名前 | 内容 |
|---|---|
| `prompts` | 生成物の derivation（`skills/` `agents/` `commands/` `memory/`、`extra.skills` / `extra.agents` / `extra.commands` のコピーを含む） |
| `verifiedPrompts` | 検査を通った `prompts`（中身は同じで、`prompts` への symlink）。`schema` / `prompts` と、`refs` と同じ判定（`refsReport` が空であること）に依存し、どれかが失敗すればビルドが失敗する。失敗時のログは `refs` check と同じ報告（件数の要約が末尾）。参照するだけでは何もビルドしない（IFD なし） |
| `facts` | Soufflé に渡した facts ディレクトリ（デバッグ用） |
| `refsReport` | 失敗時の表示形式の報告（問題がなければ空）。検査の指摘があっても、この derivation 自体は失敗しない。ただし原本の検証（`schema`）が失敗しているときは、事実が作れないので `refsReport` もビルドできない |
| `checks` | `{ schema; prompts; refs; }` |
| `enforceChecks`（引数） | 既定 `true`。§配置と検査 |
| `homeManagerModule` | `programs.claude-code.{skills, agentsDir, commandsDir}` と `home.file."<configDir>/CLAUDE.md".source` を設定する（配置元は既定で `verifiedPrompts`） |

### 配置と検査

既定（`enforceChecks = true`）では、`homeManagerModule` は `prompts` ではなく `verifiedPrompts` から配置する。そのため、参照切れ・削除済みの参照・規範の衝突・未注釈の参照・原本の検証エラーがあると、`rake switch`（home-files のビルド）自体が失敗し、ログに `refs` check と同じ報告が出る。`nix flake check` を走らせなくても、検査に通らない設定は配置されない。

- home-manager の評価（`nix eval` で option の値を見る程度）は検査を走らせない。検査が走るのはビルドのときだけ。
- 検査を一時的に無効にして配置したいときは `mkClaudeConfig { …; enforceChecks = false; }` にする。`homeManagerModule` は従来どおり `prompts` から配置する。
- リスク: `enforceChecks = false` では、壊れた設定（存在しないスキルへの参照、衝突する規範、削除済みツールの参照）がそのまま `~/.claude` に入り、実行時に初めて問題になる。`nix flake check` には引き続き検査が残るが、配置を止めない。直したら `true` に戻すこと。

home-manager の `programs.claude-code.memory.source` は廃止され `context` になった。`context` は Nix のパスリテラルのときだけ source として扱われ、ストアパスの文字列を渡すと本文として書かれる。そのため `homeManagerModule` は `home.file` で CLAUDE.md を置く。`settings.permissions.allow` は設定しない（`permissionsAllow` は検査にだけ使う）。

## 検査一覧

mkClaudeConfig が返す `checks`（利用者の設定に対する検査）:

| check | 内容 | 失敗条件 |
|---|---|---|
| `schema` | `src` の全 XML を、パス規約（`<kinddir>/<name>.xml`）、`xmllint --schema cc.xsd`、`check-origin.xsl`（パスとの一致）で検証する derivation（`lib/validate.nix` の `validateOrigins`）。事実抽出とプロンプト生成も同じ derivation に依存するので、検証は 1 回だけ実行される。`src` のルートが空白を含むパスでも扱える | パス規約違反 / invalid / パスと食い違う |
| `prompts` | 生成物（`prompts`）そのもの。生成が通ること自体が検査になる | 変換エラー |
| `refs` | 事実を `checks.dl` で評価 | `broken_ref` / `removed_ref` / `conflict` / `unannotated_ref` が空でない |

このリポジトリの flake の `checks`（`tests/default.nix`、名前は `eunomia-` 付き。eunomia 自身の回帰テスト）:

| check | 内容 |
|---|---|
| `eunomia-rules` | `tests/fixtures/<case>/*.facts` を `checks.dl` で評価し、`tests/expected/<case>/*.csv` と比較（衝突・override 解決・削除済み・エージェント継承・未注釈の参照など）。空になる facts / csv は置かなくてよい |
| `eunomia-schema` | `tests/schema/valid/*.xml` は valid、`invalid/*.xml` は invalid |
| `eunomia-facts` | `tests/facts/<case>` の原本から抽出した事実を期待値と比較（`unannotated` はツール名、`unannotated-names` はスキル・エージェント・コマンド名の未注釈の参照の検出・非検出の網羅。`profile/` があれば手書きのプロファイル事実として渡す） |
| `eunomia-factsErrors` | XSD は通るが to-facts.xsl が拒否すべき原本（`xsl-*.xml`。kind / name は `--stringparam` で渡す）と、XSD が拒否すべき原本（`schema-*.xml`） |
| `eunomia-originErrors` | `tests/origin-errors/<case>` の原本が `validateOrigins` で失敗し、食い違ったファイルと内容が表示される（key / cc:name / level / ルート要素とパスの食い違い、深い階層、未知の kinddir、kinddir なし、不正な name、不正な memory の name） |
| `eunomia-deriveFromPath` | key・`cc:name`・`level` をすべて省略した原本（`tests/derive/omitted-src`）の facts と生成物が、書いた原本（`full-src`）と一致する |
| `eunomia-e2e` | 原本 + 手書きプロファイルの事実を通して衝突を検出（`tests/e2e`） |
| `eunomia-prompts` | 生成プロンプトを `tests/prompts/expected` とバイト単位で比較 |
| `eunomia-profile` | プロファイルから生成した事実を期待値と比較（ワイルドカード等の非検査含む）。カスタムエージェントの scope は本番の経路（`appendCustomAgentScopes`）で付与して確認 |
| `eunomia-spaces` | `src` のルートが空白を含むパスでも、検証・事実抽出・生成が通る |
| `eunomia-mkClaudeConfigOk` | `mkClaudeConfig` の `checks` と出力レイアウト（extra skill、カスタムエージェントの scope） |
| `eunomia-mkClaudeConfigBroken` / `BrokenCheckTail` | 壊れた原本の `refsReport` が期待行と完全一致（末尾 2 行は要約）/ 失敗した refs check の出力も要約で終わる |
| `eunomia-mkClaudeConfigBuiltinSkill` / `CommandsAreSkills` / `realProfileRemoved` | 組み込みスキルへの参照は参照切れにならない / `commandsAreSkills` の true と false / 実プロファイルの `removed` の後継 |
| `eunomia-mkClaudeConfigUnannotated` / `realProfileAmbiguous` | 未注釈の参照が `refsReport` に出て（要約に件数が入り）`refs` check が失敗する / 実プロファイルの `ambiguousToolNames` |
| `eunomia-mkClaudeConfigUnannotatedNames` / `PermissionArgs` | 実プロファイルでのスキル・エージェント・コマンド名の未注釈の参照 / `Skill(x)` `Agent(x)` の引数の参照（未定義は参照切れ、ワイルドカード等は検査しない） |
| `eunomia-cdataRejected` / `cdataPlainOk` | `<` か `&` を含む CDATA の原本は検証で失敗する / 含まない CDATA は通る |
| `eunomia-promptsQuoting` / `eunomia-promptsDuplicateKey` | `extraFrontMatter` に `'` と `"` の両方があっても生成できる / 原本とキーが重なると失敗する |
| `eunomia-yamlRoundTrip` | `toYaml` の出力を YAML パーサで読み戻すと元の値と一致する（制御文字、null、空の要素） |
| `eunomia-mkClaudeConfigNullExtra` / `ExtraPlacement` / `ExtraCollision` | `extra` の null は定義済みにならない / agents・commands のコピーと定義 / 同名の衝突で失敗 |
| `eunomia-mkClaudeConfigMemoryMissing` / `MemoryArg` | memory の原本が無いと `prompts` が失敗する / `memory` 引数は `"user"` か null だけ |
| `eunomia-homeManagerModule` | 固定した home-manager と評価し、CLAUDE.md が本文になっていること、配置内容が `prompts` と同じであることを確認 |
| `eunomia-homeManagerEnforced` | 壊れた原本では option の値が `verifiedPrompts` を指し（評価のみ）、その `verifiedPrompts` のビルドが `refs` と同じ報告（見出し・指摘・末尾の要約）で失敗する |
| `eunomia-homeManagerUnenforced` | 同じ壊れた原本でも `enforceChecks = false` なら配置（home-files）がビルドできる |

## 既知の制約

- **CDATA は保てない**: 原本の CDATA セクションは、生成されたプロンプトでは区切りが消え、中身がテキストとして（`<` は `&lt;`、`&` は `&amp;` に）出力される（XSLT 1.0 のデータモデルに CDATA が無いため）。中身に `<` か `&` を含む CDATA は生成結果が原本と変わるので、`validateOrigins`（`lib/validate.nix`）が原本のテキストを `grep -Pz` で調べて失敗させる。`<` も `&` も含まない CDATA は出力が同じなので許す。XML コメント内の `<![CDATA[` も拾う。
- 検査の対象は `invoke` を持つ規範だけ。それ以外はプロンプトの文言になるだけ。
- 衝突は、actor が一致する（同一、またはどちらかが `agent:*`）同じ target の規範の間でしか検出しない。
- `scope:skill:<n>/phase:<id>` のような細かい scope は、to-facts.xsl が `defined` も `scope_parent` も生成しないため、規範の `scope` に書くと `broken_ref`（種別 `scope`）になる（手書きのファクトか、将来の導出が必要）。
- skill の scope は `scope:session` の下に置いている。サブエージェントがスキルを読み込んだときの適用範囲は表していない。
- override の推移閉包は取らない。衝突ごとに明示が必要。
- **スキル・エージェント・コマンド名の検出は小文字の名前だけ**: `<name>スキル` などの日本語と `<name> skill` などの英語のパターンは、name が `[a-z][a-z0-9_.-]*`（小文字の英字で始まり、大文字を含まない。慣例の kebab-case）のものだけを検出する。`CLIコマンド` `Gitコマンド` `2エージェント` のような語の誤検出を避けるためで、`lintコマンド` は検出される。大文字を含む名前（組み込みエージェントの `Explore` `Plan` など）はこれらのパターンでは検出されず、印を付けるかどうかは書き手に任される（`/<name>` のパターンは定義済みの名前だけを見るので影響を受けない）。
- **XSD の限界**: `cc:prompt` の中は `xs:any`（`##local`、lax）なので、深い位置にある未宣言の cc 要素は XSD では検出できず、to-facts.xsl が検出して失敗する。パスとの食い違い（ルート要素、`key`、`cc:name`、`level`）は XSD では書けないので、`check-origin.xsl` が検査する（`validateOrigins` が呼ぶ）。ファイル内の override の keyref は実現していない（書式の検査のみ。解決は Soufflé 側にもない）。
- **検査しないもの**: `permissionsAllow` のワイルドカード（`*` を含むもの）とサーバ単位の許可（`mcp__<server>`）。`Skill(<x>)` / `Agent(<x>)` の引数のうち、名前として解釈できないもの（`*`、スペース、コロンを含む `Skill(foo:*)` など）。`PreToolUse` / `PostToolUse` / `PostToolUseFailure` / `PermissionRequest` 以外のフックの matcher。名前として解釈できない matcher（正規表現など）。
- プロファイルの正しさは人手の更新に依存する。

## 計画中（未実装）

以下は設計のみで、実装はない（`mkClaudeConfig` は `lrml` / `probe` を返さず、flake にも対応する check はない）。

**LegalRuleML エクスポートと往復一致**: 全原本の規範・override を `norms.lrml.xml`（compact 形式）に出力し、公式 XSD で検証する。さらに、そこから抽出した `norm` / `override` を to-facts.xsl の出力と `sort | diff` して一致を要求し、写像の取りこぼしを検出する。公式 XSD は `pkgs.fetchurl`（ハッシュ固定）で取得し、同梱しない。

対応の案:

| cc | LegalRuleML（compact） |
|---|---|
| 規範要素 | `lrml:PrescriptiveStatement` + `ruleml:Rule` + `lrml:Obligation` / `Prohibition` / `Permission`。本文は `lrml:Paraphrase` |
| `actor` | `ruleml:slot` + `lrml:Bearer` |
| `invoke` | `ruleml:Atom`（`Rel iri="cc:invoke"`、`Ind iri="<target>"`） |
| scope | `ruleml:if` の `cc:inScope` Atom |
| `cc:override` | `lrml:OverrideStatement` + `lrml:Override` |

**独自語彙を原本にする理由（実験の結果）**: OASIS の公式 XSD（`legalruleml-core-spec/v1.0/os/xsd-schema/{compact,normal}/`）を libxml2 2.15.4 の `xmllint --nonet --schema` で検証した。

- 公式 XSD はコンパイルできる（`xml.xsd` の import は XML カタログでローカルに向ける）。
- `lrml-*.xsd` に `xs:any` はない。`lrml:Prohibition` の中に `cc:invoke` を置いても、`lrml:Bearer` の中に `cc:actor` を置いても invalid。拡張点は `ruleml:Data`（`xs:anyType`）で、Atom の引数位置にしか置けない。`lrml:Bearer` は子要素を持てない。
- valid になるもの: 内容が `lrml:Paraphrase` だけの規範、`lrml:OverrideStatement` / `lrml:Override over under`、`lrml:ConstitutiveStatement`（if/then に Atom）、上の対応表の出力形。
- 公式形式を原本にすると、行為をすべて `ruleml:Atom` で書くことになり手書きに向かない。独自語彙なら `invoke` / `actor` に `xs:pattern` を掛けられ、`invoke` の省略で検査対象外の規範も表せる。

**プローブ**: プロファイルの継承表を実機で確かめるコマンド（API を呼ぶので flake check には含めず手動実行）。一時ディレクトリ（ユーザー設定は `CLAUDE_CONFIG_DIR` で向ける）に、乱数の nonce を含む user / project の CLAUDE.md と auto-memory を置き、Read / Grep / Glob / Bash を deny してファイルを読めなくする。メインセッションから各エージェントを起動し、「コンテキストにある `PROBE-` で始まる行を逐語で引用せよ。なければ NONE」と答えさせる。nonce が含まれれば継承あり。LLM の応答には揺れがあるため複数回実行して確かめる。決定的な検査ではない。
