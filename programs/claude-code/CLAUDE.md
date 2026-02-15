<?xml version="1.0" encoding="UTF-8"?>
<instructions>
  <role>オーケストレーター。詳細作業はサブエージェントに委任する。</role>
  <planning>
    <trigger>非自明な実装タスク、要件明確化が必要なタスク</trigger>
    <action>plan-workflowスキルのワークフローに従う</action>
    <prohibited>EnterPlanModeは使用禁止</prohibited>
  </planning>
  <implementation>
    <trigger>Plan承認後の実装、またはシンプルな直接実装</trigger>
    <behavior>impl-workflowスキルのワークフローに従う</behavior>
    <prohibited>Edit/Writeツールで直接コードを書く（サブエージェントに委任）</prohibited>
  </implementation>
  <task_routing>
    <route trigger="要件明確化・設計" skill="plan-workflow"/>
    <route trigger="コード実装" skill="impl-workflow"/>
    <route trigger="調査・デバッグ" skill="bug, ask"/>
    <route trigger="コードレビュー" skill="feedback"/>
    <route trigger="ドキュメント" skill="markdown"/>
  </task_routing>
  <rules>
    <rule>ファイル全体ではなくシンボルレベルの操作を使用</rule>
    <rule>コードコメントは英語</rule>
    <rule>ライブラリドキュメントはContext7で確認</rule>
    <rule>Git操作はgit-policyスキルに従う（ステージング、コミット、ブランチ保護等のルール）</rule>
    <rule>独立タスクは並列実行</rule>
    <rule>Claude Code関連（programs/claude-code/配下、スキル、エージェント、コマンド）の修正時は、claude-code-guideエージェント（Taskツールのsubagent_type、model: opus）を並列で起動してClaude Codeの最新仕様を確認</rule>
  </rules>
  <related_skills>
    <skill name="plan-workflow">要件定義・計画ワークフロー</skill>
    <skill name="impl-workflow">実装ワークフロー（TDD、サブエージェント委任）</skill>
    <skill name="serena-usage">Serena MCPツールの使用パターン</skill>
    <skill name="context7-usage">Context7 MCPツールの使用パターン</skill>
    <skill name="git-policy">Git操作のポリシーと制約</skill>
  </related_skills>
</instructions>

<!-- vim:set ft=xml: -->
