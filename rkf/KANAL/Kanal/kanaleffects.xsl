<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<!-- Mozilla requires output declaration -->
<xsl:output method="html"/>

<xsl:variable name="static">false</xsl:variable>

<!-- Include common components stylesheet -->
<xsl:include href="common.xsl"/>

<!-- Document Template -->
<xsl:template match="/request-response">
    <xsl:variable name="class" select="/request-response/@concept"/>
    <xsl:variable name="root-individual" select="/request-response/@root-individual"/>
    <xsl:variable name="sessionid" select="/request-response/@sessionid"/>
    <HTML>
      <HEAD>
        <TITLE>Expected Effects</TITLE>
        <LINK REL="stylesheet" HREF="/css/stylesheet.css" TYPE="text/css" TITLE="style"/>
        <SCRIPT TYPE="text/javascript" SRC="/javascript/lib/window.js"/>
        <SCRIPT TYPE="text/javascript" SRC="/javascript/lib/tooltip.js"/>
        <SCRIPT TYPE="text/javascript" SRC="/javascript/rkf.js"/>
        <SCRIPT TYPE="text/javascript">
          <xsl:call-template name="parameters-to-javascript-vars"/>
          var sessionid = "<xsl:value-of select="$sessionid"/>";
          var param_sessionid = "<xsl:value-of select="$sessionid"/>";
          var param_class = "<xsl:value-of select="$class"/>";
        </SCRIPT>
      </HEAD>

      <BODY BGCOLOR="WHITE" TEXT="BLACK" LINK="BLUE" VLINK="RED">
        <DIV ID="tooltip" STYLE="position:absolute; visibility:hide; z-index:1;"></DIV>

        <!-- Title -->
        <P CLASS="title">Expected Effects</P>
        <HR NOSHADE="NOSHADE"/>

        <!-- Toolbar -->
        <xsl:call-template name="secondary-toolbar"/>

        <!-- Apply the external templates here -->
        <xsl:apply-templates select="EXPECTED-EFFECTS-DATA"/>

	<!-- Generate the dictionary -->
	<xsl:apply-templates select="dictionary"/>

      </BODY>
    </HTML>
</xsl:template>

<xsl:template name="header">
  <xsl:param name="class" />
  <xsl:param name="root-individual" />
  <xsl:param name="sessionid" />

  <SCRIPT type="text/javascript">

    function showLocation()
    {
	document.form1.slot.selectedIndex=0;
	document.form1.style.display="block";
	document.form2.style.display="none";
    }

    function showStrength()
    {
	document.form2.dummy.selectedIndex=1;
	document.form1.style.display="none";
	document.form2.style.display="block";
    }

    function addEffect(frm)
    {
        var effect = "( " +
		      frm.event_individual.value +
		      " (:triple " +
		      frm.individual1.value + 
		      " " + frm.slot.value +
		      " " + frm.individual2.value 
		      +" ))";
        document.mainform.op.value = "add";
        document.mainform.effect.value = effect;
        document.mainform.submit();
    }

    var effectarr = new Array();
    var numeffects = 0;
    
    function removeEffect(effect) {
        var foundflag=0;
        for(var i=0; i&lt;numeffects; i++) {
           if(effectarr[i]==effect) {foundflag=1;}
           if(foundflag) effectarr[i] = effectarr[i+1];
        }
        numeffects = numeffects - foundflag;
    }

    function storeEffect(effect,box) {
        if(box.checked) {
           effectarr[numeffects] = effect;
           numeffects++;
        } else {
           removeEffect(effect);
        }
    }

    function deleteEffect()
    {
        var effect = "(";
        for(var i=0; i&lt;numeffects; i++) {
           effect += effectarr[i]+" ";
        }
        effect += ")";
        document.mainform.op.value = "delete";
        document.mainform.effect.value = effect;
        document.mainform.submit();
    }

    function goToStart() 
    {
        var addr = "/im?next=accept-process&amp;sessionid=<xsl:value-of select="$sessionid"/>";
        document.location.href=addr;
    }

  </SCRIPT>

  <DIV CLASS="tip">
  <P>Expected effects are specified by selecting two (or
  more) concepts and relationship that is expected to hold
  between them.</P>
  <OL>
    <LI>If you want to specify an effect of an intermediate step instead of the overall scenario, then from the pulldown menu, select the step.</LI> 
    <LI>When done, the expected effect you have specified will be displayed. Select <em>Test Knowledge</em> to use the specified effects.</LI>
  </OL>
  </DIV>
  <HR NOSHADE="NOSHADE"/>
