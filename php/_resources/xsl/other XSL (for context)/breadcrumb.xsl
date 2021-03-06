<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE xsl:stylesheet SYSTEM "http://commons.omniupdate.com/dtd/standard.dtd">
<!--
Implementations Skeletor v3 - 5/10/2014

BREADCRUMBS 
Assumes that a section properties files is being used to extract section titles. 
If there aren't any props files, the xsl can be modified to check the page title of the index/default page of each section instead.

Example:
<xsl:call-template name="breadcrumb">
	<xsl:with-param name="path" select="$ou:dirname"/>								
</xsl:call-template>

Requires ouvariables.xsl, vars.xsl, and functions.xsl

Contributors: Your Name Here
Last Updated: Enter Date Here
-->
<xsl:stylesheet version="3.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:ou="http://omniupdate.com/XSL/Variables"
	xmlns:fn="http://omniupdate.com/XSL/Functions"
	xmlns:ouc="http://omniupdate.com/XSL/Variables"
	exclude-result-prefixes="ou xsl xs fn ouc">
	
	<!-- if a subfolder has been defined in Access Settings -->
	<xsl:variable name="link-start" select="''"/>	
	<xsl:variable name="breadcrumb-start" select="ou:test-variable($ou:breadcrumb-start,'/')"/>
	
	<xsl:template name="breadcrumb">
		<xsl:param name="path" select="$dirname" /> <!-- defined in the vars xsl as $ou:dirname with a trailing '/' -->
		<xsl:param name="title" select="ou:pcf-param('breadcrumb')" /> <!-- originally defined as $page-title from vars -->	
		
		<!-- begin the recursive template for the crumbs (below) -->
		<!-- check for valid breadcrumbStart to prevent infinite recursion -->
		<xsl:if test="contains($dirname,$breadcrumb-start)">
			<xsl:call-template name="bc-folders">
				<xsl:with-param name="path" select="$dirname"/>
			</xsl:call-template>	
		</xsl:if>
		
		<!-- if the file is not the index page, display the final crumb -->
		<xsl:if test="not(contains($ou:filename,concat($index-file,'.')))">
			<li class="current"><xsl:value-of select="$title" /></li>
		</xsl:if>
	</xsl:template>
	
	<xsl:template name="bc-folders">
		<xsl:param name="path" />
		<!-- The following variables assume that the section breadcrumbs is in a file called '_props.pcf'. With some config the file may be substitued for breadcrumb.xml, index.pcf etc -->
		<xsl:variable name="this-props-path" select="concat($ou:root, $ou:site, $path, $props-file)"/>	<!-- props-file is defined in vars xsl -->
		<xsl:variable name="title">
			<xsl:choose>
				<!-- test if there is a props file before trying to read it -->
				<xsl:when test="doc-available($this-props-path)">
					<xsl:value-of select="document($this-props-path)/document/ouc:properties[@label='config']/parameter[@name='breadcrumb']"/>
				</xsl:when>
				<xsl:otherwise><xsl:if test="$ou:action!='pub'">System Message: Props File Not Found</xsl:if></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:if test="$path != $breadcrumb-start">
			<!-- begin recursive function if the current path doesn't match the root or breadcrumbStart directory variable -->
			<xsl:call-template name="bc-folders">
				<xsl:with-param name="path" select="ou:find-prev-dir($path)"/>
			</xsl:call-template>
		</xsl:if>
		
		<xsl:choose>
			<!-- if the path matches the current directory, and the current page is an index file, then display without an anchor element -->
			<xsl:when test="$path = $dirname and contains($ou:filename,'index.')">
				<li class="current"><xsl:value-of select="$title"/></li>
			</xsl:when>
			<xsl:when test="$path = '/blog/posts/'"><li class="unavailable show-for-medium-up"><a href="{concat($link-start,$path)}"><xsl:value-of select="$title"/></a></li></xsl:when>
			<xsl:otherwise>
				<li><a href="{concat($link-start,$path)}"><xsl:value-of select="$title"/></a></li>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>
