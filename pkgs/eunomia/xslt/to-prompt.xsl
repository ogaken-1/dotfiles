<?xml version="1.0" encoding="UTF-8"?>
<!--
  Render the prompt body of one origin file: the descendants of cc:prompt, without the cc vocabulary.
  - Elements without a namespace, their attributes, text and comments are copied as they are.
  - cc:obligation / cc:prohibition / cc:permission: only their content is kept.
  - cc:delegate / cc:useSkill / cc:useTool / cc:seeAlso: the referenced name (kind prefix removed).
  - cc:literal: only its content is kept.
  - cc:override: dropped.
  The output has no XML declaration and no cc namespace declaration; leading and trailing blank lines
  are trimmed by the caller (lib/prompts.nix).
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:cc="urn:eunomia:claude-code:v1"
                exclude-result-prefixes="cc">
  <xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="yes" indent="no"/>

  <xsl:template match="/">
    <xsl:apply-templates select="*/cc:prompt/node()"/>
  </xsl:template>

  <!-- Plain element: re-create it without namespace nodes (xsl:copy would carry xmlns:cc along). -->
  <xsl:template match="*[namespace-uri() = '']">
    <xsl:element name="{local-name()}">
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates select="node()"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="comment()">
    <xsl:copy/>
  </xsl:template>

  <xsl:template match="cc:obligation | cc:prohibition | cc:permission">
    <xsl:apply-templates select="node()"/>
  </xsl:template>

  <xsl:template match="cc:delegate">
    <xsl:value-of select="substring-after(@agent, ':')"/>
  </xsl:template>

  <xsl:template match="cc:useSkill | cc:useTool | cc:seeAlso">
    <xsl:value-of select="substring-after(@ref, ':')"/>
  </xsl:template>

  <!-- Literal content: printed as it is (the unannotated-reference check skips it). -->
  <xsl:template match="cc:literal">
    <xsl:apply-templates select="node()"/>
  </xsl:template>

  <xsl:template match="cc:override"/>

  <xsl:template match="cc:*">
    <xsl:message terminate="yes">to-prompt: unknown cc element cc:<xsl:value-of select="local-name()"/></xsl:message>
  </xsl:template>
</xsl:stylesheet>
