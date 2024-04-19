<?xml version="1.0"?>
<!-- edited with XML Spy v3.0.7 NT (http://www.xmlspy.com) by pablo yanez (isi usc) -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/TR/WD-xsl">

	<xsl:template match="/">
		<html>
			<body>
				<center>
					<head>
						
					</head>
				</center>
				<br/>
				<center>
					<table border="0" cellpadding="0" cellspacing="0" width="60%" bgcolor="" height="20">
						<tr>
							<td/>
							<img height="130" width="200" src="photo/gil.gif"/>

							<td>
								<table border="1" cellpadding="0" cellspacing="0" width="100%" bgcolor="#f0d2b1" height="20">
									<tr>
										<td>
											<h3>Name:  </h3>
										</td>
										<td>
											<h3>
												<b>
													<xsl:value-of select="person/Name"/>
													<xsl:value-of select="person/Photo"/>
												</b>
											</h3>
										</td>
									</tr>
									<tr>
										<td>
											<h3>UserId:  </h3>
										</td>
										<td>
											<h3>
												<b>
												<xsl:value-of select="persona/Photo"/>
							
													<xsl:value-of select="person/UserId"/>
												</b>
											</h3>
										</td>
									</tr>
								</table>
							</td>
						</tr>
					</table>
				</center>
				<!--final de la tabla de presentadcion imagen y nombre-->
				<br/>
				<hr width="30%"/>
				<br/>
				<center>
				<table border="0" cellpadding="0" cellspacing="0" width="50%"  height="20%">
									<tr>
										<td>
										<b>PROJECTS: </b>
					<xsl:for-each select="person/projects">	
					, <xsl:value-of/>
					</xsl:for-each>
					<br/>
					<br/>
					<b>SYSTEMS: </b>
					<xsl:for-each select="person/systems">	
					, <xsl:value-of/>
					</xsl:for-each>
					<br/>
					<br/>					
					<b>TOPICS: </b>
					<xsl:for-each select="person/topics">	
					, <xsl:value-of/>
					</xsl:for-each>
					<br/>
					<br/>	
					<b>POSITION: </b>
					 <xsl:value-of select="person/position"/>
				<br/>
					<br/>
					<b>GROUP:  </b><xsl:value-of select="person/group"/>
					<br/>
					<br/>
					<br/><hr width="80%"/>
					
				
				<center><hr width="50%"/><i>
							<h2>Capabilities </h2>
						</i>	</center>
				</td>					
			</tr>
			</table>
			</center>
				<br/>
				<xsl:for-each select="person/capabilities/capability">
				
					<b>-   </b>
					<font color="#3333FF">
						<xsl:value-of select="NlDescription"/>
					</font>
					<p/>
				</xsl:for-each>
				<br/>	<hr width="50%"/>
			
				<xsl:for-each select="person/capabilities/capability">
					<font color="#1966ac">
						<br/>
						<h2>
							<center>
								<hr width="30%"/>
							</center>
						</h2>
						<br/>
					</font>
					<b>English: </b>
					<xsl:value-of select="NlDescription"/>
					<br/>
					<b>Stylized English: </b>
					<xsl:value-of select="MethodGoal/VarGoalForm/GoalName"/>
					<xsl:for-each select="MethodGoal/VarGoalForm/ManyVarGoalArgument/VarGoalArgument">
						<xsl:value-of select="ParameterName"/>
						
						<xsl:if match=".[MethodGoalArgument/ComplexData/ComplexData/t/@name='INST-OF']">
							<font color="#c60c40">
								<xsl:value-of select="MethodGoalArgument/ComplexData/ComplexData/ConceptName"/>
							</font>
						</xsl:if>
						<xsl:if match=".[MethodGoalArgument/ComplexData/ComplexData/t/@name!='INST-OF']">
							<xsl:value-of select="MethodGoalArgument/ComplexData/ComplexData/ConceptName"/>
						</xsl:if>
						
						<xsl:if match=".[MethodGoalArgument/ComplexData/t/@name='INST-OF']">
							<font color="#c60c40">
								<xsl:value-of select="MethodGoalArgument/ComplexData/ConceptName"/>
								<xsl:value-of select="MethodGoalArgument/ComplexData/InstanceName"/>
							</font>
						</xsl:if>
						<xsl:if match=".[MethodGoalArgument/ComplexData/t/@name!='INST-OF']">
							<xsl:value-of select="MethodGoalArgument/ComplexData/ConceptName"/>
							<xsl:value-of select="MethodGoalArgument/ComplexData/InstanceName"/>
						</xsl:if>
						
						
					</xsl:for-each>
					<!--VarGoalArgument-->
					<br/>
					<b>Formal Description:</b> 
						(<xsl:value-of select="MethodGoal/VarGoalForm/GoalName"/>
						<xsl:for-each select="MethodGoal/VarGoalForm/ManyVarGoalArgument/VarGoalArgument">
						(<xsl:value-of select="ParameterName"/>
						(<xsl:value-of select="MethodGoalArgument/VariableName"/>
						<xsl:value-of select="MethodGoalArgument/t/@name"/>
						(<xsl:value-of select="MethodGoalArgument/ComplexData/t/@name"/>
						<xsl:value-of select="MethodGoalArgument/ComplexData/ConceptName"/>
						<xsl:value-of select="MethodGoalArgument/ComplexData/InstanceName"/>
						<xsl:if match=".[MethodGoalArgument/ComplexData/ComplexData/t/@name='INST-OF']">
						
							(<xsl:value-of select="MethodGoalArgument/ComplexData/ComplexData/t/@name"/>
							<xsl:value-of select="MethodGoalArgument/ComplexData/ComplexData/ConceptName"/>)
						</xsl:if>)))
					</xsl:for-each>)
					<br/>
					<b>Formal representation: </b>
					<br/><br/>
					<b>GoalName</b>
					<xsl:value-of select="MethodGoal/VarGoalForm/GoalName"/>
					<xsl:for-each select="MethodGoal/VarGoalForm/ManyVarGoalArgument/VarGoalArgument">
						<blockquote>
							<b>ParameterName</b>
							<xsl:value-of select="ParameterName"/>
							<br/>
							<b>VariableName</b>
							<xsl:value-of select="MethodGoalArgument/VariableName"/>
							<br/>
							<b>t-name</b>
							<xsl:value-of select="MethodGoalArgument/t/@name"/>
							<br/>
							<b>ComplexData-t-Name</b>
							<xsl:value-of select="MethodGoalArgument/ComplexData/t/@name"/>
							<br/><B>ConcepName</B>	
							<xsl:value-of select="MethodGoalArgument/ComplexData/ConceptName"/>
							<xsl:value-of select="MethodGoalArgument/ComplexData/InstanceName"/>
							<xsl:value-of select="MethodGoalArgument/ComplexData/ComplexData/ConceptName"/>
						</blockquote>
					</xsl:for-each>
				</xsl:for-each>
				<!--Capability-->
			</body>
		</html>
	</xsl:template>
</xsl:stylesheet>