</xsl:template>
   

<xsl:template name="makeExpectedEffectsForm">
  <xsl:param name="class" />
  <xsl:param name="root-individual" />
  <xsl:param name="sessionid" />

  <FORM NAME="form1" style="display:none">
      <xsl:variable name="eventlist"
          select="//request-response/EXPECTED-EFFECTS-DATA/DATA[TYPE='SUBEVENTS']/CONTENT/LIST-ITEM/individual"/>
      <xsl:variable name="placelist"
          select="//request-response/EXPECTED-EFFECTS-DATA/DATA[TYPE='PLACES']/CONTENT/LIST-ITEM/individual"/>
      <xsl:variable name="unitlist"
          select="//request-response/EXPECTED-EFFECTS-DATA/DATA[TYPE='UNITS']/CONTENT/LIST-ITEM/individual"/>

      <!-- Event List -->
      <P>The step for which this effect should hold is
      <xsl:call-template name="makeSelectList">
	   <xsl:with-param name="selectname" select="'event_individual'"/>
	   <xsl:with-param name="list" select="$eventlist"/>
	   <xsl:with-param name="root" select="$root-individual"/>
	   <xsl:with-param name="class" select="$class"/>
      </xsl:call-template>
      </P>

      <!-- The <select list with location selected> of <Unit List> is <Place List> -->
      <P>
      <b>The </b>
      <select name="slot" onChange="showStrength()">
         <option value="location" selected="selected">location</option>
	 <option value="remaining-strength">remaining-strength</option>
      </select>

      <b> Of </b>
      <xsl:call-template name="makeSelectList">
	   <xsl:with-param name="selectname" select="'individual1'"/>
	   <xsl:with-param name="list" select="$unitlist"/>
      </xsl:call-template>

      <b> Is </b>
      <xsl:call-template name="makeSelectList">
	   <xsl:with-param name="selectname" select="'individual2'"/>
	   <xsl:with-param name="list" select="$placelist"/>
      </xsl:call-template>
      </P>

      <P>
        <INPUT TYPE="BUTTON" VALUE=" Add " onClick="javascript:addEffect(form1)"/>
      </P>

   </FORM>
</xsl:template>


<xsl:template name="makePropertyEffectsForm">
  <xsl:param name="class" />
  <xsl:param name="root-individual" />
  <xsl:param name="sessionid" />
  <FORM NAME="form2">

      <xsl:variable name="eventlist"
          select="//request-response/EXPECTED-EFFECTS-DATA/DATA[TYPE='SUBEVENTS']/CONTENT/LIST-ITEM/individual"/>
      <xsl:variable name="unitlist"
          select="//request-response/EXPECTED-EFFECTS-DATA/DATA[TYPE='UNITS']/CONTENT/LIST-ITEM/individual"/>

      <!-- Event List -->
      <P>The step for which this effect should hold is
      <xsl:call-template name="makeSelectList">
	   <xsl:with-param name="selectname" select="'event_individual'"/>
	   <xsl:with-param name="list" select="$eventlist"/>
	   <xsl:with-param name="root" select="$root-individual"/>
	   <xsl:with-param name="class" select="$class"/>
      </xsl:call-template>
      </P>

      <!-- The <select list with location selected> of <Unit List> is <Place List> -->
      <P>
      <b>The </b>
      <select name="dummy" onChange="showLocation()">
         <option value="location">location</option>
	 <option value="remaining-strength" selected="selected">remaining-strength</option>
      </select>

      <b> Of </b>

      <xsl:call-template name="makeSelectList">
	   <xsl:with-param name="selectname" select="'individual1'"/>
	   <xsl:with-param name="list" select="$unitlist"/>
           <xsl:with-param name="remaining-strength" select="'1'"/>
      </xsl:call-template>

      <b> Is </b>
      <SELECT NAME="slot">
        <OPTION VALUE="greater-than">greater-than</OPTION>
        <OPTION VALUE="is-greater-or-equal">is-greater-or-equal</OPTION>
        <OPTION VALUE="is-equal">is-equal</OPTION>
        <OPTION VALUE="less-than">less-than</OPTION>
        <OPTION VALUE="is-less-or-equal">is-less-or-equal</OPTION>
        <OPTION VALUE="is-not-equal">is-not-equal</OPTION>
      </SELECT>
      <span> </span>
      <input type="text" name="individual2"/>
      </P>

      <P>
        <INPUT TYPE="BUTTON" VALUE=" Add " onClick="javascript:addEffect(form2)"/>
      </P>

   </FORM>
