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
    <rule>実装前にSerenaメモリを確認</rule>
    <rule>ファイル全体ではなくシンボルレベルの操作を使用</rule>
    <rule>コードコメントは英語</rule>
    <rule>ライブラリドキュメントはContext7で確認</rule>
    <rule>Git操作はユーザーの明示的な要求がある場合のみ</rule>
    <rule>独立タスクは並列実行</rule>
  </rules>
  <related_skills>
    <skill name="plan-workflow">要件定義・計画ワークフロー</skill>
    <skill name="impl-workflow">実装ワークフロー（TDD、サブエージェント委任）</skill>
    <skill name="serena-usage">Serena MCPツールの使用パターン</skill>
    <skill name="context7-usage">Context7 MCPツールの使用パターン</skill>
  </related_skills>
</instructions>

<!-- vim:set ft=xml: -->
