<?xml version="1.0" encoding="UTF-8"?>
<!--
  Render the YAML front-matter lines (without the fence lines) of one origin file.
  Key order: name, description, the others in document order. `name` is the "name" string parameter
  (the file name without .xml, derived from the path by lib/origin.nix); cc:name, when written, has
  been checked against it by check-origin.xsl. Only keys that come from the origin are produced;
  the fences and extraFrontMatter are added by lib/prompts.nix.
  Memory entities have no front-matter and produce no output.
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:cc="urn:eunomia:claude-code:v1"
                exclude-result-prefixes="cc">
  <xsl:output method="text" encoding="UTF-8"/>

  <xsl:variable name="nl" select="'&#10;'"/>

  <xsl:param name="name" select="''"/>

  <!-- Replace every occurrence of $from in $text with $to. -->
  <xsl:template name="replace-all">
    <xsl:param name="text"/>
    <xsl:param name="from"/>
    <xsl:param name="to"/>
    <xsl:choose>
      <xsl:when test="contains($text, $from)">
        <xsl:value-of select="substring-before($text, $from)"/>
        <xsl:value-of select="$to"/>
        <xsl:call-template name="replace-all">
          <xsl:with-param name="text" select="substring-after($text, $from)"/>
          <xsl:with-param name="from" select="$from"/>
          <xsl:with-param name="to" select="$to"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise><xsl:value-of select="$text"/></xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Double-quoted YAML scalar; only backslash and double quote are escaped. -->
  <xsl:template name="quote">
    <xsl:param name="text"/>
    <xsl:variable name="backslashed">
      <xsl:call-template name="replace-all">
        <xsl:with-param name="text" select="string($text)"/>
        <xsl:with-param name="from" select="'\'"/>
        <xsl:with-param name="to" select="'\\'"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="escaped">
      <xsl:call-template name="replace-all">
        <xsl:with-param name="text" select="string($backslashed)"/>
        <xsl:with-param name="from" select="'&quot;'"/>
        <xsl:with-param name="to" select="'\&quot;'"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:value-of select="concat('&quot;', $escaped, '&quot;')"/>
  </xsl:template>

  <!-- Flow sequence of names with the kind prefix of @ref removed. -->
  <xsl:template name="flow-items">
    <xsl:text>[</xsl:text>
    <xsl:for-each select="cc:item">
      <xsl:if test="position() &gt; 1"><xsl:text>, </xsl:text></xsl:if>
      <xsl:call-template name="quote">
        <xsl:with-param name="text" select="substring-after(@ref, ':')"/>
      </xsl:call-template>
    </xsl:for-each>
    <xsl:text>]</xsl:text>
  </xsl:template>

  <xsl:template name="scalar-line">
    <xsl:param name="key"/>
    <xsl:param name="value"/>
    <xsl:value-of select="concat($key, ': ')"/>
    <xsl:call-template name="quote"><xsl:with-param name="text" select="$value"/></xsl:call-template>
    <xsl:value-of select="$nl"/>
  </xsl:template>

  <xsl:template match="/">
    <xsl:variable name="fm" select="*/cc:frontMatter"/>
    <xsl:if test="$fm and $name = ''">
      <xsl:message terminate="yes">to-frontmatter: the name parameter is required</xsl:message>
    </xsl:if>
    <xsl:if test="$fm">
      <xsl:call-template name="scalar-line">
        <xsl:with-param name="key" select="'name'"/>
        <xsl:with-param name="value" select="$name"/>
      </xsl:call-template>
      <xsl:call-template name="scalar-line">
        <xsl:with-param name="key" select="'description'"/>
        <xsl:with-param name="value" select="$fm/cc:description"/>
      </xsl:call-template>
      <xsl:for-each select="$fm/*[not(self::cc:name or self::cc:description)]">
        <xsl:choose>
          <xsl:when test="self::cc:skills or self::cc:tools or self::cc:disallowedTools">
            <xsl:value-of select="concat(local-name(), ': ')"/>
            <xsl:call-template name="flow-items"/>
            <xsl:value-of select="$nl"/>
          </xsl:when>
          <xsl:when test="self::cc:field">
            <xsl:call-template name="scalar-line">
              <xsl:with-param name="key" select="string(@name)"/>
              <xsl:with-param name="value" select="."/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="scalar-line">
              <xsl:with-param name="key" select="local-name()"/>
              <xsl:with-param name="value" select="."/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>
