<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<!-- Mozilla requires output declaration -->
<xsl:output method="html"/>

<xsl:template name="header">
  <xsl:param name="source" />
  <xsl:param name="sessionid" />

    <LINK REL="stylesheet" HREF="/css/stylesheet.css" TYPE="text/css" TITLE="style"/>

    <SCRIPT TYPE ="text/javascript" SRC ="/javascript/lib/tooltip.js"></SCRIPT>
    <SCRIPT TYPE ="text/javascript" SRC ="/javascript/rkf.js"></SCRIPT>

    <SCRIPT TYPE="text/javascript">
    var sessionid = "<xsl:value-of select="$sessionid"/>";
    var param_class = "<xsl:value-of select="$source"/>";

    function OpenEnterKnowledge(concept, fixnum) {
	 address = "im?sessionid=" + sessionid + "&amp;current=accept-editable-class&amp;class=" + concept;
	 features  = "resizable,scrollbars,alwaysRaised,width=800,height=600" ;
	 window.open(address,"",features) ;

    }

    function createSpecialCase(superclass) {
	 var subclassname = prompt("Please Enter a Name for the Special Case",superclass+"-xxx");
	 if(!subclassname) { return; }
	 subclassname = subclassname.replace(/\s/g,"_");
	 createClass(subclassname,superclass);
    }


    // -------- Instrumentation Code

    var logmessage = "";

    function MD() {
	    logmessage = "";
	    var item = event.srcElement;
	    var ntype = item.nodeName;
	    if(item.type == 'button') {
		logmessage = "Fixes :: clicked on '"+item.parentElement.nextSibling.innerText+"'";
	    }
     }

     function LogIt() {
        if(logmessage) {
  	   var the_iframe = document.getElementById("userfeedback");
	   address = "/im?next=activity-log&amp;sessionid=" + sessionid + "&amp;concept=" + param_class + "&amp;logmessage=" + logmessage;
	   address = address.replace(/amp;/g,'');
	   address = address.replace(/ /g,'+');
	   the_iframe.src = address;
	 }
     }

     document.onmousedown = MD;
     document.onclick = LogIt;

    </SCRIPT>

</xsl:template>

<xsl:template name="format-text">
	<xsl:param name="text"/>
	<xsl:for-each select="$text/node() | $text//@*">
		<xsl:variable name="val" select="."/>
		<xsl:choose>
			<xsl:when test="$text/node()=$val">
				<xsl:call-template name="format-text1" >
					<xsl:with-param name="text" select="."/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="translatefix" >
				      <xsl:with-param name="id" select="." />
				</xsl:call-template>					
			</xsl:otherwise>
		</xsl:choose>
	</xsl:for-each>
</xsl:template>

<xsl:template name="translatefix">
      <xsl:param name="id" />
	<xsl:variable name="eng" select="//FIXES/dictionary//english[parent::node()/@id = $id]"/>	
	<xsl:variable name="highlight" select="$eng/parent::node()/root/individual/@ref"/>
	<a href="javascript:void InspectInstance('{$highlight}','{$id}')"><xsl:value-of select="$eng"/></a> 
</xsl:template>

