<?xml version="1.0" encoding="ISO-8859-1" standalone="yes"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:template match="/">
		<ul>
			<xsl:for-each select="vip_object/precinct">
				<li>
					Precinct: <xsl:value-of select="name"/>
				</li>
			</xsl:for-each>
		</ul>
	</xsl:template>
</xsl:stylesheet>