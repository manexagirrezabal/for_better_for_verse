<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:prosody="http://staging.prosody.lib.virginia.edu" xmlns:TEI="http://www.tei-c.org/ns/1.0"
    xmlns="http://www.w3.org/1999/xhtml" version="2.0">

    <xsl:output indent="no" method="xml" omit-xml-declaration="yes"/>
    <xsl:strip-space elements="*"/>

    
	<xsl:template match="/">
        <div id="poem">
            <div id="title">
                <h2>
                    <xsl:apply-templates
                        select="/TEI:TEI/TEI:teiHeader/TEI:fileDesc/TEI:titleStmt/TEI:title"/>
                </h2>
                <xsl:if test="/TEI:TEI/TEI:teiHeader/TEI:fileDesc/TEI:titleStmt/TEI:author">
                    <h4>
                        <xsl:apply-templates
                            select="/TEI:TEI/TEI:teiHeader/TEI:fileDesc/TEI:titleStmt/TEI:author"/>
                    </h4>
                </xsl:if>
            </div>
            
                <xsl:apply-templates select="TEI:TEI/TEI:text/TEI:body/*"/>
            
        </div>
        <button id="toggle-discrepancies" value="off" onclick="toggledifferences(this)">Toggle
            metrical discrepancies</button>
    </xsl:template>

    <xsl:template match="TEI:lg">

        <xsl:for-each select="TEI:l">
            <xsl:apply-templates select=".">
                <xsl:with-param name="linegroupindex" select="position()"/>
            </xsl:apply-templates>
        </xsl:for-each>
        <!-- <br/> -->
    </xsl:template>

    <xsl:template match="TEI:l">
        <xsl:param name="linegroupindex"/>
        <xsl:variable name="line-number" select="@n"/>

        <table><tbody class="prosody:line">
            <!-- first cycle through the segments, constructing shadow syllables -->
            <tr class="prosody-shadowline" id="prosody:shadow:{$line-number}">
                <xsl:copy-of select="@*"/>
                <xsl:for-each select="TEI:seg">

                    <xsl:variable name="seg-position" select="position()"/>

                    <xsl:for-each select="text()|*/text()">
                        <xsl:variable name="foot-position" select="position()"/>
                        <xsl:variable name="foot-last" select="last()"/>
                        <xsl:for-each select="tokenize(string(.),' ')">
                            <xsl:if test="string(.)">
                                <td class="prosody-shadowsyllable" shadow=""
                                    id="prosody:shadow:{$line-number}:{$seg-position}:{$foot-position}:{position()}"
                                    onclick="switchstress(this);">
                                    <span class="prosody-placeholder">
                                        <xsl:copy-of select="string(.)"/>
                                    </span>
                                </td>
                            </xsl:if>
                        </xsl:for-each>
                    </xsl:for-each>
                </xsl:for-each>
            </tr>

            <tr class="TEI-l" id="prosody:real:{$line-number}">

                <xsl:copy-of select="@*"/>

                <span style="display:none;" linegroupindex="{$linegroupindex}" answer="{../@met}"
                    >Meter</span>

                <xsl:for-each select="TEI:seg">
                    <!-- if the following flag gets set, this indicates that there is a discrepancy in the line which must be later
                        highlighted -->
                    <xsl:variable name="discrepant-flag" select="exists(@real) and exists(@met)"/>

                    <!-- if the following flag gets set, this indicates that there is a sb element in the line and the
                    segment ends with a space -->

                    <xsl:variable name="seg-position" select="position()"/>

                    <xsl:for-each select="text()|*/text()">
                        <xsl:variable name="foot-position" select="position()"/>
                        <xsl:variable name="foot-last" select="last()"/>
                        <xsl:for-each select="tokenize(.,' ')">
                            <xsl:if test="string(.)">
                                <td class="prosody-syllable" real="" stress=""
                                    id="prosody:real:{$line-number}:{$seg-position}:{$foot-position}:{position()}"
                                    onclick="switchfoot('prosody:real:{$line-number}:{$seg-position}:{$foot-position}:{position()}');">
                                    <xsl:if test="$discrepant-flag">
                                        <xsl:attribute name="discrepant"/>
                                    </xsl:if>
                                    <xsl:copy-of select="."/>
                                    <!-- add space back -->

                                    <xsl:if test="not(position()=last())">
                                        <xsl:text> </xsl:text>
                                    </xsl:if>

                                </td>
                            </xsl:if>
                        </xsl:for-each>
                    </xsl:for-each>
                </xsl:for-each>


                <div class="buttons">
                    <xsl:if test="TEI:note">
                        <td class="button">
                            <button class="prosody-note-button" id="displaynotebutton{$line-number}"
                                name="Note about this line" onclick="">
                                <img src="images/blank.gif"/>
                            </button>
                            <p class="prosody-note" id="hintfor{$line-number}">
                                <span>Note on line number <xsl:value-of select="$line-number"
                                    />:</span>
                                <xsl:value-of select="TEI:note"/>
                            </p>
                        </td>
                    </xsl:if>
                    <td class="button">
                        <button class="prosody-checkstress" id="checkstress{$line-number}"
                            name="Check stress" onclick="checkstress({$line-number})">
                            <img src="images/stress-default.png"/>
                        </button>
                    </td>
                    <td class="button">
                        <button class="prosody-checkfeet" id="checkfeet{$line-number}"
                            name="Check feet" onclick="checkfeet({$line-number})">
                            <img src="images/feet-default.png"/>
                        </button>
                    </td>
                    <td class="button">
                        <button class="prosody-meter" id="checkmeter{$line-number}"
                            name="Check meter"
                            onclick="checkmeter({$line-number},{$linegroupindex})">
                            <img src="images/meter-default.png"/>
                        </button>
                    </td>
                </div>
            </tr>
        </tbody></table>
    </xsl:template>

    <xsl:template match="caesura"/>

</xsl:stylesheet>
