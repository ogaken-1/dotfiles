<?xml version="1.0" encoding="UTF-8"?>
<!--
  Check that one origin file agrees with the kind and name its path gives (src/<kinddir>/<name>.xml).
  Parameters: file (path relative to src, for messages), kind (skill | agent | command | memory) and
  name, both derived from the path by lib/origin.nix. No output; fails (xsl:message terminate="yes")
  when the root element, the `key` attribute, `cc:name` or the memory `level` disagrees. The
  attributes and cc:name are optional: only what is written is compared.
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:cc="urn:eunomia:claude-code:v1"
                exclude-result-prefixes="cc">
  <xsl:output method="text" encoding="UTF-8"/>

  <xsl:param name="file" select="'(unknown)'"/>
  <xsl:param name="kind" select="''"/>
  <xsl:param name="name" select="''"/>

  <xsl:template match="/">
    <xsl:variable name="root" select="*"/>
    <xsl:variable name="dir">
      <xsl:choose>
        <xsl:when test="$kind = 'memory'">memory</xsl:when>
        <xsl:otherwise><xsl:value-of select="concat($kind, 's')"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:if test="$kind = '' or $name = ''">
      <xsl:message terminate="yes">check-origin: <xsl:value-of select="$file"/>: the kind and name parameters are required</xsl:message>
    </xsl:if>
    <xsl:if test="not(namespace-uri($root) = 'urn:eunomia:claude-code:v1' and local-name($root) = $kind)">
      <xsl:message terminate="yes">check-origin: <xsl:value-of select="$file"/>: root element cc:<xsl:value-of select="local-name($root)"/> does not match the directory '<xsl:value-of select="$dir"/>' (expected cc:<xsl:value-of select="$kind"/>)</xsl:message>
    </xsl:if>
    <xsl:if test="$root/@key and string($root/@key) != concat($kind, ':', $name)">
      <xsl:message terminate="yes">check-origin: <xsl:value-of select="$file"/>: key '<xsl:value-of select="$root/@key"/>' does not match '<xsl:value-of select="$kind"/>:<xsl:value-of select="$name"/>' derived from the path</xsl:message>
    </xsl:if>
    <xsl:if test="$root/cc:frontMatter/cc:name and string($root/cc:frontMatter/cc:name) != $name">
      <xsl:message terminate="yes">check-origin: <xsl:value-of select="$file"/>: cc:name '<xsl:value-of select="$root/cc:frontMatter/cc:name"/>' does not match the file name '<xsl:value-of select="$name"/>'</xsl:message>
    </xsl:if>
    <xsl:if test="$kind = 'memory' and $root/@level and string($root/@level) != $name">
      <xsl:message terminate="yes">check-origin: <xsl:value-of select="$file"/>: level '<xsl:value-of select="$root/@level"/>' does not match the file name '<xsl:value-of select="$name"/>'</xsl:message>
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>
