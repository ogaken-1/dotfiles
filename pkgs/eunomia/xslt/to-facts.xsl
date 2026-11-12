<?xml version="1.0" encoding="UTF-8"?>
<!--
  Extract Datalog facts from one eunomia origin file.
  Output: one fact per line, "<relation>\t<col1>\t...". Pass the path relative to src as the "file" string
  parameter, and the kind (skill | agent | command | memory) and the name that the path gives
  (src/<kinddir>/<name>.xml, derived by lib/origin.nix) as "kind" and "name": the entity key, the
  default scope and the memory level all come from them, never from the attributes in the file.
  Whether the file agrees with the path is checked beforehand by check-origin.xsl.
  Fails (xsl:message terminate="yes") on problems the XSD cannot see.
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:cc="urn:eunomia:claude-code:v1"
                exclude-result-prefixes="cc">
  <xsl:output method="text" encoding="UTF-8"/>

  <xsl:param name="file" select="'(unknown)'"/>
  <xsl:param name="kind" select="''"/>
  <xsl:param name="name" select="''"/>

  <xsl:variable name="tab" select="'&#9;'"/>
  <xsl:variable name="nl" select="'&#10;'"/>

  <!-- Local names declared in cc.xsd (space-delimited for contains() lookups). -->
  <xsl:variable name="vocabulary"
    select="' skill agent command memory frontMatter prompt name description model skills tools disallowedTools item field delegate useSkill useTool seeAlso obligation prohibition permission override literal '"/>

  <xsl:template match="/">
    <xsl:variable name="root" select="*"/>
    <xsl:variable name="rootKey" select="concat($kind, ':', $name)"/>

    <!-- ===== Checks ===== -->
    <xsl:if test="$kind = '' or $name = ''">
      <xsl:message terminate="yes">to-facts: <xsl:value-of select="$file"/>: the kind and name parameters are required</xsl:message>
    </xsl:if>
    <xsl:if test="not(namespace-uri($root) = 'urn:eunomia:claude-code:v1' and local-name($root) = $kind)">
      <xsl:message terminate="yes">to-facts: <xsl:value-of select="$file"/>: root element cc:<xsl:value-of select="local-name($root)"/> does not match the kind '<xsl:value-of select="$kind"/>' derived from the path</xsl:message>
    </xsl:if>
    <xsl:for-each select="//cc:*">
      <xsl:if test="not(contains($vocabulary, concat(' ', local-name(), ' ')))">
        <xsl:message terminate="yes">to-facts: <xsl:value-of select="$file"/>: unknown cc element cc:<xsl:value-of select="local-name()"/></xsl:message>
      </xsl:if>
    </xsl:for-each>

    <!-- Default scope of the entity and its parent. A memory's name is its level. -->
    <xsl:variable name="defaultScope">
      <xsl:choose>
        <xsl:when test="$kind = 'memory'"><xsl:value-of select="concat('scope:memory:', $name)"/></xsl:when>
        <xsl:otherwise><xsl:value-of select="concat('scope:', $kind, ':', $name)"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="defaultActor">
      <xsl:choose>
        <xsl:when test="$kind = 'agent'"><xsl:value-of select="$rootKey"/></xsl:when>
        <!-- Omitted actor outside an agent entity: everyone who is in the scope. -->
        <xsl:otherwise>agent:*</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <!-- ===== defined ===== -->
    <xsl:value-of select="concat('defined', $tab, $kind, $tab, $rootKey, $tab, $file, $nl)"/>

    <!-- The entity's default scope is a known scope. Scopes in scope_parent are defined by checks.dl. -->
    <xsl:value-of select="concat('defined', $tab, 'scope', $tab, $defaultScope, $tab, $file, $nl)"/>

    <!-- Every norm element is a defined norm, with or without @invoke (override may point at it). -->
    <xsl:for-each select="//cc:obligation | //cc:prohibition | //cc:permission">
      <xsl:value-of select="concat('defined', $tab, 'norm', $tab, $rootKey, '#', @key, $tab, $file, $nl)"/>
      <xsl:if test="@scope">
        <xsl:value-of select="concat('ref', $tab, $rootKey, '#', @key, $tab, 'scope', $tab, @scope, $tab, $file, $nl)"/>
      </xsl:if>
    </xsl:for-each>

    <!-- ===== scope_parent ===== -->
    <xsl:if test="$kind = 'skill' or $kind = 'command'">
      <xsl:value-of select="concat('scope_parent', $tab, $defaultScope, $tab, 'scope:session', $nl)"/>
    </xsl:if>

    <!-- ===== ref ===== -->
    <xsl:for-each select="//cc:delegate/@agent">
      <xsl:value-of select="concat('ref', $tab, $rootKey, $tab, 'agent', $tab, ., $tab, $file, $nl)"/>
    </xsl:for-each>
    <xsl:for-each select="//cc:useSkill/@ref">
      <xsl:value-of select="concat('ref', $tab, $rootKey, $tab, 'skill', $tab, ., $tab, $file, $nl)"/>
    </xsl:for-each>
    <xsl:for-each select="//cc:useTool/@ref">
      <xsl:value-of select="concat('ref', $tab, $rootKey, $tab, 'tool', $tab, ., $tab, $file, $nl)"/>
    </xsl:for-each>
    <xsl:for-each select="//cc:seeAlso/@ref">
      <xsl:value-of select="concat('ref', $tab, $rootKey, $tab, substring-before(., ':'), $tab, ., $tab, $file, $nl)"/>
    </xsl:for-each>
    <xsl:for-each select="$root/cc:frontMatter/cc:skills/cc:item/@ref">
      <xsl:value-of select="concat('ref', $tab, $rootKey, $tab, 'skill', $tab, ., $tab, $file, $nl)"/>
    </xsl:for-each>
    <xsl:for-each select="$root/cc:frontMatter/cc:tools/cc:item/@ref | $root/cc:frontMatter/cc:disallowedTools/cc:item/@ref">
      <xsl:value-of select="concat('ref', $tab, $rootKey, $tab, 'tool', $tab, ., $tab, $file, $nl)"/>
    </xsl:for-each>

    <!-- ===== norm (only norms with @invoke) ===== -->
    <xsl:for-each select="//cc:obligation[@invoke] | //cc:prohibition[@invoke] | //cc:permission[@invoke]">
      <xsl:variable name="modality">
        <xsl:choose>
          <xsl:when test="local-name() = 'obligation'">O</xsl:when>
          <xsl:when test="local-name() = 'prohibition'">F</xsl:when>
          <xsl:otherwise>P</xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:variable name="actor">
        <xsl:choose>
          <xsl:when test="@actor"><xsl:value-of select="@actor"/></xsl:when>
          <xsl:otherwise><xsl:value-of select="$defaultActor"/></xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:variable name="scope">
        <xsl:choose>
          <xsl:when test="@scope"><xsl:value-of select="@scope"/></xsl:when>
          <xsl:otherwise><xsl:value-of select="$defaultScope"/></xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:value-of select="concat('norm', $tab, $rootKey, '#', @key, $tab, $modality, $tab, $actor, $tab, 'cc:invoke', $tab, @invoke, $tab, $scope, $nl)"/>
    </xsl:for-each>

    <!-- ===== text / attr (candidates of unannotated references) =====
         Every text node of cc:prompt (also inside cc:obligation etc.) and every attribute of a
         namespace-less element, except what is inside cc:literal. Attributes of cc: elements and
         comments are not scanned. facts.nix turns these lines into mention rows. Tabs and
         newlines become spaces so that one fact stays on one line. -->
    <xsl:for-each select="$root/cc:prompt//text()[not(ancestor::cc:literal)][normalize-space(.) != '']">
      <xsl:value-of select="concat('text', $tab, $rootKey, $tab, $file, $tab, translate(., '&#9;&#10;&#13;', '   '), $nl)"/>
    </xsl:for-each>
    <xsl:for-each select="$root/cc:prompt//*[namespace-uri() = ''][not(ancestor::cc:literal)]/@*[normalize-space(.) != '']">
      <xsl:value-of select="concat('attr', $tab, $rootKey, $tab, $file, $tab, translate(., '&#9;&#10;&#13;', '   '), $nl)"/>
    </xsl:for-each>

    <!-- ===== override ===== -->
    <xsl:for-each select="//cc:override">
      <xsl:value-of select="concat('override', $tab, @over, $tab, @under, $nl)"/>
      <xsl:value-of select="concat('ref', $tab, $rootKey, $tab, 'norm', $tab, @over, $tab, $file, $nl)"/>
      <xsl:value-of select="concat('ref', $tab, $rootKey, $tab, 'norm', $tab, @under, $tab, $file, $nl)"/>
    </xsl:for-each>
  </xsl:template>
</xsl:stylesheet>
