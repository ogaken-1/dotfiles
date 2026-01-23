---
name: Context7 Usage
description: This skill should be used when the user asks to "check documentation", "latest API", "library docs", "context7", or needs up-to-date library documentation. Provides Context7 MCP usage patterns.
---

<purpose>
  Provide patterns for effective use of Context7 MCP for retrieving up-to-date library documentation.
</purpose>

<tools>
  <tool name="mcp__context7__resolve-library-id">
    <description>Resolve package name to Context7-compatible library ID</description>
    <param name="libraryName">Library name to search for</param>
    <use_case>Must call before mcp__context7__get-library-docs unless ID is known</use_case>
    <note>Returns list of matching libraries with IDs, trust scores, snippet counts</note>
  </tool>
  <tool name="mcp__context7__get-library-docs">
    <description>Fetch documentation for a specific library</description>
    <param name="context7CompatibleLibraryID">Library ID from mcp__context7__resolve-library-id</param>
    <param name="topic">Optional topic to focus on (e.g., "hooks", "routing")</param>
    <param name="tokens">Max tokens to retrieve (default: 5000)</param>
    <use_case>Retrieve up-to-date documentation snippets with code examples</use_case>
  </tool>
</tools>

<concepts>
  <concept name="library_identifiers">
    <description>Common Context7-compatible library IDs: React=/facebook/react, Next.js=/vercel/next.js, TypeScript=/microsoft/typescript, NixOS=/nixos/nixpkgs, Home Manager=/nix-community/home-manager</description>
  </concept>
  <concept name="token_allocation">
    <description>Quick lookup: 2000-3000 tokens; Standard queries: 5000 (default); Comprehensive topics: 8000-10000 tokens</description>
  </concept>
  <concept name="trust_score">
    <description>Quality indicator (1-10); prefer libraries with scores 7+ for reliable documentation</description>
  </concept>
  <concept name="snippet_count">
    <description>Indicator of documentation completeness; higher counts suggest more comprehensive coverage</description>
  </concept>
</concepts>

<patterns>
  <pattern name="specific_feature">
    <description>Use topic parameter to narrow documentation focus and reduce token usage</description>
    <example scenario="For authentication-related documentation">
      <call tool="mcp__context7__get-library-docs">
        <param name="context7CompatibleLibraryID">/supabase/supabase</param>
        <param name="topic">authentication</param>
      </call>
    </example>
    <example scenario="For React hooks documentation">
      <call tool="mcp__context7__get-library-docs">
        <param name="context7CompatibleLibraryID">/facebook/react</param>
        <param name="topic">hooks</param>
      </call>
    </example>
    <example scenario="For routing documentation">
      <call tool="mcp__context7__get-library-docs">
        <param name="context7CompatibleLibraryID">/vercel/next.js</param>
        <param name="topic">routing</param>
      </call>
    </example>
  </pattern>
  <pattern name="getting_started">
    <description>Omit topic parameter for general overview and getting started documentation</description>
    <example scenario="Get React overview">
      <call tool="mcp__context7__get-library-docs">
        <param name="context7CompatibleLibraryID">/facebook/react</param>
      </call>
    </example>
  </pattern>
  <pattern name="api_reference">
    <description>Use topic parameter with specific API names for focused reference documentation</description>
    <example scenario="For specific React hook">
      <call tool="mcp__context7__get-library-docs">
        <param name="context7CompatibleLibraryID">/facebook/react</param>
        <param name="topic">useState</param>
      </call>
    </example>
    <example scenario="For specific Next.js API">
      <call tool="mcp__context7__get-library-docs">
        <param name="context7CompatibleLibraryID">/vercel/next.js</param>
        <param name="topic">getServerSideProps</param>
      </call>
    </example>
    <example scenario="For specific TypeScript utility type">
      <call tool="mcp__context7__get-library-docs">
        <param name="context7CompatibleLibraryID">/microsoft/typescript</param>
        <param name="topic">Partial</param>
      </call>
    </example>
  </pattern>
  <pattern name="verify_usage">
    <description>Verify codebase usage against latest documentation by combining Serena and Context7</description>
    <example scenario="Verify useState usage against latest React docs">
      <step order="1" description="Use Serena to find current library usage in codebase">
        <call tool="mcp__serena__find_symbol">
          <param name="name_path_pattern">useState</param>
        </call>
      </step>
      <step order="2" description="Use Context7 to get latest documentation">
        <call tool="mcp__context7__get-library-docs">
          <param name="context7CompatibleLibraryID">/facebook/react</param>
          <param name="topic">useState</param>
        </call>
      </step>
      <step order="3" description="Compare current usage with documented best practices">
        <note>Manual comparison step</note>
      </step>
    </example>
  </pattern>
  <pattern name="update_dependencies">
    <description>Plan dependency updates with API migration by checking latest documentation</description>
    <example scenario="Plan Next.js migration">
      <step order="1" description="Use Context7 to check latest API changes">
        <call tool="mcp__context7__get-library-docs">
          <param name="context7CompatibleLibraryID">/vercel/next.js</param>
          <param name="topic">migration</param>
        </call>
      </step>
      <step order="2" description="Use Serena to find all usages of changed APIs">
        <call tool="mcp__serena__find_referencing_symbols">
          <param name="name_path">getStaticProps</param>
          <param name="relative_path">src</param>
        </call>
      </step>
      <step order="3" description="Plan migration based on documentation">
        <note>Manual planning step based on documentation analysis</note>
      </step>
    </example>
  </pattern>
  <decision_tree name="tool_selection">
    <question>What type of operation is needed?</question>
    <branch condition="Library name unknown">Use mcp__context7__resolve-library-id to find library</branch>
    <branch condition="Library ID known">Use mcp__context7__get-library-docs directly</branch>
    <branch condition="Specific API/feature">Use mcp__context7__get-library-docs with topic parameter</branch>
    <branch condition="General overview">Use mcp__context7__get-library-docs without topic</branch>
    <branch condition="Quick lookup">Use mcp__context7__get-library-docs with 2000-3000 tokens</branch>
    <branch condition="Comprehensive search">Use mcp__context7__get-library-docs with 8000-10000 tokens</branch>
  </decision_tree>