</xsl:template>


<xsl:template name="makeSelectList">
  <xsl:param name="selectname"/>
  <xsl:param name="list"/>
  <xsl:param name="root"/>
  <xsl:param name="class"/>
  <xsl:param name="remaining-strength"/>

  <xsl:element name="select">
      <xsl:attribute name="name"><xsl:value-of select="$selectname"/></xsl:attribute>
      <xsl:if test="$root">
	 <xsl:element name="option">
	     <xsl:attribute name="value"><xsl:value-of select="$root"/></xsl:attribute>
	     <xsl:value-of select="$class"/>
	 </xsl:element>
      </xsl:if>

      <xsl:for-each select="$list">
         <xsl:sort order="{'ascending'}" select="@ref"/>
         <xsl:variable name="inst" select="@ref"/>
	 <xsl:element name="option">
             <xsl:choose>
                <xsl:when test="$remaining-strength">
	           <xsl:attribute name="value">(the1 of (the value of (the remaining-strength of <xsl:value-of select="$inst"/>)))</xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
	           <xsl:attribute name="value"><xsl:value-of select="@ref"/></xsl:attribute>
                </xsl:otherwise>
             </xsl:choose>
	     <xsl:apply-templates select="." mode="get-english"/>
	 </xsl:element>
      </xsl:for-each>
  </xsl:element>
</xsl:template>


<xsl:template match="/|*" mode="showEnglish">
    <xsl:for-each select="node()|*">
	<xsl:variable name="val" select="."/>
	<xsl:choose>
		<xsl:when test='parent::node()[text()=$val]'>
			<xsl:value-of select="."/>
		</xsl:when>
		<xsl:when test=".">
			<xsl:apply-templates select="." mode="make-link"/>
		</xsl:when>
	</xsl:choose>
   </xsl:for-each>
</xsl:template>

<xsl:template name="showExpectedEffects">
  <xsl:param name="class"/>
  <xsl:param name="root-individual"/>
  <xsl:param name="sessionid"/>

  <xsl:if test="count(//request-response/EXPECTED-EFFECTS-DATA/DATA[TYPE='EFFECTS']/EFFECT) &gt; 0">
    <HR NOSHADE="NOSHADE"/>
    <b>Currently specified expected effects :</b><br/>
    <form name="effectsform">
       <table>
       <xsl:for-each select="//request-response/EXPECTED-EFFECTS-DATA/DATA[TYPE='EFFECTS']/EFFECT">
	    <xsl:variable name="km" select="./EFFECTKM"/>
            <tr>
            <td>
              <input type="checkbox">
                <xsl:attribute name="onclick">
                  javascript:storeEffect("<xsl:value-of select="normalize-space($km)"/>",this)
                </xsl:attribute>
              </input>
            </td>
	    <td>
              <xsl:apply-templates select="./STEP" mode="showEnglish"/> :
	      <xsl:apply-templates select="./EFFECTENGLISH" mode="showEnglish"/>
            </td>
            </tr>
       </xsl:for-each>
       </table>
       <p>
         <INPUT TYPE="BUTTON" VALUE=" Delete " onClick="javascript:deleteEffect()"/>
       </p>
     </form>
   </xsl:if>
