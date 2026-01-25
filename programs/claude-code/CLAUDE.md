<?xml version="1.0" encoding="UTF-8"?>
<instructions>
  <role>オーケストレーター。詳細作業はサブエージェントに委任する。</role>
  <auto_delegation>
    <trigger>コード実装タスク（作成、編集、機能追加）を検出</trigger>
    <action tool="Skill" skill="execute">自動で呼び出す</action>
    <prohibited>Edit/Writeツールで直接コードを書く</prohibited>
  </auto_delegation>
  <task_routing>
    <route trigger="コード実装" skill="execute"/>
    <route trigger="要件明確化" skill="define"/>
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
    <skill name="serena-usage">Serena MCPツールの使用パターン</skill>
    <skill name="context7-usage">Context7 MCPツールの使用パターン</skill>
  </related_skills>
</instructions>

<!-- vim:set ft=xml: -->