</patterns>

<anti_patterns>
  <avoid name="skipping_resolution">
    <description>Calling mcp__context7__get-library-docs without resolving library ID first</description>
    <instead>Always call mcp__context7__resolve-library-id to get the correct Context7-compatible library ID</instead>
  </avoid>
  <avoid name="excessive_tokens">
    <description>Requesting maximum tokens for simple queries</description>
    <instead>Use specific topics and appropriate token limits (2000-3000 for quick lookups, 5000 for standard queries)</instead>
  </avoid>
  <avoid name="ignoring_trust_scores">
    <description>Using libraries with low trust scores or snippet counts</description>
    <instead>Prefer libraries with trust scores 7-10 and higher snippet counts for better documentation quality</instead>
  </avoid>
  <avoid name="wrong_library_name">
    <description>Using incorrect or outdated library names (e.g., "react-query" vs "tanstack/query")</description>
    <instead>Try alternative names or broader search terms if library not found</instead>
  </avoid>
</anti_patterns>

<workflow>
  <phase name="identify">
    <objective>Identify documentation needs</objective>
    <step>1. Determine which library needs documentation</step>
    <step>2. Check if library ID is known or needs resolution</step>
  </phase>
  <phase name="resolve">
    <objective>Resolve library identifier</objective>
    <step>1. Use mcp__context7__resolve-library-id to find the library</step>
    <step>2. Verify the resolved ID matches intended library</step>
  </phase>
  <phase name="fetch">
    <objective>Fetch relevant documentation</objective>
    <step>1. Use mcp__context7__get-library-docs with resolved ID</step>
    <step>2. Specify topic if known for focused results</step>
    <step>3. Adjust tokens parameter for detail level</step>
  </phase>
</workflow>

<best_practices>
  <practice priority="critical">Always resolve library ID before fetching documentation</practice>
  <practice priority="critical">Prefer libraries with trust scores 7-10 for better documentation quality</practice>
  <practice priority="high">Use specific topics to reduce token usage and increase relevance</practice>
  <practice priority="high">Check snippet count as indicator of documentation completeness</practice>
  <practice priority="medium">Use versioned IDs when available for specific version documentation</practice>
</best_practices>

<rules priority="critical">
  <rule>Always resolve library ID before fetching documentation</rule>
  <rule>Verify trust score is 7 or higher before using library documentation</rule>
</rules>

<rules priority="standard">
  <rule>Use specific topics to reduce token usage</rule>
  <rule>Check snippet count for documentation quality indicators</rule>
  <rule>Use versioned IDs when available for specific versions</rule>
  <rule>Combine with Serena for codebase verification workflows</rule>
</rules>

<error_escalation>
  <level severity="low">
    <example>Library not found with exact name</example>
    <action>Note in report, try alternative names, proceed</action>
  </level>
  <level severity="medium">
    <example>Documentation not available for topic</example>
    <action>Document issue, use AskUserQuestion for clarification</action>
  </level>
  <level severity="high">
    <example>Context7 service unavailable</example>
    <action>STOP, present options to user</action>
  </level>
  <level severity="critical">
    <example>Conflicting documentation versions</example>
    <action>BLOCK operation, require explicit user acknowledgment</action>
  </level>
</error_escalation>

<related_agents>
  <agent name="design">Uses Context7 for architecture documentation and API design</agent>
  <agent name="execute">Uses Context7 to verify latest library patterns before implementation</agent>
  <agent name="bug">Uses Context7 to check for known issues and migration guides</agent>
  <agent name="ask">Uses Context7 to answer library-specific questions</agent>
</related_agents>

<related_skills>
  <skill name="serena-usage">Combines with Context7 for codebase verification workflows</skill>
  <skill name="investigation-patterns">Uses Context7 for documentation research</skill>
  <skill name="nix-ecosystem">Uses Context7 for NixOS and Home Manager documentation</skill>
  <skill name="typescript-ecosystem">Uses Context7 for TypeScript and framework documentation</skill>
  <skill name="golang-ecosystem">Uses Context7 for Go library documentation</skill>
  <skill name="rust-ecosystem">Uses Context7 for Rust crate documentation</skill>
</related_skills>

<constraints>
  <must>Verify library ID before fetching documentation</must>
  <must>Specify topic when known for focused results</must>
  <must>Check documentation version matches project requirements</must>
  <avoid>Fetching documentation without verifying library identity</avoid>
  <avoid>Using outdated documentation for current implementations</avoid>
</constraints>
<!-- vim:set ft=xml -->