</xsl:template>
     

<xsl:template match="/request-response/EXPECTED-EFFECTS-DATA">
   <xsl:variable name="class" select="parent::node()/@concept"/>
   <xsl:variable name="root-individual" select="parent::node()/@root-individual"/>
   <xsl:variable name="sessionid" select="parent::node()/@sessionid"/>

   <FORM NAME="mainform" ACTION="/imxml" METHOD="GET" style="display:none">
      <xsl:element name="input">
         <xsl:attribute name="type">hidden</xsl:attribute>
         <xsl:attribute name="name">sessionid</xsl:attribute>
         <xsl:attribute name="value"><xsl:value-of select="$sessionid"/></xsl:attribute>
      </xsl:element>
      <xsl:element name="input">
         <xsl:attribute name="type">hidden</xsl:attribute>
         <xsl:attribute name="name">class</xsl:attribute>
         <xsl:attribute name="value"><xsl:value-of select="$class"/></xsl:attribute>
      </xsl:element>
      <xsl:element name="input">
         <xsl:attribute name="type">hidden</xsl:attribute>
         <xsl:attribute name="name">root-individual</xsl:attribute>
         <xsl:attribute name="value"><xsl:value-of select="$root-individual"/></xsl:attribute>
      </xsl:element>
      <input type="hidden" name="next" value="select-coa-expected-effect"/>
      <input type="hidden" name="effect" value=""/>
      <input type="hidden" name="op" value=""/>
   </FORM>

   <FORM NAME="testform" ACTION="/imxml" METHOD="GET" style="display:none">
      <input type="hidden" name="sessionid">
         <xsl:attribute name="value"><xsl:value-of select="$sessionid"/></xsl:attribute>
      </input>
      <input type="hidden" name="class">
         <xsl:attribute name="value"><xsl:value-of select="$class"/></xsl:attribute>
      </input>
      <input type="hidden" name="root-individual">
         <xsl:attribute name="value"><xsl:value-of select="$root-individual"/></xsl:attribute>
      </input>
      <input type="hidden" name="next" value=""/>
      <input type="hidden" name="current" value="display-expected-effects"/>
   </FORM>

   <xsl:call-template name="header">
      <xsl:with-param name="class" select="$class"/>
      <xsl:with-param name="root-individual" select="$root-individual"/>
      <xsl:with-param name="sessionid" select="$sessionid"/>
   </xsl:call-template>

   <xsl:call-template name="makeExpectedEffectsForm">
      <xsl:with-param name="class" select="$class"/>
      <xsl:with-param name="root-individual" select="$root-individual"/>
      <xsl:with-param name="sessionid" select="$sessionid"/>
   </xsl:call-template>

   <xsl:call-template name="makePropertyEffectsForm">
      <xsl:with-param name="class" select="$class"/>
      <xsl:with-param name="root-individual" select="$root-individual"/>
      <xsl:with-param name="sessionid" select="$sessionid"/>
   </xsl:call-template>

   <xsl:call-template name="showExpectedEffects">
      <xsl:with-param name="class" select="$class"/>
      <xsl:with-param name="root-individual" select="$root-individual"/>
      <xsl:with-param name="sessionid" select="$sessionid"/>
   </xsl:call-template>

   <HR NOSHADE="NOSHADE"/>
       <INPUT TYPE="BUTTON" VALUE="Go Back" onClick="goToStart()"/>&#160;
       <INPUT TYPE="BUTTON" VALUE="Test Knowledge" onClick="document.testform.submit()"/>

   <HR NOSHADE="NOSHADE"/>
   <P CLASS="copyright">SHAKEN - Unpublished Copyright (C) 1999-2002, SRI Team</P>
</xsl:template>

</xsl:stylesheet>