<xsl:template name="format-text2">
	<xsl:param name="text"/>
	<xsl:variable name="lowercase" select="'abcdefghijklmnopqrstuvwxyz'"/>
	<xsl:variable name="uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>
	<xsl:choose>
		<xsl:when test="contains($text,'KANAL::')">
					
			<xsl:call-template name="format-text1">
				<xsl:with-param name="text" select="concat(substring-before($text,'KANAL::'),substring-after($text,'KANAL::'))"/>
			</xsl:call-template>

		</xsl:when>
		<xsl:when test="contains($text,'(FRAME OF)')">
					
			<xsl:call-template name="format-text1">
				<xsl:with-param name="text" select="concat(substring-before($text,'(FRAME OF)'),substring-after($text,'(FRAME OF)'),'of')"/>
			</xsl:call-template>

		</xsl:when>
		<xsl:when test="contains($text,'{')">
					
			<xsl:call-template name="format-text1">
				<xsl:with-param name="text" select="concat(substring-before($text,'{'),substring-after($text,'{'))"/>
			</xsl:call-template>

		</xsl:when>
		<xsl:when test="contains($text,'}')">
					
			<xsl:call-template name="format-text1">
				<xsl:with-param name="text" select="concat(substring-before($text,'}'),substring-after($text,'}'))"/>
			</xsl:call-template>

		</xsl:when>
		<xsl:otherwise>
			
			<xsl:value-of select="concat($text,' ')"/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template name="format-text1">
	<xsl:param name="text"/>
	<xsl:variable name="lowercase" select="'abcdefghijklmnopqrstuvwxyz'"/>
	<xsl:variable name="uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>
	<xsl:choose>
		<xsl:when test="contains($text,'KANAL::')">
					
			<xsl:call-template name="format-text1">
				<xsl:with-param name="text" select="concat(substring-before($text,'KANAL::'),substring-after($text,'KANAL::'))"/>
			</xsl:call-template>

		</xsl:when>
		<xsl:when test="contains($text,'(FRAME OF)')">
					
			<xsl:call-template name="format-text1">
				<xsl:with-param name="text" select="concat(substring-before($text,'(FRAME OF)'),substring-after($text,'(FRAME OF)'),'of')"/>
			</xsl:call-template>

		</xsl:when>
		<xsl:when test="contains($text,'{')">
					
			<xsl:call-template name="format-text1">
				<xsl:with-param name="text" select="concat(substring-before($text,'{'),substring-after($text,'{'))"/>
			</xsl:call-template>

		</xsl:when>
		<xsl:when test="contains($text,'}')">
					
			<xsl:call-template name="format-text1">
				<xsl:with-param name="text" select="concat(substring-before($text,'}'),substring-after($text,'}'))"/>
			</xsl:call-template>

		</xsl:when>
		<xsl:otherwise>
			
			<xsl:value-of select="concat(translate($text,$uppercase,$lowercase),' ')"/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>


	<xsl:template name="printfix">
		<xsl:param name="fixtype"/>
		<xsl:param name="content"/>

		<xsl:choose>
			<xsl:when test="contains($fixtype,'ADD-STEP') and string-length($fixtype) &lt; string-length('ADD-STEP') + 2">

				Add a step <br/><br/>
				<ul>
					<li> Step details: </li>
					<ul> <li> 
						<xsl:for-each select="$content/LIST-ITEM[position() &gt; 1 and position() &lt; 8]"> 
							<xsl:call-template name="format-text">
							<xsl:with-param name="text" select="."/>
							</xsl:call-template>
						</xsl:for-each>
					</li> </ul>

					<li> Effect of the step: </li>
					<ul> <li> 
						<xsl:for-each select="$content/LIST-ITEM[position() &gt; 8 and position() &lt; 14]"> 
							<xsl:call-template name="format-text">
							<xsl:with-param name="text" select="."/>
							</xsl:call-template>
						</xsl:for-each> 
					</li> </ul>
				</ul>
			</xsl:when>

			<xsl:when test="contains($fixtype,'ADD-STEP-BEFORE-STEP') and string-length($fixtype) &lt; string-length('ADD-STEP-BEFORE-STEP') + 2">
				<xsl:choose>
					<xsl:when test="count($content/LIST-ITEM)=10">
						Add a step <br/><br/>
						<ul>
							<li> Step details: </li>
							<ul> <li> 
								<xsl:for-each select="$content/LIST-ITEM[position() &gt; 1 and position() &lt; 3]"> 	
									<xsl:call-template name="format-text">
									<xsl:with-param name="text" select="."/>
									</xsl:call-template>
								</xsl:for-each>
							</li> </ul>
		
							<li> Step Order: </li>
							<ul> <li> 
								<xsl:for-each select="$content/LIST-ITEM[position() &gt; 2 and position() &lt; 5]"> 
									<xsl:call-template name="format-text">
									<xsl:with-param name="text" select="."/> 
									</xsl:call-template>
								</xsl:for-each>
							</li> </ul>

							<li> Effect of the step: </li>
							<ul> <li> 
								<xsl:for-each select="$content/LIST-ITEM[position() &gt; 5 and position() &lt; 11]"> 
									<xsl:call-template name="format-text">
									<xsl:with-param name="text" select="."/>
									</xsl:call-template>
								</xsl:for-each>
							</li> </ul>
						</ul>
					</xsl:when>
					<xsl:when test="count($content/LIST-ITEM)=15">
						Add a step <br/><br/>
						<ul>
							<li> Step details: </li>
							<ul> <li> 
								<xsl:for-each select="$content/LIST-ITEM[position() &gt; 1 and position() &lt; 8]"> 	
									<xsl:call-template name="format-text">
									<xsl:with-param name="text" select="."/>
									</xsl:call-template>
								</xsl:for-each>
							</li> </ul>
		
							<li> Step Order: </li>
							<ul> <li> 
								<xsl:for-each select="$content/LIST-ITEM[position() &gt; 7 and position() &lt; 10]"> 
									<xsl:call-template name="format-text">
									<xsl:with-param name="text" select="."/> 
									</xsl:call-template>
								</xsl:for-each>
							</li> </ul>

							<li> Effect of the step: </li>
							<ul> <li> 
								<xsl:for-each select="$content/LIST-ITEM[position() &gt; 10 and position() &lt; 16]"> 
									<xsl:call-template name="format-text">
									<xsl:with-param name="text" select="."/>
									</xsl:call-template>
								</xsl:for-each>
							</li> </ul>
						</ul>
					</xsl:when>
				</xsl:choose>
			</xsl:when>

			<xsl:when test="contains($fixtype,'MODIFY-STEP') and string-length($fixtype) &lt; string-length('MODIFY-STEP') + 2">
				<xsl:choose>
					<xsl:when test="count($content/LIST-ITEM)=15">
						Modify a step <br/><br/>
						<ul>
							<li> Step details: </li>
							<ul> <li>
								<xsl:for-each select="$content/LIST-ITEM[position() &gt; 1 and position() &lt; 8]"> 	
									<xsl:call-template name="format-text">
									<xsl:with-param name="text" select="."/>
									</xsl:call-template>
								</xsl:for-each>
							</li> </ul>
	
							<li> Step Order: </li>
							<ul> <li> 
								<xsl:for-each select="$content/LIST-ITEM[position() &gt; 7 and position() &lt; 10]"> 	
									<xsl:call-template name="format-text">
									<xsl:with-param name="text" select="."/>
									</xsl:call-template>
								</xsl:for-each>
							</li> </ul>
		
							<li> Effect of the step: </li>
							<ul> <li> 
								<xsl:for-each select="$content/LIST-ITEM[position() &gt; 10 and position() &lt; 16]"> 	
									<xsl:call-template name="format-text">
									<xsl:with-param name="text" select="."/>
									</xsl:call-template>
								</xsl:for-each>
							</li> </ul>
						</ul>
					</xsl:when>
					<xsl:when test="count($content/LIST-ITEM)=13">
						Modify a step <br/><br/>
						<ul>
							<li> Step details: </li>
							<ul> <li> 
								<xsl:for-each select="$content/LIST-ITEM[position() &gt; 1 and position() &lt; 8]"> 	
									<xsl:call-template name="format-text">
									<xsl:with-param name="text" select="."/>
									</xsl:call-template>
								</xsl:for-each>
							</li> </ul>
	
							<li> Effect of the step: </li>
							<ul> <li> 
								<xsl:for-each select="$content/LIST-ITEM[position() &gt; 8 and position() &lt; 14]"> 	
									<xsl:call-template name="format-text">
									<xsl:with-param name="text" select="."/>
									</xsl:call-template>
								</xsl:for-each> 
							</li> </ul>
						</ul>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="format-text">
							<xsl:with-param name="text" select="$content"/>
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>

			<xsl:when test="contains($fixtype,'MODIFY-STEPS') and string-length($fixtype) &lt; string-length('MODIFY-STEPS') + 2">
				Modify steps <br/><br/>
				<ul>
					<li> Steps Order: </li>
					<ul> <li> 
						<xsl:for-each select="$content/LIST-ITEM[position() &gt; 0 and position() &lt; 3]"> 							<xsl:call-template name="format-text">
							<xsl:with-param name="text" select="."/>
							</xsl:call-template>
						</xsl:for-each>
					</li> </ul>
					<li> Effect of the steps: </li>
					<ul> <li> 
						<xsl:for-each select="$content/LIST-ITEM[position() &gt; 2 and position() &lt; 5]"> 
							<xsl:call-template name="format-text">
							<xsl:with-param name="text" select="."/>
							</xsl:call-template>
						</xsl:for-each>
					</li> </ul>
				</ul>
			</xsl:when>

			<xsl:when test="contains($fixtype,'MODIFY-EXPR') and string-length($fixtype) &lt; string-length('MODIFY-EXPR') + 2">
				Modify Expression(s) <br/><br/>
				<ul>
					<li> Expression Details: </li>
					<ul> <li> 
						<xsl:for-each select="$content/LIST-ITEM[position() &gt; 1 and position() &lt; 3]"> 
							<xsl:call-template name="format-text">
							<xsl:with-param name="text" select="."/>
							</xsl:call-template>
						</xsl:for-each>
					</li> </ul>
					<li> Source: </li>
					<ul> <li> 
						<xsl:for-each select="$content/LIST-ITEM[position() &gt; 3 and position() &lt; 5]"> 							<xsl:call-template name="format-text">
							<xsl:with-param name="text" select="."/>
							</xsl:call-template>
						</xsl:for-each>
					</li> </ul>
					<li> Steps Details: </li>
					<ul> <li> 
						<xsl:for-each select="$content/LIST-ITEM[position() &gt; 5 and position() &lt; 7]"> 
							<xsl:call-template name="format-text">
							<xsl:with-param name="text" select="."/>
							</xsl:call-template>
						</xsl:for-each>
					</li> </ul>
				</ul>
			</xsl:when>

			<xsl:when test="contains($fixtype,'DELETE-OR-MODIFY-STEP') and string-length($fixtype) &lt; string-length('DELETE-OR-MODIFY-STEP') + 2">
				Modify or Delete 
				<xsl:for-each select="$content/LIST-ITEM[position() &gt; 1 and position() &lt; 3]"> 		
					<xsl:call-template name="format-text">
					<xsl:with-param name="text" select="."/>
					</xsl:call-template>
				</xsl:for-each>
			</xsl:when>

			<xsl:when test="contains($fixtype,'CHANGE-OR-ADD-LINK-BETWEEN-STEPS') and string-length($fixtype) &lt; string-length('CHANGE-OR-ADD-LINK-BETWEEN-STEPS') + 2">
				<xsl:choose>
					<xsl:when test="count($content/LIST-ITEM)=8">
						Change or add link
						<ul>
							<li> Ordering: </li>
							<ul> <li> 
								Between
								<xsl:for-each select="$content/LIST-ITEM[position() &gt; 1 and position() &lt; 3]"> 
									<xsl:call-template name="format-text">
										<xsl:with-param name="text" select="."/>
									</xsl:call-template>
								</xsl:for-each>
							</li> </ul>
							<li> Effect: </li>
							<ul> <li> 
								<xsl:for-each select="$content/LIST-ITEM[position() &gt; 3 and position() &lt; 9]"> 							<xsl:call-template name="format-text">
									<xsl:with-param name="text" select="."/>
								</xsl:call-template>
								</xsl:for-each>
							</li> </ul>
						</ul>
					</xsl:when>
					<xsl:otherwise>
						<xsl:for-each select="$content/LIST-ITEM[position() &gt; 0 and position() &lt; 3]"> 			
							<xsl:call-template name="format-text">
							<xsl:with-param name="text" select="."/>
							</xsl:call-template>
						</xsl:for-each>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>

			<xsl:when test="contains($fixtype,'ADD-LINK') and string-length($fixtype) &lt; string-length('ADD-LINK') + 2">
				<xsl:for-each select="$content/LIST-ITEM[position() &gt; 0 and position() &lt; 6]"> 		
					<xsl:call-template name="format-text">
					<xsl:with-param name="text" select="."/>
					</xsl:call-template>
				</xsl:for-each>
			</xsl:when>

			<xsl:when test="contains($fixtype,'DELETE-OR-MODIFY-LINK') and string-length($fixtype) &lt; string-length('DELETE-OR-MODIFY-LINK') + 2">
				<xsl:choose>
					<xsl:when test="count($content/LIST-ITEM)=6">
						<xsl:choose>
							<xsl:when test="$content/LIST-ITEM/LIST-ITEM">
								Delete or Modify ordering constraints in loops: <br/><br/>
								<ul>
			
									<li> Loops: </li>
									<ul> 
										<xsl:for-each select="$content/LIST-ITEM/LIST-ITEM"> 
											<li> 
												<xsl:call-template name="format-text">
												<xsl:with-param name="text" select="."/> 
												</xsl:call-template>
											</li>
										</xsl:for-each>
									</ul>
				
								</ul>
							</xsl:when>
							<xsl:otherwise>
								Delete or Modify ordering between 
								<xsl:for-each select="$content/LIST-ITEM[position() &gt; 3 and position() &lt; 7]"> 								
									<xsl:call-template name="format-text">
									<xsl:with-param name="text" select="."/>
									</xsl:call-template>
								</xsl:for-each>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:when test="count($content/LIST-ITEM)=5">
						<xsl:choose>
							<xsl:when test="$content/LIST-ITEM/LIST-ITEM">
								Delete or Modify ordering constraints in: <br/><br/>
								<ul>
	
									<li> Ordering: </li>
									<ul> 
										<xsl:for-each select="$content/LIST-ITEM/LIST-ITEM"> 
											<li> 
												<xsl:call-template name="format-text">
													<xsl:with-param name="text" select="."/> 
												</xsl:call-template>
											</li>
										</xsl:for-each>
									</ul>
		
								</ul>
							</xsl:when>
							<xsl:otherwise>								
								<xsl:call-template name="format-text">
									<xsl:with-param name="text" select="$content"/>
								</xsl:call-template>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>

				</xsl:choose>
			</xsl:when>

			<xsl:when test="contains($fixtype,'ADD-EXPR') and string-length($fixtype) &lt; string-length('ADD-EXPR') + 2">				
				Add Expression(s) <br/><br/>
				<ul>
					<li> Expression Details: </li>
					<ul> <li> 
						<xsl:for-each select="$content/LIST-ITEM[position() &gt; 1 and position() &lt; 3]"> 
							<xsl:call-template name="format-text">
							<xsl:with-param name="text" select="."/>
							</xsl:call-template>
						</xsl:for-each>
					</li> </ul>
					<li> As: </li>
					<ul> <li> 
						<xsl:for-each select="$content/LIST-ITEM[position() &gt; 3 and position() &lt; 7]"> 
							<xsl:call-template name="format-text">
							<xsl:with-param name="text" select="."/>
							</xsl:call-template>
						</xsl:for-each>
					</li> </ul>
				</ul>
			</xsl:when>

			<xsl:when test="contains($fixtype,'ADD-FIRST-EVENT') and string-length($fixtype) &lt; string-length('ADD-FIRST-EVENT') + 2">
				Specify the first subevent of 
				<xsl:for-each select="$content/LIST-ITEM[position() &gt; 4 and position() &lt; 6]"> 		
					<xsl:call-template name="format-text">
					<xsl:with-param name="text" select="."/>
					</xsl:call-template>
				</xsl:for-each>
			</xsl:when>

			<xsl:when test="contains($fixtype,'ADD-SUBEVENT') and string-length($fixtype) &lt; string-length('ADD-SUBEVENT') + 2">
				<xsl:call-template name="format-text">
					<xsl:with-param name="text" select="$content"/>
				</xsl:call-template>
			</xsl:when>			

			<xsl:when test="contains($fixtype,'MODIFY-ROLE-ASSIGNMENT') and string-length($fixtype) &lt; string-length('MODIFY-ROLE-ASSIGNMENT') + 2">
				<xsl:call-template name="format-text">
					<xsl:with-param name="text" select="$content"/>
				</xsl:call-template>
			</xsl:when>

		</xsl:choose>
	</xsl:template>

	
	<xsl:template match="FIXES">
		<xsl:call-template name="header">
			<xsl:with-param name="source" select="parent::node()/@concept"/>
			<xsl:with-param name="sessionid" select="parent::node()/@sessionid"/>
		</xsl:call-template>

		<xsl:variable name="concept" select="parent::node()/@concept"/>

		<br/>
		<br/>
		<P CLASS="subtitle">Suggestions:</P> 
		<br/>
		<table border="0" cellpadding="0" cellspacing="5">

		<!-- List INFO about each of the general fixes -->
		<TR><TD COLSPAN="2" CLASS="label">There are several things that one can do in order to fix this kind of problem, such as:</TD></TR>

			<xsl:for-each select="FIX-ITEM">
				<xsl:if test="contains(TYPE,'GENERAL')">
				<tr>
					<td valign="top">
						<input type="button" value="Apply Fix"
						      onClick="javascript:void OpenEnterKnowledge('{$concept}', 0 );"/>
					</td>
					<td>						
						<xsl:value-of select="CONTENT"/>
					</td>				
				</tr>
				</xsl:if>
			</xsl:for-each>

		<!-- List INFO about each of the specific fixes -->
		<xsl:if test="count(FIX-ITEM[TYPE='GENERAL']) + count(FIX-ITEM[TYPE='EDIT-BACKGROUND-K']) &lt; count(FIX-ITEM)">
			<TR><TD COLSPAN="2" CLASS="label">These are more specific suggestions:</TD></TR>
		</xsl:if>

			<xsl:for-each select="FIX-ITEM">
				<xsl:if test="not(contains(TYPE,'GENERAL')) and not(contains(TYPE,'EDIT-BACKGROUND-K'))">
				<tr>
					<td valign="top">
						<input type="button" value="Apply Fix"
						      onClick="javascript:void OpenEnterKnowledge('{$concept}', 0 );"/>
					</td>
					<td> 
						<xsl:call-template name="printfix">
							<xsl:with-param name="fixtype" select="TYPE"/>
							<xsl:with-param name="content" select="CONTENT"/>
						</xsl:call-template>
					</td>				
				</tr>
				</xsl:if>
			</xsl:for-each>
	
			<xsl:if test="FIX-ITEM[TYPE='EDIT-BACKGROUND-K']">
				<tr><td colspan="2"><br/><br/><br/></td></tr>
			</xsl:if>

			<xsl:for-each select="FIX-ITEM">
				<xsl:if test="contains(TYPE,'EDIT-BACKGROUND-K')">
		                <xsl:variable name="superclass" select="SOURCE/LIST-ITEM/class/@ref"/>
				<tr>
					<td valign="top">
						<input type="button" value="Apply Fix"
						      onClick="javascript:void createSpecialCase('{$superclass}');"/>
					</td>
					<td>						
						<i><xsl:value-of select="CONTENT"/></i>
						<br/><br/><br/>
					</td>				
				</tr>
				</xsl:if>
			</xsl:for-each>

		    <TR VALIGN="TOP">
		    <TD>
		    <INPUT TYPE="BUTTON" VALUE="None of the above" onClick="javascript:void OpenEnterKnowledge('{$concept}', -1);"/>
		    </TD>
		    <TD>None of the fixes above seem appropriate in this case. 
		    The knowledge will be modified in a different way than what is suggested above.
		    </TD></TR>


		</table>

		<hr/>
		<iframe id="userfeedback" src="" style="display:none" width="100%" height="200">
			Your browser doesn't support iframes. Upgrade.
		</iframe>

	</xsl:template>

</xsl:stylesheet>
