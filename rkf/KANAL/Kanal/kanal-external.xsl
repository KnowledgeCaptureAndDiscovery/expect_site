<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

        <!-- variables for unit graphing -->
        <xsl:variable name="mul">180</xsl:variable>
        <xsl:variable name="padding">20</xsl:variable>
        <xsl:variable name="tagwidth">20</xsl:variable>

	<xsl:template name="header">
		<xsl:param name="class"/>
			<STYLE>
			   * {
			       font-family:Verdana;
			     }

			   td {
			       font-size:11px;
			       line-height:1.3em;
			   }

	                  .bluebutton {font-family:Verdana;font-size:xx-small;font-weight:bold;color:white;background-color:#6699cc}
	                  .darkbluebutton {font-family:Verdana;font-size:xx-small;font-weight:bold;color:white;background-color:#5588bb}
			  .sublabelwhite {font-weight:bold;text-align:left; font-size:11px;color:#e4f0fa;margin: 1px;width:80px;}
			  .sublabel {font-weight:bold; text-align:right; padding-right:4px; font-family:Verdana; font-size:11px; color:steelblue; margin:1px; width:80px;}
	                  .largebluelink {font-family:Verdana;font-size:10pt;font-weight:bold;color:#d4e0ea;cursor:pointer}
	                  .smallbluelink {font-family:Verdana;font-size:8pt;font-weight:bold;color:darkblue;cursor:pointer;text-decoration:underline}

	                  .bluelink {font-family:Verdana;font-size:8pt;font-weight:bold;color:#d4e0ea;cursor:pointer}
	                  .brownlink {font-family:Verdana;font-size:8pt;font-weight:bold;color:orange;cursor:pointer}
	                  .redlink {font-family:Verdana;font-size:8pt;font-weight:bold;color:orangered;cursor:pointer}

	                  .highlargebluelink {font-family:Verdana;font-size:10pt;font-weight:bold;color:#fafcfe;cursor:pointer}
	                  .highbluelink {font-family:Verdana;font-size:8pt;font-weight:bold;color:#fafcfe;cursor:pointer}
	                  .highbrownlink {font-family:Verdana;font-size:8pt;font-weight:bold;color:#e8caa2;cursor:pointer}
	                  .highredlink {font-family:Verdana;font-size:8pt;font-weight:bold;color:#ffc4aa;cursor:pointer}

	                  //.highlargebluelink {font-family:Verdana;font-size:10pt;font-weight:bold;color:#d4e0ea;cursor:pointer;
                          //               filter:progid:DXImageTransform.Microsoft.dropshadow(OffX=1, OffY=1, Color='black', Positive='true')}
	                  //.highbluelink {font-family:Verdana;font-size:8pt;font-weight:bold;color:#d4e0ea;cursor:pointer;
                          //               filter:progid:DXImageTransform.Microsoft.dropshadow(OffX=1, OffY=1, Color='black', Positive='true')}
	                  //.highbrownlink {font-family:Verdana;font-size:8pt;font-weight:bold;color:orange;cursor:pointer;
                          //               filter:progid:DXImageTransform.Microsoft.dropshadow(OffX=1, OffY=1, Color='black', Positive='true')}
	                  //.highredlink {font-family:Verdana;font-size:8pt;font-weight:bold;color:orangered;cursor:pointer;
                          //               filter:progid:DXImageTransform.Microsoft.dropshadow(OffX=1, OffY=1, Color='black', Positive='true')}

			  A:visited{color:darkblue}

			  ul{margin-top:0}

                          .remunitbar {
	                      font-family:Verdana;
	                      font-size:8px;
	                      font-weight:bold;
	                      border:1px dashed #666;
	                      background-color:#ddd;
	                      position:relative;
	                      text-align:center;
	                      margin-bottom:2px;
			      cursor:pointer;
			      word-break:break-all;
                          }

                          .selremunitbar {
	                      font-family:Verdana;
	                      font-size:8px;
	                      font-weight:bold;
	                      border:1px dashed #ddd;
	                      background-color:#666;
			      color:white;
	                      position:relative;
	                      text-align:center;
	                      margin-bottom:2px;
			      cursor:pointer;
			      word-break:break-all;
                          }


                          .unitbar {
	                      font-family:Verdana;
	                      font-size:8px;
	                      font-weight:bold;
	                      border:1px solid #669;
	                      background-color:#bdf;
	                      position:relative;
	                      text-align:center;
	                      margin-bottom:2px;
			      cursor:pointer;
			      word-break:break-all;
                          }

                          .selunitbar {
	                      font-family:Verdana;
	                      font-size:8px;
	                      font-weight:bold;
	                      border:1px solid #bdf;
	                      background-color:#669;
			      color:white;
	                      position:relative;
	                      text-align:center;
	                      margin-bottom:2px;
			      cursor:pointer;
			      word-break:break-all;
                          }

			  .unittip {
			      position:absolute;
	                      font-family:Verdana;
	                      font-size:10px;
			      width:350px;
	                      background-color:#ffd;
			      visibility:hidden;
			      border:1px solid black;
			      z-index:500;
			  }

			  .timetip {
			      position:absolute;
	                      font-family:Verdana;
	                      font-size:10px;
			      width:350px;
	                      background-color:#fed;
			      visibility:hidden;
			      border:1px solid black;
			      z-index:500;
			  }

			  .unittip ul, .timetip ul {
			      margin:2px;
			      margin-left:15px;
			  }


                          .timelegend {
	                      font-family:Verdana;
	                      font-size:8px;
	                      font-weight:bold;
	                      position:relative;
	                      text-align:left;
	                      border-left:1px solid red;
	                      color:red;
	                      padding-left:3px;
	                      width:<xsl:value-of select="$tagwidth"/>px;
			      cursor:pointer;
                          }

                          .seltimelegend {
	                      font-family:Verdana;
	                      font-size:8px;
	                      font-weight:bold;
	                      position:relative;
	                      text-align:left;
	                      border-left:1px solid white;
			      background-color:red;
	                      color:white;
	                      padding-left:3px;
	                      width:<xsl:value-of select="$tagwidth"/>px;
			      cursor:pointer;
                          }

                          .powerlegend {
	                      font-family:Verdana;
	                      font-size:8px;
	                      font-weight:bold;
	                      position:relative;
	                      text-align:left;
	                      border-left:1px;
	                      padding-left:3px;
	                      width:<xsl:value-of select="$tagwidth"/>px;
                          }

	             </STYLE>

			<SCRIPT TYPE="text/javascript"> 
				
<!-- used to store the starting row number of results (like unnecessary links etc.) in "kanalresults" table -->
				var resultstartrow=0;

<!-- used to store the ending row number of results (like unnecessary links etc.) in "kanalresults" table -->
				var resultendrow=0;

<!-- used to store number of steps being currently displayed -->
				var stepsdisplayed=0;

	          		function OpenFixes (errorid) {
             	 		address = "/imxml?next=test-knowledge-kanal-get-fix&amp;individual=" + param_class + "&amp;sessionid=" + param_sessionid + "&amp;fixid=" + errorid
	              		features  = "resizable,scrollbars,alwaysRaised,width=800,height=500" ;
	              		window.open(address,"_blank",features) ;
	          		}

		   		function StoreError (errorid,flag) {
			 		var reason = "";
					var address = "";
					
					the_iframe = document.getElementById("userfeedback");

 			 		if(flag==1) {
				 		reason = prompt("What is the Reason of disagreement ?","");
						address = "/imxml?next=log&amp;sessionid=" + param_sessionid + "&amp;concept=" + param_class + "&amp;action=open&amp;errorid=" + errorid + "&amp;type=disagree&amp;logflag=yes&amp;reason=" + reason
			 		} else if(flag==2) {
						address = "/imxml?next=log&amp;sessionid=" + param_sessionid + "&amp;concept=" + param_class + "&amp;action=open&amp;errorid=" + errorid + "&amp;type=ignore&amp;logflag=yes&amp;reason=" + reason

			 		} else {
						address = "/imxml?next=log&amp;sessionid=" + param_sessionid + "&amp;concept=" + param_class + "&amp;action=open&amp;errorid=" + errorid + "&amp;type=agree&amp;logflag=yes&amp;reason=" + reason

		       		 }

					while(address.indexOf('amp;')!=-1)
					{
						address = address.replace('amp;','');
					}
					the_iframe.src = address;
		   		}
		   		
<!-- toggles the display of step details shown on the right side 
	- item : pointer to the right or down image of the step
	- rcount : number of rows to toggle display of 
	- errorlevel : 0=no error 1=warning 2=error
	- withimagerow : decides if the the image itself should be toggled
	- issubevent : indicates if the step being toggled is a subevent or not
-->
		   		function toggleDisplayOfSteps(item,rcount,errorlevel,withimagerow,issubevent) {
					var imagerow = item.parentNode.parentNode.parentNode;
					var table = document.getElementById('kanalresults');
					var tablerows = table.rows;
					
		   		        var target_block = imagerow.nextSibling;
		   		        var display_state = target_block.style["display"];
					if(withimagerow)
						display_state = imagerow.style.display;

                                        var i=0; var imgURL="";
                                        <xsl:if test="$static = 'true'">
                                            imgURL += "<xsl:value-of select="$static_server"/>";
                                        </xsl:if>

					<!-- color of the image is assigned here -->
         				switch(errorlevel) {
						  case 1: imgURL+="/images/kanal/w" ; break;
						  case 2: imgURL+="/images/kanal/e" ; break;						
						  default: imgURL+="/images/general/" ;
					}
						
					<!-- toggle display of steps -->					
					while(( i != rcount )&amp;&amp;(target_block)) {
			   		       if ((display_state == "")||(!display_state)) {
    							target_block.style["display"] = "none";
							if(withimagerow) {
								imagerow.style["display"] = "none";
								if(i==0)
									if(!issubevent)
										stepsdisplayed--;
							}
    							item.src = imgURL + "right.gif";
  						} else {
    							target_block.style["display"] = "";
							if(withimagerow) {
								imagerow.style["display"] = "";
								if(i==0)
									if(!issubevent)
										stepsdisplayed++;
							}
    							item.src = imgURL + "down.gif";
	  					}

						target_block = target_block.nextSibling;	
						i = i + 1;
					}
					
					<!-- toggles the display of message 'please select the step to see details' -->
					if(stepsdisplayed) {
						if((tablerows[0].style.display=="")||(!tablerows[0].style.display))
  							tablerows[0].style.display="none"
					}
					else {
						if(tablerows[0].style.display=="none")
  							tablerows[0].style.display=""
					}
						
                         }

<!-- displays the details of steps on right side if the step contains a warning or error 
	- rcount : number of rows to toggle display of 
	- issubevent : indicates if the step being toggled is a subevent or not
-->
	
				function displayErrorSteps(rcount,issubevent) {
					var imgNodes = document.getElementsByTagName("IMG")
					var i=0
<!-- if the 'right' image is brown or red then toggle that step -->
					while(i != imgNodes.length) {
						if(imgNodes[i].src.indexOf("/images/kanal/eright.gif") != -1) {
							toggleDisplayOfSteps(imgNodes[i],rcount,2,1,issubevent)
						}
						else if(imgNodes[i].src.indexOf("/images/kanal/wright.gif") != -1) {
							toggleDisplayOfSteps(imgNodes[i],rcount,1,1,issubevent)
						}
						i = i + 1
					}
				}

<!-- toggles the display of checked and unchecked images on the left hand side
	- item : pointer to the checked or unchecked image
-->
		   		function toggleDisplayOfTabs(item) {
				       var target_block = item.parentNode.parentNode.nextSibling;
		   		       var display_state = target_block.style.display;

                                       var textitem;
                                       var mainclass="";
                                       if(item.id.indexOf("tab") != -1) {
                                            var textid = "texttab" + item.id.substring(3);
                                            textitem = document.getElementById(textid);
                                            mainclass = textitem.className;
                                            if(mainclass.indexOf("high") != -1) {
                                              mainclass = mainclass.substring(4);
                                            }
                                       }

		   		       if ((display_state == "")||(!display_state)) {
    						target_block.style.display = "none";
                                                <xsl:if test="$static = 'true'">
    						  item.src = "<xsl:value-of select="$static_server"/>/images/kanal/unchecked.gif";
                                                </xsl:if>
                                                <xsl:if test="not($static = 'true')">
    						  item.src = "/images/kanal/unchecked.gif";
                                                </xsl:if>
                                                if(textitem) { textitem.className = mainclass; }
  				       } else {
    						target_block.style.display = "";
                                                <xsl:if test="$static = 'true'">
    						  item.src = "<xsl:value-of select="$static_server"/>/images/kanal/checked.gif";
                                                </xsl:if>
                                                <xsl:if test="not($static = 'true')">
    						  item.src = "/images/kanal/checked.gif";
                                                </xsl:if>
                                                if(textitem) { textitem.className = "high"+mainclass; }
  				       }
                                 }

<!-- toggles step details on right corresponding to step name on the left
	- item : pointer to the right or down image of the step
	- step : step id like _Attach1234
	- rcount : number of rows to toggle display of 
	- issubevent : indicates if the step being toggled is a subevent or not

This function is actually not needed. The next function can do the work.
I will change this later.
-->
		   		function toggleStepForTab(step) {
                                        var stepnum = getStepNumber(step);
                                        if(isSubevent(stepnum)) toggleStep(stepnum);
                                        else showStep("step", stepnum);
                                }

				var stepChildren = new Array();

				function toggleChildren(step) {
					var children = stepChildren[step].split("\01");
					for(var i=0; i&lt;children.length; i++) {
					    toggleStepForTab(children[i]);
					}
				}

		   		function toggleStepCorrespondingToTab(item,step,rcount,issubevent) {

				        /***id is to be used for toggling the display of details***/

					var imgNode = document.getElementById(step);
					var imagerow = imgNode.parentNode.parentNode.parentNode;
					var target_block = item.parentNode.parentNode.nextSibling;
					var togglestep = 0;
					
					<!--display state of the checked/unchecked image on left-->
		   		        var display_state = target_block.style.display;

					<!-- toggle display of step on right hand side only if display
						states are different on left and right side -->
					if(display_state != imagerow.style.display)					
						togglestep=1;

					<!-- toggle corresponding step details -->
					if(togglestep) {
						if(imgNode.src.indexOf("/images/kanal/e") != -1) {
							toggleDisplayOfSteps(imgNode,rcount,2,1,issubevent)
						}
						else if(imgNode.src.indexOf("/images/kanal/w") != -1) {
							toggleDisplayOfSteps(imgNode,rcount,1,1,issubevent)
						}
						else {
							toggleDisplayOfSteps(imgNode,rcount,0,1,issubevent)
						}
					}
                               }

<!-- toggles other details on right corresponding to selection on the left
	- item : pointer to the right or down image of the step
	- tableid : id of the table whose rows r to be toggled
	- startrow : start index of the rows to be toggled
	- endrow : end index of the rows to be toggled
	- onlysecondcolumn : indicates if only secondcolumns of the rows are to be toggled
-->
		   		function toggleDetailCorrespondingToTab(item,tableid,startrow,endrow,onlysecondcolumn) {

				        /***id is to be used for toggling the display of details***/

					var table = document.getElementById(tableid);
					var tablerows = table.rows
					var tablecells = tablerows[startrow].cells;
					var target_block = item.parentNode.parentNode.nextSibling;
					var togglestep = 0;
					var i=startrow;
					
					<!-- display state of the checked/unchecked image -->
		   		        var display_state = target_block.style.display;

					<!-- this condition check is actually not needed even in the previous function -->
					if(display_state != tablerows[startrow].style.display) {					
						togglestep=1;
					} else if (tablecells[1]) {
					    if(display_state != tablecells[1].firstChild.style.display) {
						if(onlysecondcolumn)
							togglestep=1;
					    }
					}
				
					<!--toggle the requested rows-->
					if(togglestep) {
						if(onlysecondcolumn) {
							while(i &lt; endrow+1) {
								tablecells = tablerows[i].cells;
								if(tablecells[1].firstChild.style.display=="none") {						
									tablecells[1].firstChild.style.display=""
								}
								else {
									tablecells[1].firstChild.style.display="none"
								}
								i++
							}
						}
						else {
							while(i &lt; endrow+1) {
								if(tablerows[i].style.display=="none") {						
									tablerows[i].style.display=""
								}
								else {
									tablerows[i].style.display="none"
								}
								i++
							}
						}
					}
            	                }


<!-- displays all the steps as per the value of variable displayState
	displayState: 0 - hide steps, 1 - display steps
-->
				function displayAllSteps(displayState) {
					
					<xsl:variable name="fc" select="//ERROR[TYPE='PRECONDITION' and SUCCESS='NIL']/SOURCE/individual/@ref"/>
					<xsl:for-each select="//INFO[TYPE='SIMULATED-PATHS']/CONTENT/PATH/LIST-ITEM/LIST-ITEM/individual/@ref">		
						<xsl:variable name="step" select="."/>
						<xsl:variable name="issubevent" select="count(//INFO[TYPE='SUBEVENTS']/CONTENT/LIST-ITEM/SUBEVENTS/SUBEVENT[individual/@ref=$step])"/>
						var node<xsl:value-of select="translate($step,'-','_')"/> = document.getElementById('tab'+'<xsl:value-of select="$step"/>');
						if(node<xsl:value-of select="translate($step,'-','_')"/>.src.indexOf('unchecked')!=-1){
							if(displayState) {
								toggleDisplayOfTabs(node<xsl:value-of select="translate($step,'-','_')"/>)
      		                              toggleStepCorrespondingToTab(node<xsl:value-of select="translate($step,'-','_')"/>,'<xsl:value-of select="$step"/>',rcount<xsl:value-of select="translate($step,'-','_')"/> + has_subevents<xsl:value-of select="translate($step,'-','_')"/>,<xsl:value-of select="$issubevent"/>)
							}
						}
						else if(!displayState) {
						       toggleDisplayOfTabs(node<xsl:value-of select="translate($step,'-','_')"/>)
      		                                       toggleStepCorrespondingToTab(node<xsl:value-of select="translate($step,'-','_')"/>,'<xsl:value-of select="$step"/>',rcount<xsl:value-of select="translate($step,'-','_')"/> + has_subevents<xsl:value-of select="translate($step,'-','_')"/>,<xsl:value-of select="$issubevent"/>)
						}
					</xsl:for-each>

					<xsl:if test="$fc">
						<xsl:variable name="issubevent" select="count(//INFO[TYPE='SUBEVENTS']/CONTENT/LIST-ITEM/SUBEVENTS/SUBEVENT[individual/@ref=$fc])"/>
						var node<xsl:value-of select="translate($fc,'-','_')"/> = document.getElementById('tab'+'<xsl:value-of select="$fc"/>');
						if(node<xsl:value-of select="translate($fc,'-','_')"/>.src.indexOf('unchecked')!=-1) {
							if(displayState) {
								toggleDisplayOfTabs(node<xsl:value-of select="translate($fc,'-','_')"/>)
      		                              toggleStepCorrespondingToTab(node<xsl:value-of select="translate($fc,'-','_')"/>,'<xsl:value-of select="$fc"/>',rcount<xsl:value-of select="translate($fc,'-','_')"/> + has_subevents<xsl:value-of select="translate($fc,'-','_')"/>,<xsl:value-of select="$issubevent"/>)
							}
						}
						else if(!displayState) {
								toggleDisplayOfTabs(node<xsl:value-of select="translate($fc,'-','_')"/>)
      		                              toggleStepCorrespondingToTab(node<xsl:value-of select="translate($fc,'-','_')"/>,'<xsl:value-of select="$fc"/>',rcount<xsl:value-of select="translate($fc,'-','_')"/> + has_subevents<xsl:value-of select="translate($fc,'-','_')"/>,<xsl:value-of select="$issubevent"/>)
						}
					</xsl:if>

				}

				function toggleDisplayOfEventInfo(item,nrows) {
					var target_block = item.nextSibling;
		   		        var display_state = target_block.style.display;
					var i = nrows;

					while(i != 0) {
			   		      if ((display_state == "")||(!display_state)) {
							target_block.style.display = "none";
						} else {
							target_block.style.display = "";
 						}
						if(i>1)					
							target_block=target_block.parentNode.nextSibling.firstChild.nextSibling;
						i = i - 1;
						
					}
				}

<!-- sets the resultendrow variable to one less of the length of the table, which is its index -->
				function setResultEndRow() {
					var table = document.getElementById('kanalresults');
					var tablerows = table.rows;
					resultendrow = tablerows.length - 1;
				}

<!-- I have 4 global arrays for showing time varying properties:
a)unit_refs[] = stores the instance names
b)unit_names[] = stores the corresponding english
c)unit_property_names[] = stores the different property names for all units
d)unit_properties[i][j][k] = a 3d array which stores the property values
                 for all units for all steps.
		Here i indexes into arrays a&b
                 j indicates step number
		     k indexes into array c

Following are the functions to deal with these arrays
-->

				function getUnitIndex(str) {
					var tempindex = -1;
					var tempi = 0;
					for(tempi = 0; tempi &lt; no_of_units; tempi++) {
						tempindex=unit_refs[tempi].indexOf(str);
						if(tempindex!=-1){
							if(unit_refs[tempi].length == str.length) {
								tempindex = tempi;
								break;
							}
						}
					}
					return tempindex;	
				}


				function addUnit(str,name,step) {
					if(getUnitIndex(str)==-1) {
                                                //alert("adding unit "+name+" -"+str+"-");
						unit_names[no_of_units] = name;
						unit_refs[no_of_units++] = str;
					}
					//event_unit[step] += str+"\01";
					if(!event_unit[step]) event_unit[step] = new Array();
					event_unit[step][str] = 1;
				}

				function getPropertyIndex(str) {
					var tempindex = -1;
					var tempi = 0;
					for(tempi = 0; tempi &lt; no_of_properties; tempi++) {
						tempindex=unit_property_names[tempi].indexOf(str);
						if(tempindex!=-1){
							tempindex = tempi;
							break;
						}
					}
					return tempindex;
				}

				function addProperty(str) {
					if(getPropertyIndex(str)==-1) {
						unit_property_names[no_of_properties++] = str;
					}
				}


				function setPropertyValue(property_name,unit_ref, cur_step, str, from_del_list) {
					var tempi = getUnitIndex(unit_ref)
					var tempk = getPropertyIndex(property_name)
					var tempj = 0;
					unit_properties[tempk][tempi][cur_step] = str;
					if(from_del_list) {
						tempj = cur_step - 1;
						while(tempj &gt;= 0) {
							if(unit_properties[tempk][tempi][tempj].length == 0) {
								unit_properties[tempk][tempi][tempj] = str
							}
							else
								break;
							tempj--
						}
					}
					else {
						tempj = cur_step + 1;
						while(tempj &lt; total_no_of_steps) {
							unit_properties[tempk][tempi][tempj] = str
							tempj++
						}
					}
				}


                                // --------------- Code to hide non-combat power data

				function showAllData(buttonelem,message) {
                                    if(!buttonelem) { buttonelem = document.getElementById("show All Data"); }
				    var items = document.getElementsByName('extradata');
				    var otheritems = document.getElementsByName('hidetext');

				    var disp="none";
				    var otherdisp="block";

				    if(buttonelem.value == 'Show All Checks') {
					disp="block";
					otherdisp="none";
					buttonelem.value = 'Show Combat Power Analysis Only';
				    } else {
					buttonelem.value = 'Show All Checks';
				    }

				    for(var i=0; i &lt; items.length; i++) {
					items[i].style.display=disp;
				    }
				    for(var i=0; i &lt; otheritems.length; i++) {
					otheritems[i].style.display=otherdisp;
				    }
				}


                                // -------------- Code to Allow Stepping through Steps one at a time ------------------

                                var currentstep = 0;
                                var laststep = 0;

                                function isSubevent(stepnum) {
                                    var st = simulated_steps[stepnum];
                                    if(!st) { return 0; }
                                    var stt = st.replace(/-/g,"_");
                                    var is_subevent = eval("is_subevent"+stt);
                                    return is_subevent;
                                }
                              
                                function getStepNumber(step) {
                                    for(var i=1; i&lt;stcount; i++) {
                                       if(simulated_steps[i] == step) return i; 
                                    }
                                    return 0;
                                }
                                
                                function toggleStep(stepnum) {
                                    var st = simulated_steps[stepnum];
                                    if(!st) { return 0; }
                                    var stt = st.replace(/-/g,"_");
				    var node = document.getElementById("tab"+st);
                                    var rcount = eval("rcount"+stt);
                                    var has_subevents = eval("has_subevents"+stt);
                                    var is_subevent = eval("is_subevent"+stt);
				    toggleDisplayOfTabs(node);
      		                    toggleStepCorrespondingToTab(node,st,rcount + has_subevents,is_subevent)
                                }



                                // ShowStep : op = "first", "next", "previous", "step"
                                function showStep(op, stepnum) {
                                    var is_subevent = 1;

                                    if(!isSubevent(currentstep)) laststep=currentstep;

                                    if(op == "first") {currentstep = minst;}
                                    if((op == "next")&amp;&amp;(currentstep &lt; maxst)) currentstep++;
                                    if((op == "previous")&amp;&amp;(currentstep &gt; minst)) currentstep--;
                                    if(op == "step") currentstep = stepnum;
                                    //alert(laststep +" -> "+currentstep);

                                    if(laststep != currentstep) {
                                       if(isSubevent(currentstep)) {
                                         if(currentstep == maxst) {
                                            showStep("previous");
                                            maxst--;
                                         } else if(currentstep == minst) {
                                            showStep("next");
                                            minst++;
                                         } else {
                                            showStep(op); 
                                         }
                                       }
                                       else { 
                                         if(op != "step") { logmessage += " ("+simulated_steps[currentstep]+") "; }
                                         toggleStep(laststep);
                                         toggleStep(currentstep);
                                       }
                                       // Hide the Prev/Next Buttons if needed
                                       if(currentstep &gt;= maxst) {
                                          document.getElementById("nextstep").style.display="none";
                                       } else {
                                          document.getElementById("nextstep").style.display="inline";
                                       }
                                       if(currentstep &lt;= minst) {
                                          document.getElementById("prevstep").style.display="none";
                                       } else {
                                          document.getElementById("prevstep").style.display="inline";
                                       }
                                    } else if(op == "step") {
                                       // Manually hiding a step
                                       toggleStep(currentstep);
                                       currentstep=0;
                                    }
                                }

				function showTip (id, unitclass, e) {
				    var unititem = document.getElementById(id);
				    var tipitem = document.getElementById(id+"_description");
				    unititem.className = "sel"+unitclass;
				    tipitem.style.left = e.clientX - 100;
				    tipitem.style.top = e.clientY + 30 + document.body.scrollTop;
				    tipitem.style.visibility = "visible";
				}

				function hideTip (id, unitclass, e) {
				    var unititem = document.getElementById(id);
				    var tipitem = document.getElementById(id+"_description");
				    unititem.className = unitclass;
				    tipitem.style.visibility = "hidden";
				}

				function showTimeTip (id, e) {
				    var timeitem = document.getElementById(id);
				    var tipitem = document.getElementById(id+"_description");
				    timeitem.className = "seltimelegend";
				    tipitem.style.left = e.clientX - 100;
				    tipitem.style.top = e.clientY + 30 + document.body.scrollTop;
				    tipitem.style.visibility = "visible";
				}

				function hideTimeTip (id, e) {
				    var timeitem = document.getElementById(id);
				    var tipitem = document.getElementById(id+"_description");
				    timeitem.className = "timelegend";
				    tipitem.style.visibility = "hidden";
				}

				function toggleTable (id) {
				    var tableitem = document.getElementById(id+"_Explanation");
				    var hrefitem = document.getElementById("Show_"+id+"_Link");
				    if(tableitem.style.display == 'none') {
					tableitem.style.display = "";
					hrefitem.innerHTML = "Hide Details";
				    } else {
					tableitem.style.display = "none";
					hrefitem.innerHTML = "Show Details";
				    }
				}

                                // -------------- Facility to Modify knowledge for all steps

                                var sessionid = param_sessionid;
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
					logmessage = "Clicked button "+item.value;
				    } else if ((ntype == 'IMG')||(ntype == 'TD')||(ntype == 'SPAN')) {
					if(item.id) {
					   var state = "";
					   if(ntype == 'IMG') {
					       if (item.src.indexOf("checked") != -1) {
					          if(item.src.indexOf("/images/kanal/checked.gif") != -1) { state = "hide"; }
					          else { state = "show"; }
					       }
					       else if (item.src.indexOf("right") != -1) {
						   state = "show";
					       } else {
						   state = "hide";
					       }
					   } else if ((ntype=='TD')&amp;&amp;(item.id.indexOf("texttab") != -1)) {
                                               var step = item.id.substring(7);
                                               var imgitem = document.getElementById("tab"+step);
					       if (imgitem.src.indexOf("checked") != -1) {
					          if(imgitem.src.indexOf("/images/kanal/checked.gif") != -1) { state = "hide"; }
					          else { state = "show"; }
					       }
					       else if (imgitem.src.indexOf("right") != -1) {
						   state = "show";
					       } else {
						   state = "hide";
					       }
                                           } else if (ntype== 'TD') {
					       var disp = item.nextSibling.style.display;
					       if(disp == 'none') { state = "show"; }
					       else { state = "hide";}
					   } else if (ntype== 'SPAN') {
					       var disp = item.parentElement.nextSibling.style.display;
					       if(disp == 'none') { state = "show"; }
					       else { state = "hide";}
					   }
					   logmessage = state + " " + item.id;
					}
				    } else if(item.href) {
					logmessage = "Clicked on link : "+item.href;
				    }
				}

                                function Agree(step) {
                                    alert("Ok");
                                    logmessage = "Agree with results of "+step;
                                    Logit();
                                }

                                function Disagree(step) {
                                    var reason = prompt("Please explain your reason for disagreement ?", "");
                                    logmessage = "Disagree with results of "+step+" because "+reason;
                                    Logit();
                                }

                                var numlinks = 0;

				function LogIt() {
				    if(logmessage) {
					logmessage = logmessage.replace(/\&lt;/g,'');
					logmessage = logmessage.replace(/\&gt;/g,'');
					var the_iframe = document.getElementById("userfeedback");
					address = "/im?next=activity-log&amp;sessionid=" + param_sessionid + "&amp;concept=" + param_class + "&amp;logmessage=" + logmessage;
					address = address.replace(/amp;/g,'');
					address = address.replace(/ /g,'+');
					//the_iframe.document.clear();
					//the_iframe.document.writeln(address);
					the_iframe.src = address;
                                        numlinks++;
                                        //alert(logmessage);
				    }
				}
 
                                function goBack() {
                                    var backnum = 0 - numlinks;
                                    numlinks = 0;
                                    history.go(backnum);
                                }

                                <xsl:if test="not($static = 'true')">
				  if(document.all) {
				     document.onmousedown = MD;
				     document.onclick = LogIt;
				  }
                                </xsl:if>
           	</SCRIPT>

		<p class="subtitle">Knowledge Analysis for: 
			<xsl:apply-templates select="//dictionary/class[@id = $class]" mode="make-link"/>
		</p><br/>
	</xsl:template>

	<xsl:template name="translate-operator">
		<xsl:param name="str"/>
		<xsl:choose>
			<xsl:when test="contains($str,'GT')">
				<span style="white-space:pre">&gt;</span>
			</xsl:when>
			<xsl:when test="contains($str,'LT')">
				<span style="white-space:pre">&lt;</span>
			</xsl:when>
			<xsl:when test="contains($str,'GTE')">
				<span style="white-space:pre">&gt;=</span>
			</xsl:when>
			<xsl:when test="contains($str,'LTE')">
				<span style="white-space:pre">&lt;=</span>
			</xsl:when>
			<xsl:when test="contains($str,'EQ')">
				<span style="white-space:pre">&gt;</span>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$str"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

<xsl:template name="format-text1">
	<xsl:param name="text"/>
	<xsl:variable name="lowercase" select="'abcdefghijklmnopqrstuvwxyz'"/>
	<xsl:variable name="uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>
	<xsl:choose>
		<xsl:when test="contains($text,'pcs-list')">
			<xsl:call-template name="format-text1">
				<xsl:with-param name="text" select="'conditions'"/>
			</xsl:call-template>
		</xsl:when>
		<xsl:when test="contains($text,'del-list')">
			<xsl:call-template name="format-text1">
				<xsl:with-param name="text" select="'delete-list'"/>
			</xsl:call-template>
		</xsl:when>
		<xsl:when test="contains($text,'-')">					
			<xsl:call-template name="format-text1">
				<xsl:with-param name="text" select="translate($text,'-',' ')"/>
			</xsl:call-template>
		</xsl:when>
		<xsl:otherwise>			
			<xsl:value-of select="concat(translate(substring($text,1,1),$lowercase,$uppercase),substring($text,2))"/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>


<xsl:template name="combat_power_timeline">
    <xsl:param name="top"/>
    <xsl:param name="step"/>
    <xsl:variable name="stfrom" select="$top/ITEM[1]/TIME"/>

    <xsl:for-each select="$top/ITEM">
        <xsl:if test="VALUE != 'NIL'">
        <xsl:variable name="stCoord" select="(number(TIME)-number($stfrom))*number($mul)+number($padding)"/>
	<xsl:variable name="left" select="number($stCoord)-((number(position())-1)*(number($tagwidth)+3))"/>
	<span class="powerlegend">
	   <xsl:attribute name="style">
	      left:<xsl:value-of select="$left"/>px;
	   </xsl:attribute>
	   <xsl:value-of select="VALUE"/>
	</span>
	</xsl:if>
    </xsl:for-each>

    <br/>
    <xsl:for-each select="$top/ITEM">
        <xsl:variable name="stCoord" select="(number(TIME)-number($stfrom))*number($mul)+number($padding)"/>
	<xsl:variable name="left" select="number($stCoord)-((number(position())-1)*(number($tagwidth)+2))"/>
	<xsl:variable name="daTimeId">Time_<xsl:value-of select="$step"/><xsl:value-of select="translate(TIME,'.','_')"/></xsl:variable>
	<span class="timelegend">
	   <xsl:attribute name="ID"><xsl:value-of select="$daTimeId"/></xsl:attribute>
	   <xsl:if test="DESCRIPTION/LIST-ITEM">
	      <xsl:attribute name="onmouseover">showTimeTip('<xsl:value-of select="$daTimeId"/>', event);</xsl:attribute>
	      <xsl:attribute name="onmouseout">hideTimeTip('<xsl:value-of select="$daTimeId"/>', event);</xsl:attribute>
	   </xsl:if>
	   <xsl:attribute name="style">
	      left:<xsl:value-of select="$left"/>px;
	   </xsl:attribute>
	   <xsl:value-of select="TIME"/>
	</span>
	<div class="timetip">
	   <xsl:attribute name="ID"><xsl:value-of select="$daTimeId"/>_description</xsl:attribute>
           <xsl:call-template name="showdetails">
               <xsl:with-param name="list" select="DESCRIPTION/LIST-ITEM[2]/LIST-ITEM"/>
               <xsl:with-param name="unordered" select="'yes'"/>
	   </xsl:call-template>
        </div>
    </xsl:for-each>

</xsl:template>


<xsl:template name="unit_timeline">
    <xsl:param name="top"/>
    <xsl:param name="stfrom"/>
    <xsl:param name="step"/>

    <xsl:for-each select="$top/UNIT">
	<xsl:sort order="ascending" select="TIME/START"/>
        <xsl:variable name="unitid"><xsl:apply-templates select="ID" mode="get-english"/></xsl:variable>
        <xsl:variable name="combatpower" select="RELATIVE_COMBAT_POWER"/>
        <xsl:variable name="stCoord" select="(number(TIME/START)-number($stfrom))*number($mul)+number($padding)"/>
        <xsl:variable name="width" select="(number(TIME/END) - number(TIME/START))* number($mul)"/>
	<xsl:variable name="daUnitId">
	   <xsl:value-of select="$step"/><xsl:value-of select="$unitid"/><xsl:value-of select="translate(TIME/START,'.','_')"/>
	</xsl:variable>
	<xsl:variable name="daUnitClass">
	    <xsl:choose><xsl:when test="OKFLAG='REMOVED'">remunitbar</xsl:when>
	                <xsl:otherwise>unitbar</xsl:otherwise> 
	    </xsl:choose>
	</xsl:variable>
	<div class="unitbar">
	   <xsl:attribute name="class"><xsl:value-of select="$daUnitClass"/></xsl:attribute>
	   <xsl:attribute name="ID"><xsl:value-of select="$daUnitId"/></xsl:attribute>
	   <xsl:attribute name="onmouseover">showTip('<xsl:value-of select="$daUnitId"/>', '<xsl:value-of select="$daUnitClass"/>', event);</xsl:attribute>
	   <xsl:attribute name="onmouseout">hideTip('<xsl:value-of select="$daUnitId"/>', '<xsl:value-of select="$daUnitClass"/>', event);</xsl:attribute>
	   <xsl:attribute name="style">
	   left:<xsl:value-of select="$stCoord"/>px;width:<xsl:value-of select="$width"/>px;
	   </xsl:attribute>
	   <xsl:value-of select="$unitid"/> (<xsl:value-of select="$combatpower"/>)
	</div>
	<div class="unittip">
	   <xsl:attribute name="ID"><xsl:value-of select="$daUnitId"/>_description</xsl:attribute>
           <xsl:call-template name="showdetails">
               <xsl:with-param name="list" select="DESCRIPTION/LIST-ITEM"/>
               <xsl:with-param name="unordered" select="'yes'"/>
	   </xsl:call-template>
        </div>
    </xsl:for-each>
</xsl:template>


<!-- show details of steps and results-->
	<xsl:template name="showdetails">
	      <xsl:param name="list" />
		<xsl:param name="color" />
		<xsl:param name="unordered"/>
		<xsl:param name="sortorder"/>
		<xsl:param name="explanation"/>
		<xsl:param name="step"/>
		
		<xsl:if test="$unordered">
		<font color="{$color}">
			<ul>
				<xsl:variable name="count" select="count($list[not(contains(.,'NIL'))])"/>
				<xsl:for-each select="$list">
					
					<!--<xsl:sort order="{$sortorder}" select="position()"/>-->
					<!--<xsl:if test="not(contains(.,'NIL'))">-->
						<xsl:element name="li">
							<xsl:if test="$count &lt; 2 and $explanation &lt; 1">
								<xsl:attribute name="style">list-style-type:none</xsl:attribute>
							</xsl:if>
							<xsl:if test="$count &gt; 1">
								<xsl:attribute name="style">list-style-type:circle</xsl:attribute>
							</xsl:if>


							   <!-- iterate through the text as well as invidual refs -->
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
								<xsl:text>&#160;</xsl:text>
							   </xsl:for-each>

						</xsl:element>
					<!--</xsl:if>-->
				</xsl:for-each>
			</ul>			
		</font>
		</xsl:if>

		<xsl:if test="not($unordered)">
		<font color="{$color}">
			<ol>

				<xsl:for-each select="$list">					
                                     <xsl:element name="span">
					<xsl:if test="not(contains(.,'force-ratio')) and not(contains(.,'remaining-strength'))">
					   <xsl:attribute name="ID">extradata</xsl:attribute>
					   <xsl:attribute name="name">extradata</xsl:attribute>
					   <xsl:attribute name="style">display:none</xsl:attribute>
					</xsl:if>

					<!--<xsl:variable name="explflag" select="count(//INFO[TYPE='FORCE-RATIO-EXPLANATION' and SOURCE/individual/@ref=$step])"/>-->
					<xsl:if test="contains(.,'force-ratio')">
					<table>
			                  <xsl:element name="tr">
				          <xsl:attribute name="style"></xsl:attribute>
				          <xsl:attribute name="valign">top</xsl:attribute>
				              <td align="center" style="background-color:#5588bb;cursor:pointer" onclick="toggleDisplayOfEventInfo(this,1);">
					          <xsl:attribute name="ID">Force ratio explanation for <xsl:value-of select="$step"/></xsl:attribute>
					          <span class="sublabelwhite">
					            <xsl:attribute name="ID">Force ratio explanation for <xsl:value-of select="$step"/></xsl:attribute>
					            Force ratio explanation</span>
				              </td>
				              <td style="">
					          <xsl:variable name="utline" select="//INFO[TYPE='UNIT-TIMELINE' and SOURCE/individual/@ref=$step]/CONTENT"/>
					          <xsl:variable name="cptline" select="//INFO[TYPE='COMBAT-POWER-TIMELINE' and SOURCE/individual/@ref=$step]/CONTENT"/>
						  <xsl:call-template name="combat_power_timeline">
						          <xsl:with-param name="top" select="$cptline"/>
						          <xsl:with-param name="step" select="$step"/>
						  </xsl:call-template>
						  <xsl:call-template name="unit_timeline">
						          <xsl:with-param name="top" select="$utline"/>
							  <xsl:with-param name="stfrom" select="$cptline/ITEM[1]/TIME"/>
						          <xsl:with-param name="step" select="$step"/>
						  </xsl:call-template>
                                                  <a class="smallbluelink" style="position:relative;left:20px;margin-top:5px">
						     <xsl:attribute name="id">Show_<xsl:value-of select="$step"/>_Link</xsl:attribute>
                                                     <xsl:attribute name="href">
                                                     javascript:toggleTable('<xsl:value-of select="$step"/>');
						     </xsl:attribute>
                                                     Show Details
                                                  </a>
					          <table style="display:none">
						     <xsl:attribute name="ID"><xsl:value-of select="$step"/>_Explanation</xsl:attribute>
					             <xsl:for-each select="//INFO[TYPE='FORCE-RATIO-EXPLANATION' and SOURCE/individual/@ref=$step]/CONTENT">
					                <tr>
					                 <td align="left" valign="top">
					                   <xsl:call-template name="showdetails">
					                      <xsl:with-param name="list" select="./TEXT/LIST-ITEM"/>
					                      <xsl:with-param name="unordered" select="'yes'"/>
					                   </xsl:call-template>
					                 </td>
					                </tr>
					             </xsl:for-each>
					          </table>
				             </td>
			                    </xsl:element>
					</table>
					</xsl:if>
					
					<xsl:element name="li">
							<!-- iterate through the text as well as invidual refs -->
						<b>
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
							<xsl:text>&#160;</xsl:text>
						</xsl:for-each>
						</b>
					</xsl:element>

					<xsl:if test="contains(.,'triple')">
						<br/><b><font color="red">ENGLISH GENERATION PROBLEM</font></b>
					</xsl:if>
				     </xsl:element>
				</xsl:for-each>
			</ol>

			<xsl:variable name="hidecount" select="count($list[not(contains(.,'force-ratio')) and not(contains(.,'remaining-strength'))])"/>
			<xsl:if test="$hidecount &gt; 0">
			    <span name="hidetext" ID="hidetext">
			    <ul><li>Click <a href="javascript:showAllData('','See hidden items')">here</a> to see other checks</li></ul>
			    </span>
			    <span name="extradata" ID="extradata" style="display:none">
			    <ul><li>Click <a href="javascript:showAllData('','Hide extra items')">here</a> to hide extra checks</li></ul>
			    </span>
			</xsl:if>
		</font>
		</xsl:if>		
	</xsl:template>

<!-- displays the userinputs available for steps -->
	<xsl:template name="userinput">
		<xsl:param name="errorid"/>
                <xsl:if test="not($static = 'true')">
		<xsl:variable name="err" select="//KANAL-OUTPUT/ERROR[ID=$errorid and SUCCESS='NIL']"/>
		<xsl:if test="$err/USER-INPUT">
		<p style="line-height=30px" class="smallbluelink">
		<xsl:for-each select="$err/USER-INPUT/USER-INPUT-ITEM">
			<xsl:choose>
				<xsl:when test="@TYPE='BUTTON'">
					<xsl:choose>
						<xsl:when test="BUTTON-TYPE='Agree'">
							<input type="button" value="{BUTTON-TYPE}" class="bluebutton" onclick="StoreError('{$errorid}',0)"/>					
						</xsl:when>
						<xsl:when test="BUTTON-TYPE='Disagree'">
							<input type="button" value="{BUTTON-TYPE}" class="bluebutton" onclick="StoreError('{$errorid}',1)"/>					
						</xsl:when>
						<xsl:when test="BUTTON-TYPE='Ignore'">
							<input type="button" value="{BUTTON-TYPE}" class="bluebutton" onclick="StoreError('{$errorid}',2)"/>					
						</xsl:when>
					</xsl:choose>
					<xsl:value-of select="./DISPLAY"/>
				</xsl:when>
				<xsl:when test="@TYPE='HREF'">
					<xsl:choose>
						<xsl:when test="contains($errorid,'|')">
							<xsl:variable name="f-errorid" select="substring($errorid,2,string-length($errorid)-2)"/>
							<a href="javascript:OpenFixes('{$f-errorid}')"><xsl:value-of select="DISPLAY"/></a>
						</xsl:when>
						<xsl:otherwise>
							<a href="javascript:OpenFixes('{$errorid}')"><xsl:value-of select="DISPLAY"/></a>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>

			</xsl:choose>
			<br/>
		</xsl:for-each>
		<br/>
		</p>
		</xsl:if>
		</xsl:if>
	</xsl:template>

<!-- displays the selections for every step. name of the template is not good. will change later -->
	<xsl:template name="displaytab">
		<xsl:param name="step"/>
		<xsl:param name="innerloop"/>

            
		<xsl:if test='not($step="")'>
		<xsl:if test="(not($innerloop=1) and not(//INFO/CONTENT/LIST-ITEM/SUBEVENTS/SUBEVENT[individual/@ref = $step])) or ($innerloop=1)">
			
<!-- this is not boolean as it appears by name. it is the actual count -->
			<xsl:variable name="has-subevents" select="count(//INFO/CONTENT/LIST-ITEM[EVENT/individual/@ref = $step])"/>
			<script type="text/javascript">
				var has_subevents<xsl:value-of select="translate($step,'-','_')"/> = <xsl:value-of select="$has-subevents"/>;	
			</script>

			<script>
				var srctab<xsl:value-of select="translate($step,'-','_')"/>="";
                                <xsl:if test="$static = 'true'">
				    srctab<xsl:value-of select="translate($step,'-','_')"/>= "<xsl:value-of select="$static_server"/>";
                                </xsl:if>

				srctab<xsl:value-of select="translate($step,'-','_')"/> += "/images/kanal/unchecked.gif";
				var tabnameclass<xsl:value-of select="translate($step,'-','_')"/>="bluelink";
				var tabnamedisplay<xsl:value-of select="translate($step,'-','_')"/>="none";

                                <!-- xxxxxxxxx Everything is unchecked initially xxxxxxxxx (show only first steps) -->
				if(errorinstep<xsl:value-of select="translate($step,'-','_')"/> &gt; 0 || errorinsubstep<xsl:value-of select="translate($step,'-','_')"/> &gt; 0) {
					tabnameclass<xsl:value-of select="translate($step,'-','_')"/>="redlink";
					tabnamedisplay<xsl:value-of select="translate($step,'-','_')"/>="none";
				}
				else if(warninginstep<xsl:value-of select="translate($step,'-','_')"/> &gt; 0 || warninginsubstep<xsl:value-of select="translate($step,'-','_')"/> &gt; 0) {
					tabnameclass<xsl:value-of select="translate($step,'-','_')"/>="brownlink";
					tabnamedisplay<xsl:value-of select="translate($step,'-','_')"/>="none";
				}
			</script>
			
			<tr>
			<td valign="top">
			<xsl:element name="img">
				<xsl:attribute name="id">tab<xsl:value-of select="$step"/></xsl:attribute>
				<xsl:attribute name="style">cursor:pointer</xsl:attribute>
                                <xsl:if test="$static = 'true'">
				   <xsl:attribute name="src"><xsl:value-of select="$static_server"/>/images/kanal/checked.gif</xsl:attribute>
                                </xsl:if>
                                <xsl:if test="not($static = 'true')">
				   <xsl:attribute name="src">/images/kanal/checked.gif</xsl:attribute>
                                </xsl:if>
				<xsl:attribute name="onClick">javascript:toggleStepForTab('<xsl:value-of select="$step"/>');</xsl:attribute>
			</xsl:element>
			</td>
			<td>
			  <xsl:attribute name="ID">tabname<xsl:value-of select="translate($step,'-','_')"/></xsl:attribute>
			</td>

			<script>
				var str = '&lt;span class=' + tabnameclass<xsl:value-of select="translate($step,'-','_')"/>;
				str += ' onclick="javascript:toggleStepForTab(\'<xsl:value-of select="$step"/>\')"';
				str += ' id="texttab<xsl:value-of select="$step"/>">';
				str += '  <xsl:apply-templates select="$step/parent::node()" mode="get-english"/>' + '&lt;br/>&lt;br/>&lt;/span>';
				var item = document.getElementById("tabname<xsl:value-of select="translate($step,'-','_')"/>");
				item.innerHTML = str;
			</script>

<!--
			<td>
			   <xsl:attribute name="class">bluelink</xsl:attribute>
			   <xsl:attribute name="onclick">javascript:toggleStepForTab('<xsl:value-of select="$step"/>');</xsl:attribute>
			   <xsl:attribute name="id">texttab<xsl:value-of select="$step"/></xsl:attribute>
			   <xsl:text> </xsl:text>
			   <xsl:apply-templates select="$step/parent::node()" mode="get-english"/>
			   <br/><br/>
			</td>
			-->
			
			</tr>

			
			<xsl:element name="tr">
			<xsl:attribute name="id">tabdummyrow<xsl:value-of select="$step"/></xsl:attribute>
			<td></td>
			<td>

			<xsl:if test="$has-subevents>0">
					<table>
					<xsl:for-each select="//INFO/CONTENT/LIST-ITEM/SUBEVENTS/SUBEVENT[../../EVENT/individual/@ref = $step]">
						<xsl:call-template name="displaytab">
							<xsl:with-param name="step" select="individual/@ref"/>
							<xsl:with-param name="innerloop" select="1"/>
						</xsl:call-template>
					</xsl:for-each>
					</table>
			</xsl:if>
			<!--<xsl:if test="not(//INFO/CONTENT/LIST-ITEM/SUBEVENTS/SUBEVENT[individual/@ref=$step])">
				<script type="text/javascript">
					resultstartrow = resultstartrow + rcount<xsl:value-of select="translate($step,'-','_')"/> + has_subevents<xsl:value-of select="translate($step,'-','_')"/>;
                                        alert(resultstartrow);
				</script>
			</xsl:if>-->
			</td>
			</xsl:element>

			<script type="text/javascript">
				var temp = document.getElementById('tab<xsl:value-of select="$step"/>');
				temp.src = srctab<xsl:value-of select="translate($step,'-','_')"/>;
				temp = document.getElementById('tabdummyrow<xsl:value-of select="$step"/>');
				temp.style.display = tabnamedisplay<xsl:value-of select="translate($step,'-','_')"/>;
			</script>
     					
		</xsl:if>
		</xsl:if>
	</xsl:template>

<!-- displays the simulation steps -->

	<xsl:template name="printstep">
		<xsl:param name="step"/>
		<xsl:param name="innerloop"/>
            
		<xsl:if test='not($step="")'>
		<xsl:if test="(not($innerloop=1) and not(//INFO/CONTENT/LIST-ITEM/SUBEVENTS/SUBEVENT[individual/@ref = $step])) or ($innerloop=1)">

		<!--<tr><td colspan="2">Step is : <xsl:value-of select="$step"/></td></tr>-->
			
<!-- getting the start time of the step  -->
			<xsl:variable name="start-time" select="//INFO[TYPE='EVENT-START-TIMES']/CONTENT/START-TIME[EVENT/individual/@ref=$step]"/>

			<script>
				var src<xsl:value-of select="translate($step,'-','_')"/>="";

                                <xsl:if test="$static = 'true'">
				    src<xsl:value-of select="translate($step,'-','_')"/>="<xsl:value-of select="$static_server"/>";
                                </xsl:if>

				src<xsl:value-of select="translate($step,'-','_')"/>+="/images/kanal/right.gif";
				var  imgtype<xsl:value-of select="translate($step,'-','_')"/>=0

				if(errorinstep<xsl:value-of select="translate($step,'-','_')"/> &gt; 0 || errorinsubstep<xsl:value-of select="translate($step,'-','_')"/> &gt; 0) {
					src<xsl:value-of select="translate($step,'-','_')"/>+="/images/kanal/eright.gif"
					imgtype<xsl:value-of select="translate($step,'-','_')"/>=2
				}
				else if(warninginstep<xsl:value-of select="translate($step,'-','_')"/> &gt; 0 || warninginsubstep<xsl:value-of select="translate($step,'-','_')"/> &gt; 0) {
					src<xsl:value-of select="translate($step,'-','_')"/>+="/images/kanal/wright.gif"
					imgtype<xsl:value-of select="translate($step,'-','_')"/>=1
				}
			</script>

			<!-- adding agents and objects -->
			<xsl:for-each select="//INFO[TYPE='TIME-VARYING-PROPERTIES-INFO' and SOURCE/individual/@ref=$step]/CONTENT/AGENT-OBJECT">
				<script>
					<xsl:for-each select="./NAME">
						<xsl:variable name="unit-name"><xsl:apply-templates select="./individual" mode="get-english"/></xsl:variable>
						<xsl:variable name="unit-ref" select="./individual/@ref"/>
						addUnit('<xsl:value-of select="$unit-ref"/>','<xsl:value-of select="$unit-name"/>','<xsl:value-of select="$step"/>')
						<xsl:for-each select="../OLD-PROPERTIES/PROPERTY">
						        <xsl:variable name="propval"><xsl:apply-templates select="PROPERTY-VALUE" mode="get-english"/></xsl:variable>
						        var tmp = "<xsl:value-of select="normalize-space($propval)"/>";
							addProperty('<xsl:value-of select="PROPERTY-NAME"/>');
                                                        setPropertyValue("<xsl:value-of select="PROPERTY-NAME"/>","<xsl:value-of select="$unit-ref"/>", current_step, tmp, 1);
						</xsl:for-each>
						<xsl:for-each select="../NEW-PROPERTIES/PROPERTY">
						        <xsl:variable name="propval"><xsl:apply-templates select="PROPERTY-VALUE" mode="get-english"/></xsl:variable>
						        var tmp = "<xsl:value-of select="normalize-space($propval)"/>";
							addProperty('<xsl:value-of select="PROPERTY-NAME"/>');
                                                        setPropertyValue("<xsl:value-of select="PROPERTY-NAME"/>","<xsl:value-of select="$unit-ref"/>", current_step, tmp, 0);
						</xsl:for-each>
					</xsl:for-each>
				</script>
			</xsl:for-each>



                        <!-- tr 1 : step: -->
			<xsl:element name="tr">
				<xsl:attribute name="style">display:none</xsl:attribute>
				<td colspan="2">
					<p>
					<xsl:element name="img">
						<xsl:attribute name="id"><xsl:value-of select="$step"/></xsl:attribute>
						<xsl:attribute name="style">cursor:pointer</xsl:attribute>
                                                <xsl:if test="$static = 'true'">
				                   <xsl:attribute name="src"><xsl:value-of select="$static_server"/>/images/kanal/right.gif</xsl:attribute>
                                                </xsl:if>
                                                <xsl:if test="not($static = 'true')">
				                   <xsl:attribute name="src">/images/kanal/right.gif</xsl:attribute>
                                                </xsl:if>
						<xsl:attribute name="onClick">toggleDisplayOfSteps(this, rcount<xsl:value-of select="translate($step,'-','_')"/> + has_subevents<xsl:value-of select="translate($step,'-','_')"/>,imgtype<xsl:value-of select="translate($step,'-','_')"/>,0,<xsl:value-of select="$innerloop"/>);</xsl:attribute>
					</xsl:element>
					<script type="text/javascript">
						var tempimg = document.getElementById('<xsl:value-of select="$step"/>');
						tempimg.src = src<xsl:value-of select="translate($step,'-','_')"/>;
					</script>
				   	<b>
						<xsl:choose>
							<xsl:when test="//INFO/CONTENT/LIST-ITEM/SUBEVENTS/SUBEVENT[individual/@ref = $step]">
								Substep:
							</xsl:when>
							<xsl:otherwise>
								Step: 
							</xsl:otherwise>
						</xsl:choose>

						<xsl:apply-templates select="$step/parent::node()" mode="make-link"/>			
                                            <xsl:if test="not($static = 'true')">
                                                &#160; <i>Do you agree with the results for this step ?</i>
                                                &#160;<a class="smallbluelink"><xsl:attribute name="onclick">javascript:Agree('<xsl:value-of select="$step"/>')</xsl:attribute>Yes</a>
                                                &#160;<a class="smallbluelink"><xsl:attribute name="onclick">javascript:Disagree('<xsl:value-of select="$step"/>')</xsl:attribute>No</a>
                                            </xsl:if>
					</b>
					<br/><br/>
				</p>
			</td>
			</xsl:element>

			
                        <!-- tr 2 : step info before execution-->
			<xsl:element name="tr">
				<xsl:attribute name="style">display:none</xsl:attribute>
				<xsl:attribute name="valign">top</xsl:attribute>
				<td align="center" style="background-color:#5588bb;cursor:pointer" onclick="toggleDisplayOfEventInfo(this,1);">
					<xsl:attribute name="ID">Step information for <xsl:value-of select="$step"/></xsl:attribute>
					<span class="sublabelwhite">
					<xsl:attribute name="ID">Step information for <xsl:value-of select="$step"/></xsl:attribute>
					Step information </span>
				</td>
				<td style="display:none">
					<table>
						<tr>
							<td align="right" valign="top"><b>Roles</b></td>
							<td><ul style="list-style-type:none"><li><b>Values</b></li></ul></td>
						</tr>
						<xsl:if test="//INFO[TYPE='SIMULATED-PATHS']/CONTENT/PATH/LIST-ITEM/LIST-ITEM/individual/@ref=$step">
							<tr>
								<td align="right">Start Time:
								</td>
								<td> 
									<p style="text-indent:40px">
									
									<xsl:call-template name="translate-operator">
										<xsl:with-param name="str" select="$start-time/OPERATOR"/>
									</xsl:call-template>
									
									
									<xsl:text> </xsl:text>
									
									<xsl:variable name="stime" select="$start-time/VALUE"/>
									<xsl:choose>
										<xsl:when test="contains($stime,'d0')">
											<xsl:value-of select="substring-before($stime,'d0')"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="$stime"/>
										</xsl:otherwise>
									</xsl:choose>
									</p>
								</td>
							</tr>
							<xsl:if test="not($start-time/DURATION='NIL')">
								<tr>
									<td align="right">
										Duration:
									</td>
									<td>
										<p style="text-indent:40px">
										<xsl:variable name="dur" select="$start-time/DURATION"/>
										<xsl:choose>
											<xsl:when test="contains($dur,'d0')">
												<xsl:value-of select="substring-before($dur,'d0')"/>
											</xsl:when>
											<xsl:otherwise>
												<xsl:value-of select="$dur"/>
											</xsl:otherwise>
										</xsl:choose>
										</p>
									</td>
								</tr>
							</xsl:if>
						</xsl:if>

						<xsl:for-each select="//INFO[SOURCE/individual/@ref=$step]/CONTENT/INFO-ITEM">
							<xsl:if test="not(./NAME='pcs-list' or ./NAME='del-list' or ./NAME='add-list' or ./NAME='time' or ./NAME='duration')">
							<tr>
								<td align="right" valign="top">
									<xsl:call-template name="format-text1">
										<xsl:with-param name="text" select="./NAME"/>
									</xsl:call-template>
									<xsl:text>:</xsl:text>
								</td>
								<td>
									<xsl:call-template name="showdetails">
										<xsl:with-param name="list" select="./DETAIL/LIST-ITEM/LIST-ITEM"/>
										<xsl:with-param name="unordered" select="'yes'"/>
									</xsl:call-template>								
								</td>
							</tr>	
							</xsl:if>
						</xsl:for-each>

						<xsl:variable name="prec0" select="//INFO[SOURCE/individual/@ref=$step]/CONTENT/INFO-ITEM[NAME='soft-pcs-list']"/>
						<xsl:if test="$prec0">
							<tr>
								<td align="right" valign="top">
									<xsl:call-template name="format-text1">
										<xsl:with-param name="text" select="$prec0/NAME"/>
									</xsl:call-template>
									<xsl:text>:</xsl:text>
								</td>
								<td>
									<xsl:call-template name="showdetails">
										<xsl:with-param name="list" select="$prec0/DETAIL/LIST-ITEM/LIST-ITEM"/>
										<xsl:with-param name="unordered" select="'yes'"/>
										<xsl:with-param name="sortorder" select="'descending'"/>
									</xsl:call-template>
								</td>
							</tr>
						</xsl:if>
						<xsl:variable name="prec1" select="//INFO[SOURCE/individual/@ref=$step]/CONTENT/INFO-ITEM[NAME='pcs-list']"/>
						<xsl:if test="$prec1">
							<tr>
								<td align="right" valign="top">
									<xsl:call-template name="format-text1">
										<xsl:with-param name="text" select="$prec1/NAME"/>
									</xsl:call-template>
									<xsl:text>:</xsl:text>
								</td>
								<td>
									<xsl:call-template name="showdetails">
										<xsl:with-param name="list" select="$prec1/DETAIL/LIST-ITEM/LIST-ITEM"/>
										<xsl:with-param name="unordered" select="'yes'"/>
										<xsl:with-param name="sortorder" select="'descending'"/>
									</xsl:call-template>
								</td>
							</tr>
						</xsl:if>
						<xsl:variable name="prec2" select="//INFO[SOURCE/individual/@ref=$step]/CONTENT/INFO-ITEM[NAME='del-list']"/>
						<xsl:if test="$prec2">
							<tr>
								<td align="right" valign="top">
									<xsl:call-template name="format-text1">
										<xsl:with-param name="text" select="$prec2/NAME"/>
									</xsl:call-template>
									<xsl:text>:</xsl:text>
								</td>
								<td>
									<xsl:call-template name="showdetails">
										<xsl:with-param name="list" select="$prec2/DETAIL/LIST-ITEM/LIST-ITEM"/>
										<xsl:with-param name="unordered" select="'yes'"/>
									</xsl:call-template>
								</td>
							</tr>
						</xsl:if>

						<xsl:variable name="prec3" select="//INFO[SOURCE/individual/@ref=$step]/CONTENT/INFO-ITEM[NAME='add-list']"/>
						<xsl:if test="$prec3">
							<tr>
								<td align="right" valign="top">
									<xsl:call-template name="format-text1">
										<xsl:with-param name="text" select="$prec3/NAME"/>
									</xsl:call-template>
									<xsl:text>:</xsl:text>
								</td>
								<td>
									<xsl:call-template name="showdetails">
										<xsl:with-param name="list" select="$prec3/DETAIL/LIST-ITEM/LIST-ITEM"/>
										<xsl:with-param name="unordered" select="'yes'"/>
									</xsl:call-template>
								</td>
							</tr>
						</xsl:if>
					</table>
				</td>
			</xsl:element>


                                        <!-- tr 3 (1 for each error) = rcount<step> -->
					<xsl:for-each select="//KANAL-OUTPUT/ERROR">					
						<xsl:if test="SOURCE/individual/@ref=$step">
							<xsl:variable name="tr" select="CONSTRAINT/ADD-ITEM"/>
							<xsl:variable name="errorid" select="substring(ID,2,string-length(ID)-2)"/>
							
							<xsl:if test="contains(TYPE,'NO-EFFECT') and string-length(TYPE) &lt; string-length('NO-EFFECT') + 2">
								
								<xsl:variable name="tr1" select="CONSTRAINT/DEL-ITEM"/>
								<xsl:variable name="rf" select="CONSTRAINT/ADD-ITEM/individual/@ref"/>
								<xsl:variable name="rf1" select="CONSTRAINT/DEL-ITEM/individual/@ref"/>
									<xsl:if test="//INFO/CONTENT/LIST-ITEM[EVENT/individual/@ref = $step]">
										
										<xsl:element name="tr">
											<xsl:attribute name="style">display:none</xsl:attribute>
											<td align="right">
											<span class="sublabel" style="cursor:pointer"> 
					                                                    <xsl:attribute name="ID">Seeing substeps for : <xsl:value-of select="$step"/></xsl:attribute>
											    <xsl:attribute name="onclick">toggleChildren("<xsl:value-of select="$step"/>");</xsl:attribute>
											    Substeps are:</span>
											</td>
											<td></td>
										</xsl:element>

										<xsl:if test="//INFO/CONTENT/LIST-ITEM/SUBEVENTS[../EVENT/individual/@ref = $step]">
											
											<xsl:element name="tr">
											<xsl:attribute name="style">display:none</xsl:attribute>
											<td></td>
											<td>		
											<table border="0" cellpadding="0" cellspacing="2">
											<xsl:for-each select="//INFO/CONTENT/LIST-ITEM/SUBEVENTS/SUBEVENT[../../EVENT/individual/@ref = $step]">
											        <script>
												    if(!stepChildren["<xsl:value-of select="$step"/>"]) {
													stepChildren["<xsl:value-of select="$step"/>"] = "<xsl:value-of select="./individual/@ref"/>";
												    } else {
													stepChildren["<xsl:value-of select="$step"/>"] += "\01<xsl:value-of select="./individual/@ref"/>";
												    }
												</script>
												<xsl:call-template name="printstep">
													<xsl:with-param name="step" select="./individual/@ref"/>
													<xsl:with-param name="innerloop" select="1"/>
												</xsl:call-template>
											</xsl:for-each>					
											</table>
											</td>
											</xsl:element>
										</xsl:if>
									</xsl:if>
									    <xsl:element name="tr">
										<xsl:attribute name="valign">top</xsl:attribute>
										<xsl:attribute name="style">display:none</xsl:attribute>
										
											<td align="right">					
												<span class="sublabel" onclick="toggleDisplayOfEventInfo(this.parentNode,1);" style="cursor:pointer"> Checking effects</span>
											</td>
									
											<td style="">
												<font color="black">
													<br/>
													<i>Note: These effects are valid just before/after the end of the step. For changes during the event, you can see its substeps.</i><br/><br/>
													<xsl:if test="$tr1 or $rf1">
            													The following becomes false (just before the end of step):
														<xsl:call-template name="showdetails" >
														      <xsl:with-param name="list" select="CONSTRAINT/DEL-ITEM" />
														</xsl:call-template>

		            									        </xsl:if>
													<xsl:if test="$tr or $rf">
            													The following becomes true (just after the end of step):
														<xsl:call-template name="showdetails" >
														      <xsl:with-param name="list" select="CONSTRAINT/ADD-ITEM" />
														</xsl:call-template>
		
            											</xsl:if>
													<xsl:if test="not($tr1 or $rf1 or $tr or $rf)">
														<font color="brown">
                        		            		                                                    <b><font color="black"> Note: </font></b> No effect was produced by the step			
														</font>	
													</xsl:if>
												</font>
												<xsl:call-template name="userinput">
													<xsl:with-param name="errorid" select="ID"/>
												</xsl:call-template>
											</td>
									        </xsl:element>
							</xsl:if>

			                                <xsl:variable name="combatcount" select="count(CONSTRAINT/PRECONDITION[not(contains(.,'force-ratio')) and not(contains(.,'remaining-strength'))])"/>

							<xsl:if test="contains(TYPE,'PRECONDITION') and string-length(TYPE) &lt; string-length('PRECONDITION') + 2">
								<tr>
								<xsl:attribute name="valign">top</xsl:attribute>
								<xsl:attribute name="style">display:none</xsl:attribute>
									<td align="right">
										<xsl:variable name="pos" select="position()"/>
										<xsl:if test="not(../ERROR[TYPE='INEXPLICIT-PRECONDITION' and position() &lt; $pos and SOURCE/individual/@ref=$step]) and not(../ERROR[TYPE='PRECONDITION' and position() &lt; $pos and SOURCE/individual/@ref=$step])">
											<xsl:variable name="tcount" select="count(../ERROR[TYPE='INEXPLICIT-PRECONDITION' and SOURCE/individual/@ref=$step]) + count(../ERROR[TYPE='PRECONDITION' and SOURCE/individual/@ref=$step])"/>
											<span class="sublabel" onclick="toggleDisplayOfEventInfo(this.parentNode,{$tcount});" style="cursor:pointer"> 
					                                                    <xsl:attribute name="ID">Checking conditions for <xsl:value-of select="$step"/></xsl:attribute>
											    Checking conditions<br/><br/></span>
										</xsl:if>
									</td>

									<td>
									<xsl:if test="SUCCESS='NIL'">
									       <xsl:call-template name="showdetails" >
										      <xsl:with-param name="list" select="CONSTRAINT/PRECONDITION" />
										      <xsl:with-param name="color" select="'red'"/>
										      <xsl:with-param name="step" select="$step"/>
										</xsl:call-template>
										<font color="red">
											-> The <xsl:value-of select="count(CONSTRAINT/PRECONDITION)"/> condition(s) failed
										</font>		

									</xsl:if>
									<xsl:if test="SUCCESS='T'">
										<font color="black">
										      <xsl:call-template name="showdetails" >
											      <xsl:with-param name="list" select="CONSTRAINT/PRECONDITION" />
										              <xsl:with-param name="step" select="$step"/>
											</xsl:call-template>						
											-> The above condition(s) succeeded
										</font>
									</xsl:if>
									<xsl:call-template name="userinput">
										<xsl:with-param name="errorid" select="ID"/>
									</xsl:call-template>
									</td>
								</tr>
							</xsl:if>

							<xsl:if test="contains(TYPE,'CANNOT-DELETE') and string-length(TYPE) &lt; string-length('CANNOT-DELETE') + 2">
								
								<xsl:element name="tr">
									<xsl:attribute name="valign">top</xsl:attribute>
									<xsl:attribute name="style">display:none</xsl:attribute>
									<td align="right">
										<xsl:variable name="pos" select="position()"/>
										<xsl:if test="not(../ERROR[TYPE='CANNOT-DELETE' and position() &lt; $pos and SOURCE/individual/@ref=$step])">
											<xsl:variable name="tcount" select="count(../ERROR[TYPE='CANNOT-DELETE' and SOURCE/individual/@ref=$step])"/>
											<span class="sublabel" onclick="toggleDisplayOfEventInfo(this.parentNode,{$tcount});" style="cursor:pointer"> Checking of non deletion<br/><br/></span>
										</xsl:if>
									</td>
									<td style="">
										<xsl:if test="SUCCESS = 'NIL'">
										<font color="brown">
											<br/> 
                                                                  <b><font color="black"> Note: </font></b> The step could not delete the following conditions:
											<br/> 
										</font>	
										</xsl:if>

										<font color="black">
										       <xsl:call-template name="showdetails" >
											      <xsl:with-param name="list" select="CONSTRAINT/CANNOT-DELETE" />
												<xsl:with-param name="color" select="'brown'"/>
											</xsl:call-template>
										</font>
										<xsl:call-template name="userinput">
											<xsl:with-param name="errorid" select="ID"/>
										</xsl:call-template>

									</td>
								</xsl:element>
							</xsl:if>
							<xsl:if test="contains(TYPE,'INEXPLICIT-PRECONDITION') and string-length(TYPE) &lt; string-length('INEXPLICIT-PRECONDITION') + 2">
								
								<xsl:element name="tr">
									<xsl:attribute name="valign">top</xsl:attribute>
									<xsl:attribute name="style">display:none</xsl:attribute>
									<td align="right">
										<xsl:variable name="pos" select="position()"/>
										<xsl:if test="not(../ERROR[TYPE='INEXPLICIT-PRECONDITION' and position() &lt; $pos and SOURCE/individual/@ref=$step]) and not(../ERROR[TYPE='PRECONDITION' and position() &lt; $pos and SOURCE/individual/@ref=$step])">
											<xsl:variable name="tcount" select="count(../ERROR[TYPE='INEXPLICIT-PRECONDITION' and SOURCE/individual/@ref=$step]) + count(../ERROR[TYPE='PRECONDITION' and SOURCE/individual/@ref=$step])"/>
											<span class="sublabel" onclick="toggleDisplayOfEventInfo(this.parentNode,{$tcount});" style="cursor:pointer">
					                                                    <xsl:attribute name="ID">Checking conditions for <xsl:value-of select="$step"/></xsl:attribute>
											    Checking conditions<br/><br/></span>
									        </xsl:if>
									</td>
									<td style="">
									<!-- XXXXXX force ratio explanation was here XXXXXXX -->
										<xsl:if test="SUCCESS = 'NIL'">
                                                                                  <xsl:element name="span">
										     <xsl:if test="$combatcount &gt; 0">
					                                                <xsl:attribute name="ID">extradata</xsl:attribute>
					                                                <xsl:attribute name="name">extradata</xsl:attribute>
					                                                <xsl:attribute name="style">display:none</xsl:attribute>
					                                             </xsl:if>
										     <font color="brown">
										     <br/> 
                                                                                      <b><font color="black"> Note: </font></b> 
										        You never told me the following conditions were true, 
											<br/> 
											but we can safely ignore these conditions: 
										     </font>	
										  </xsl:element>
										</xsl:if>
										<font color="black">
										       <xsl:call-template name="showdetails" >
											      <xsl:with-param name="list" select="CONSTRAINT/PRECONDITION" />
											      <xsl:with-param name="color" select="('brown')" />	
											      <xsl:with-param name="step" select="$step"/>
											</xsl:call-template>
										</font>
                                                                                <xsl:element name="span">
										    <xsl:if test="$combatcount &gt; 0">
					                                               <xsl:attribute name="ID">extradata</xsl:attribute>
					                                               <xsl:attribute name="name">extradata</xsl:attribute>
					                                               <xsl:attribute name="style">display:none</xsl:attribute>
					                                            </xsl:if>
										    <xsl:call-template name="userinput">
											<xsl:with-param name="errorid" select="ID"/>
										    </xsl:call-template>
										</xsl:element>
									</td>
								</xsl:element>
							</xsl:if>

							<xsl:if test="contains(TYPE,'INEXPLICIT-SOFT-PRECONDITION') and string-length(TYPE) &lt; string-length('INEXPLICIT-SOFT-PRECONDITION') + 2">
								<xsl:element name="tr">
									<xsl:attribute name="valign">top</xsl:attribute>
									<xsl:attribute name="style">display:none</xsl:attribute>
									<td align="right">
										<xsl:variable name="pos" select="position()"/>
										<xsl:if test="not(../ERROR[TYPE='INEXPLICIT-SOFT-PRECONDITION' and position() &lt; $pos and SOURCE/individual/@ref=$step]) and not(../ERROR[TYPE='SOFT-PRECONDITION' and position() &lt; $pos and SOURCE/individual/@ref=$step])">
											<xsl:variable name="tcount" select="count(../ERROR[TYPE='INEXPLICIT-SOFT-PRECONDITION' and SOURCE/individual/@ref=$step]) + count(../ERROR[TYPE='SOFT-PRECONDITION' and SOURCE/individual/@ref=$step])"/>
											<span class="sublabel" onclick="toggleDisplayOfEventInfo(this.parentNode,{$tcount});" style="cursor:pointer"> 
					                                                    <xsl:attribute name="ID">Checking soft conditions for <xsl:value-of select="$step"/></xsl:attribute>
											    Checking soft conditions<br/><br/></span>
										</xsl:if>
									</td>
									<td style="">
										<xsl:if test="SUCCESS = 'NIL'">
                                                                                  <xsl:element name="span">
										     <xsl:if test="$combatcount &gt; 0">
					                                                <xsl:attribute name="ID">extradata</xsl:attribute>
					                                                <xsl:attribute name="name">extradata</xsl:attribute>
					                                                <xsl:attribute name="style">display:none</xsl:attribute>
					                                             </xsl:if>
										<font color="brown">
											<br/> 
                                                                  <b><font color="black"> Note: </font></b> You never told me the following conditions were true, 
											<br/> 
											but we can safely ignore these conditions: 
										</font>	
										  </xsl:element>
										</xsl:if>
										<font color="black">
										       <xsl:call-template name="showdetails" >
											      <xsl:with-param name="list" select="CONSTRAINT/PRECONDITION" />
												<xsl:with-param name="color" select="('brown')" />	
										                <xsl:with-param name="step" select="$step"/>
											</xsl:call-template>
										</font>
                                                                                  <xsl:element name="span">
										     <xsl:if test="$combatcount &gt; 0">
					                                                <xsl:attribute name="ID">extradata</xsl:attribute>
					                                                <xsl:attribute name="name">extradata</xsl:attribute>
					                                                <xsl:attribute name="style">display:none</xsl:attribute>
					                                             </xsl:if>
										<xsl:call-template name="userinput">
											<xsl:with-param name="errorid" select="ID"/>
										</xsl:call-template>
										  </xsl:element>

									</td>
								</xsl:element>
							</xsl:if>

							<xsl:if test="contains(TYPE,'SOFT-PRECONDITION') and string-length(TYPE) &lt; string-length('SOFT-PRECONDITION') + 2">
								<xsl:element name="tr">
									<xsl:attribute name="valign">top</xsl:attribute>
									<xsl:attribute name="style">display:none</xsl:attribute>
									<td align="right">
										<xsl:variable name="pos" select="position()"/>
										<xsl:if test="not(../ERROR[TYPE='INEXPLICIT-SOFT-PRECONDITION' and position() &lt; $pos and SOURCE/individual/@ref=$step]) and not(../ERROR[TYPE='SOFT-PRECONDITION' and position() &lt; $pos and SOURCE/individual/@ref=$step])">
											<xsl:variable name="tcount" select="count(../ERROR[TYPE='INEXPLICIT-SOFT-PRECONDITION' and SOURCE/individual/@ref=$step]) + count(../ERROR[TYPE='SOFT-PRECONDITION' and SOURCE/individual/@ref=$step])"/>
											<span class="sublabel" onclick="toggleDisplayOfEventInfo(this.parentNode,{$tcount});" style="cursor:pointer"> 
					                                                 <xsl:attribute name="ID">Checking soft conditions for <xsl:value-of select="$step"/></xsl:attribute>
                                                                                         Checking soft conditions<br/><br/></span>
										</xsl:if>
									</td>
									<td style="">

										<xsl:if test="SUCCESS = 'NIL'">
                                                                                  <xsl:element name="span">
										     <xsl:if test="$combatcount &gt; 0">
					                                                <xsl:attribute name="ID">extradata</xsl:attribute>
					                                                <xsl:attribute name="name">extradata</xsl:attribute>
					                                                <xsl:attribute name="style">display:none</xsl:attribute>
					                                             </xsl:if>
										<font color="brown">
											<br/> 
                                                                  <b><font color="black"> Warning: </font></b> System found these conditions to be false: 

										</font>	
										  </xsl:element>
										</xsl:if>
										<font color="black">
										       <xsl:if test="SUCCESS = 'NIL'">
										          <xsl:call-template name="showdetails" >
											      <xsl:with-param name="list" select="CONSTRAINT/PRECONDITION" />
											      <xsl:with-param name="color" select="('brown')" />
										              <xsl:with-param name="step" select="$step"/>
											  </xsl:call-template>
                                                                                       </xsl:if>
										       <xsl:if test="SUCCESS = 'T'">
										          <xsl:call-template name="showdetails" >
											      <xsl:with-param name="list" select="CONSTRAINT/PRECONDITION" />
											      <xsl:with-param name="color" select="('black')" />
										              <xsl:with-param name="step" select="$step"/>
											  </xsl:call-template>
                                                                                       </xsl:if>
										</font>
                                                                                  <xsl:element name="span">
										     <xsl:if test="$combatcount &gt; 0">
					                                                <xsl:attribute name="ID">extradata</xsl:attribute>
					                                                <xsl:attribute name="name">extradata</xsl:attribute>
					                                                <xsl:attribute name="style">display:none</xsl:attribute>
					                                             </xsl:if>
										<xsl:call-template name="userinput">
											<xsl:with-param name="errorid" select="ID"/>
										</xsl:call-template>
										  </xsl:element>

									</td>
								</xsl:element>
							</xsl:if>

							<xsl:if test="contains(TYPE,'EXPECTED-EFFECT-FOR-STEP') and string-length(TYPE) &lt; string-length('EXPECTED-EFFECT-FOR-STEP') + 2">
								<xsl:element name="tr">
									<xsl:attribute name="valign">top</xsl:attribute>
									<xsl:attribute name="style">display:none</xsl:attribute>
									<td align="right">								
										<xsl:variable name="pos" select="position()"/>
										<xsl:if test="not(../ERROR[TYPE='EXPECTED-EFFECT-FOR-STEP' and position() &lt; $pos and SOURCE/individual/@ref=$step])">
											<xsl:variable name="tcount" select="count(../ERROR[TYPE='EXPECTED-EFFECT-FOR-STEP' and SOURCE/individual/@ref=$step])"/>
											<span class="sublabel" onclick="toggleDisplayOfEventInfo(this.parentNode,1);" style="cursor:pointer"> Checking expected effects for step<br/><br/></span>
										</xsl:if>
									</td>
									<td style="">
										<font color="red">
											<xsl:if test="SUCCESS = 'NIL' and LEVEL='ERROR'">
										       <xsl:call-template name="showdetails" >
											      <xsl:with-param name="list" select="CONSTRAINT/EXPECTED-EFFECT" />
												<xsl:with-param name="color" select="'red'"/>
											</xsl:call-template>
											-> The <xsl:value-of select="count(CONSTRAINT/EXPECTED-EFFECT)"/> expected effect(s) failed
											</xsl:if>
										</font>
										<font color="brown">
											<xsl:if test="SUCCESS = 'NIL' and LEVEL='WARNING'">
										       <xsl:call-template name="showdetails" >
											      <xsl:with-param name="list" select="CONSTRAINT/EXPECTED-EFFECT" />
												<xsl:with-param name="color" select="'brown'"/>
											</xsl:call-template>
											-> The <xsl:value-of select="count(CONSTRAINT/EXPECTED-EFFECT)"/> expected effect(s) failed
											</xsl:if>
										</font>
										<font color="black">
											<xsl:if test="SUCCESS = 'T'">
										       <xsl:call-template name="showdetails" >
											      <xsl:with-param name="list" select="CONSTRAINT/EXPECTED-EFFECT" />
											</xsl:call-template>
											-> The <xsl:value-of select="count(CONSTRAINT/EXPECTED-EFFECT)"/> expected effect(s) succeeded

											</xsl:if>
										</font>

										<br/><br/>
										<xsl:call-template name="userinput">
											<xsl:with-param name="errorid" select="ID"/>
										</xsl:call-template>
									</td>
								</xsl:element>
							</xsl:if>
						</xsl:if>
					</xsl:for-each>

                                        <xsl:if test="not($static = 'true')">
                                        <!-- tr 4 (for non static pages) -->
                                        <tr valign="top" style="display:none"> 
                                          <td valign="top"></td>
                                          <td valign="top">
                                           <a class="smallbluelink">
                                              <xsl:attribute name="href">
                                              javascript:createSpecialCase('<xsl:value-of select="//request-response/dictionary/individual[@id=$step]/class/@ref"/>')</xsl:attribute>
                                                  Create a special case of the action
                                           </a><br/><br/>
                                        </td></tr>
                                        </xsl:if>

			<!--<script type="text/javascript">
    				displayErrorSteps(rcount<xsl:value-of select="translate($step,'-','_')"/>,<xsl:value-of select="$innerloop"/>)
			</script>-->

		</xsl:if>
		</xsl:if>

	</xsl:template>

<!-- displays results like unnecessary links etc.-->
	<xsl:template name="printresult">
		<xsl:param name="step"/>
		<xsl:if test='not($step="")'>

					<xsl:for-each select="//KANAL-OUTPUT/ERROR">					
						<xsl:if test="SOURCE/class/@ref=$step">
							<xsl:variable name="tr" select="CONSTRAINT/ADD-ITEM"/>
							<xsl:variable name="errorid" select="substring(ID,2,string-length(ID)-2)"/>
							<xsl:if test="contains(TYPE,'EXPECTED-EFFECT') and string-length(TYPE) &lt; string-length('EXPECTED-EFFECT') + 2">
                                                                <script>numresults+=2</script>
								
								<tr valign="top">
									<td align="right">								
										<span class="sublabel"> Checking expected effects</span>
									</td>
									<td>
										<font color="red">
											<xsl:if test="SUCCESS = 'NIL' and LEVEL='ERROR'">
										       <xsl:call-template name="showdetails" >
											      <xsl:with-param name="list" select="CONSTRAINT/EXPECTED-EFFECT" />
												<xsl:with-param name="color" select="'red'"/>
											</xsl:call-template>
											-> The <xsl:value-of select="count(CONSTRAINT/EXPECTED-EFFECT)"/> expected effect(s) failed
											</xsl:if>
										</font>
										<font color="brown">
											<xsl:if test="SUCCESS = 'NIL' and LEVEL='WARNING'">
										       <xsl:call-template name="showdetails" >
											      <xsl:with-param name="list" select="CONSTRAINT/EXPECTED-EFFECT" />
												<xsl:with-param name="color" select="'brown'"/>
											</xsl:call-template>
											-> The <xsl:value-of select="count(CONSTRAINT/EXPECTED-EFFECT)"/> expected effect(s) failed
											</xsl:if>
										</font>
										<font color="black">
											<xsl:if test="SUCCESS = 'T'">
										       <xsl:call-template name="showdetails" >
											      <xsl:with-param name="list" select="CONSTRAINT/EXPECTED-EFFECT" />
											</xsl:call-template>
											-> The <xsl:value-of select="count(CONSTRAINT/EXPECTED-EFFECT)"/> expected effect(s) succeeded

											</xsl:if>
										</font>

										<br/><br/>
										<xsl:call-template name="userinput">
											<xsl:with-param name="errorid" select="ID"/>
										</xsl:call-template>
									</td>
								</tr>
								<tr><td colspan="2">
								<hr/>
								</td></tr>
							</xsl:if>
						</xsl:if>
						<xsl:if test="contains(TYPE,'UNNECESSARY-LINK') and string-length(TYPE) &lt; string-length('UNNECESSARY-LINK') + 2">
                                                        <script>numresults+=2</script>
							<xsl:variable name="errorid" select="substring(ID,2,string-length(ID)-2)"/>
							<tr valign="top">
								<td align="right">
									<span class="sublabel"> Checking specified order of steps</span>
								</td>
								<td>
									<xsl:if test="SUCCESS = 'NIL'">
									<font color="brown">
										<br/> 
                                                                 <b><font color="black"> Note: </font></b> These requirements seemed to be unnecessary given the definitions currently I have about those steps: 										
									</font>	
									</xsl:if>

									<font color="black">
									       <xsl:call-template name="showdetails" >
										      <xsl:with-param name="list" select="SOURCE/UNNECESSARY-LINK" />
										</xsl:call-template>
									</font>
									<xsl:call-template name="userinput">
										<xsl:with-param name="errorid" select="ID"/>
									</xsl:call-template>
								</td>
							</tr>
							<tr><td colspan="2">
							<hr/>
							</td></tr>

						</xsl:if>

						<xsl:if test="contains(TYPE,'MISSING-FIRST-SUBEVENT') and string-length(TYPE) &lt; string-length('MISSING-FIRST-SUBEVENT') + 2">
                                                        <script>numresults+=2</script>
							<xsl:variable name="errorid" select="substring(ID,2,string-length(ID)-2)"/>
							<tr valign="top">
								<td align="right">
									<span class="sublabel"> Checking first event</span>
								</td>
								<td>
									<xsl:if test="SUCCESS = 'NIL'">
									<xsl:if test="contains(LEVEL,'WARNING')">
									<font color="brown">
										<br/> 
                                                                 <b><font color="black"> Note: </font></b> These requirements seemed to be unnecessary given the definitions currently I have about those steps: 										
									</font>
									</xsl:if>	
									<xsl:if test="contains(LEVEL,'ERROR')">
									<font color="red">
										<br/> 
                                                                 <b><font color="black"> Note: </font></b> I don't know which one of these is the first subevent										
									</font>
									</xsl:if>	

									</xsl:if>

									<font color="black">
									       <xsl:call-template name="showdetails" >
										      <xsl:with-param name="list" select="SOURCE/LIST-ITEM" />
										</xsl:call-template>
									</font>
									<xsl:call-template name="userinput">
										<xsl:with-param name="errorid" select="ID"/>
									</xsl:call-template>
								</td>
							</tr>
							<tr><td colspan="2">
							<hr/>
							</td></tr>

						</xsl:if>
						<xsl:if test="contains(TYPE,'NOT-PARALLEL') and string-length(TYPE) &lt; string-length('NOT-PARALLEL') + 2">
                                                        <script>numresults+=2</script>
							<xsl:variable name="errorid" select="substring(ID,2,string-length(ID)-2)"/>
							<tr valign="top">
								<td align="right">
									<span class="sublabel"> Checking ordering between parallel events</span>
								</td>
								<td>
									<xsl:if test="SUCCESS = 'NIL'">
									<font color="red">
										<br/> 
                                                                 <b><font color="black"> Error: </font></b> These events should have been parallel because they are  both the first sub-events but there is an ordering contraint between them:						
									</font>
									</xsl:if>

									<font color="black">
									       <xsl:call-template name="showdetails" >
										      <xsl:with-param name="list" select="SOURCE/LIST-ITEM" />
											<xsl:with-param name="color" select="'red'"/>
										</xsl:call-template>
									</font>
									<xsl:call-template name="userinput">
										<xsl:with-param name="errorid" select="ID"/>
									</xsl:call-template>
								</td>
							</tr>
							<tr><td colspan="2">
							<hr/>
							</td></tr>

						</xsl:if>

						<xsl:if test="contains(TYPE,'MISSING-LINK')">
                                                        <script>numresults+=2</script>
							<xsl:variable name="errorid" select="substring(ID,2,string-length(ID)-2)"/>
							<tr valign="top">
								<td align="right">
									<span class="sublabel"> Checking subevents</span>
								</td>
								<td>
									<xsl:if test="SUCCESS = 'NIL'">
									<font color="brown">
										<br/> 
                                                            <b><font color="black"> Note: </font></b> 
										
											These events were not reached due to missing links:
									</font>	
									</xsl:if>

									<font color="black">
									       <xsl:call-template name="showdetails" >
										      <xsl:with-param name="list" select="CONSTRAINT/EVENT" />
										</xsl:call-template>
									</font>
									<xsl:call-template name="userinput">
										<xsl:with-param name="errorid" select="ID"/>
									</xsl:call-template>
								</td>
							</tr>
							<tr><td colspan="2">
							<hr/>
							</td></tr>

						</xsl:if>

						<xsl:if test="contains(TYPE,'MISSING-SUBEVENT') and string-length(TYPE) &lt; string-length('MISSING-SUBEVENT') + 2">
                                                        <script>numresults+=2</script>
							<xsl:variable name="errorid" select="substring(ID,2,string-length(ID)-2)"/>
							<tr valign="top">
								<td align="right">
									<span class="sublabel"> Checking missing subevent link </span>
								</td>
								<td>
									<xsl:if test="SUCCESS = 'NIL'">
									<font color="red">
										<br/> 
                                                                 <b><font color="black"> Error: </font></b> These events are the first subevents of <xsl:value-of select="//request/parameters/parameter/value[../name='class']"/> but not its subevent:						
									</font>
									</xsl:if>

									<font color="red">
									       <xsl:call-template name="showdetails" >
										      <xsl:with-param name="list" select="SOURCE/LIST-ITEM[2]" />
											<xsl:with-param name="color" select="'red'"/>
										</xsl:call-template>
									</font>
									<xsl:call-template name="userinput">
										<xsl:with-param name="errorid" select="ID"/>
									</xsl:call-template>
								</td>
							</tr>
							<tr><td colspan="2">
							<hr/>
							</td></tr>

						</xsl:if>

						<xsl:if test="contains(TYPE,'UNREACHED-EVENTS') and contains(SOURCE,'MISSING-ORDERING-CONSTRAINT')">
                                                        <script>numresults+=2</script>
							<xsl:variable name="errorid" select="substring(ID,2,string-length(ID)-2)"/>
							<tr valign="top">
								<td align="right">
									<span class="sublabel"> Checking ordering constraint</span>
								</td>
								<td>
									<xsl:if test="SUCCESS = 'NIL'">
									<font color="brown">
										<br/> 
                                                            <b><font color="black"> Note: </font></b> 
										
											These events were not reached due to missing ordering constraints:
									</font>	
									</xsl:if>

									<font color="black">
									       <xsl:call-template name="showdetails" >
										      <xsl:with-param name="list" select="CONSTRAINT/EVENT" />
										</xsl:call-template>
									</font>
									<xsl:call-template name="userinput">
										<xsl:with-param name="errorid" select="ID"/>
									</xsl:call-template>
								</td>
							</tr>
							<tr><td colspan="2">
							<hr/>
							</td></tr>

						</xsl:if>


					</xsl:for-each>
		</xsl:if>
	</xsl:template>

<!-- displays other results like loops, unreached events, causal links etc -->
	<xsl:template name="printotherresults">
		<xsl:param name="step"/>
		<xsl:if test='not($step="")'>
			<span class="label"> Other results from the analysis: </span>
			
				<ul>
					<xsl:for-each select="//KANAL-OUTPUT/ERROR | //KANAL-OUTPUT/INFO">
						<xsl:if test="SOURCE/class/@ref=$step">
							<xsl:variable name="tr" select="CONSTRAINT/ADD-ITEM"/>
							<xsl:variable name="errorid" select="substring(ID,2,string-length(ID)-2)"/>
							<xsl:if test="contains(TYPE,'CAUSAL-LINKS') and string-length(TYPE) &lt; string-length('CAUSAL-LINKS') + 2">
								
									<li>
										<font color="black">
											Causal relationship between the steps:
											<ul>
											<xsl:for-each select="CONTENT/LINK">
												<li> 
											      	<xsl:apply-templates select="EVENT[1]/individual" mode="make-link"/>
													step enabled 
											      	<xsl:apply-templates select="EVENT[2]/individual" mode="make-link"/>
													because after
											      	<xsl:apply-templates select="EVENT[1]/individual" mode="make-link"/>
													-
												      <xsl:call-template name="showdetails" >
													      <xsl:with-param name="list" select="CONDITIONS/LIST-ITEM" />
													</xsl:call-template>
												</li>
											</xsl:for-each>
											</ul>
											<xsl:call-template name="userinput">
												<xsl:with-param name="errorid" select="ID"/>
											</xsl:call-template>

										</font>
										<br/><br/><br/>																	</li>
								
								
							</xsl:if>
							<xsl:if test="contains(TYPE,'LOOP') and string-length(TYPE) &lt; string-length('LOOP') + 2">
								
									<li>
										<font color="black">
											<xsl:choose>
												<xsl:when test="SUCCESS='T'">
													No iteration of steps (e.g. A before B before C before A) were found for <xsl:value-of select="$step"/> <br/>
												</xsl:when> 
												<xsl:otherwise>
												Loops where found for <xsl:value-of select="$step"/> <br/><br/>
												<font color="black">
												       <xsl:call-template name="showdetails" >
													      <xsl:with-param name="list" select="CONSTRAINT/LOOP/LIST-ITEM" />
													</xsl:call-template>
												</font>

												</xsl:otherwise>
											</xsl:choose>
											<xsl:call-template name="userinput">
												<xsl:with-param name="errorid" select="ID"/>
											</xsl:call-template>

										</font>																	</li>
								
								
							</xsl:if>
							<xsl:if test="contains(TYPE,'MAX-LOOPS') and string-length(TYPE) &lt; string-length('MAX-LOOPS') + 2">
								
									<li>
										<font color="black">
											<xsl:choose>
												<xsl:when test="SUCCESS='T'">
													Iteration of steps (e.g. A before B before C before A) found for <xsl:value-of select="$step"/> executed for finite number of times<br/>
												</xsl:when> 
												<xsl:otherwise>
												Loops found for <xsl:value-of select="$step"/> crossed the maximum loops limit<br/><br/>
												<font color="black">
												       <xsl:call-template name="showdetails" >
													      <xsl:with-param name="list" select="CONSTRAINT/LOOP/LIST-ITEM" />
													</xsl:call-template>
												</font>

												</xsl:otherwise>
											</xsl:choose>
											<xsl:call-template name="userinput">
												<xsl:with-param name="errorid" select="ID"/>
											</xsl:call-template>

										</font>																	</li>
								
								
							</xsl:if>
							<xsl:if test="contains(TYPE,'TEMPORAL-LOOP') and string-length(TYPE) &lt; string-length('TEMPORAL-LOOP') + 2">
								
									<li>
										<font color="black">
											<xsl:choose>
												<xsl:when test="SUCCESS='T'">
													No temporal loops were found for <xsl:value-of select="$step"/> <br/>
												</xsl:when> 
												<xsl:otherwise>
												Temporal loops where found for <xsl:value-of select="$step"/> <br/><br/>
												<font color="black">
												       <xsl:call-template name="showdetails" >
													      <xsl:with-param name="list" select="CONSTRAINT/LOOP/LIST-ITEM" />
													</xsl:call-template>
												</font>

												</xsl:otherwise>
											</xsl:choose>
											<xsl:call-template name="userinput">
												<xsl:with-param name="errorid" select="ID"/>
											</xsl:call-template>

										</font>																	</li>
								
								
							</xsl:if>
						</xsl:if>
						<xsl:if test="contains(TYPE,'UNREACHED-EVENTS') and not(contains(SOURCE,'MISSING-ORDERING-CONSTRAINT'))">
							<xsl:variable name="errorid" select="substring(ID,2,string-length(ID)-2)"/>
								<li>
									<xsl:if test="SUCCESS = 'NIL'">
									<font color="black">
                                                            <b> Note: </b> 
										<xsl:choose>
											<xsl:when test="contains(SOURCE,'NO-SIMULATION-PATH-EXIST')">

												These events were not reached because the simulation failed
											</xsl:when>
											<xsl:when test="contains(SOURCE,'FAILED-CONDITION')">

												These events were not reached due to the condition failure of  
											       <xsl:apply-templates select="SOURCE/individual" mode="make-link"/>

											</xsl:when>

										</xsl:choose>
									</font>	
									</xsl:if>

									<font color="black">
									       <xsl:call-template name="showdetails" >
										      <xsl:with-param name="list" select="CONSTRAINT/EVENT" />
										</xsl:call-template>
									</font>
									<xsl:call-template name="userinput">
										<xsl:with-param name="errorid" select="ID"/>
									</xsl:call-template>
								</li>
						</xsl:if>

					</xsl:for-each>
				</ul>
			
		</xsl:if>
	</xsl:template>



        <!-- this rule is matched when apply-templates from kanal-internal is called  with response tag -->
	<xsl:template match="KANAL-OUTPUT">

                <!-- defines javascript functions and displays the process name being tested -->
		<xsl:call-template name="header">
			<xsl:with-param name="class" select="//request/parameters/parameter/value[../name = 'class']"/>
		</xsl:call-template>

			<!-- failed precondition -->
			<xsl:variable name="fc" select="ERROR[TYPE='PRECONDITION' and SUCCESS='NIL']/SOURCE/individual/@ref"/>
			
			<!-- define variables -->
			<xsl:variable name="max-units" select="count(INFO[TYPE='EVENT-INFO-BEFORE-EXECUTION']/CONTENT/INFO-ITEM[NAME='agent' or NAME='object']/DETAIL/LIST-ITEM/LIST-ITEM)"/>
			<xsl:variable name="no-of-steps" select="count(INFO[TYPE='SIMULATED-PATHS']/CONTENT/PATH/LIST-ITEM/LIST-ITEM)"/>
			<script>
				var current_step = 1;  //zeroth index is reserved for initial values
				var total_no_of_steps = <xsl:value-of select="$no-of-steps"/>+1;
				var unit_names = new Array(<xsl:value-of select="$max-units"/>);
				var unit_refs = new Array(<xsl:value-of select="$max-units"/>);
				var event_unit = new Array();
				var simulated_steps = new Array();

				//below two array sizes should be max number of properties
				var unit_property_names = new Array(<xsl:value-of select="$max-units"/>); 
				var unit_properties = new Array(<xsl:value-of select="$max-units"/>);

				var no_of_units = 0;
				var no_of_properties = 0;

				var tempi=0,tempj=0,tempk=0;
				var addone = 0;
				<xsl:if test="$fc">
					addone=1;
					total_no_of_steps++;
				</xsl:if>

				for(tempi=0; tempi &lt; <xsl:value-of select="$max-units"/>; tempi++) {
					unit_properties[tempi] = new Array(<xsl:value-of select="$max-units"/>)
				}

				for(tempi=0; tempi &lt; <xsl:value-of select="$max-units"/>; tempi++) {
					for(tempj=0; tempj &lt; <xsl:value-of select="$max-units"/>; tempj++) {
						unit_properties[tempi][tempj] = new Array(total_no_of_steps)
					}
				}

				for(tempk=0; tempk &lt; <xsl:value-of select="$max-units"/>; tempk++) {
					for(tempi=0; tempi &lt; <xsl:value-of select="$max-units"/>; tempi++) {
						for(tempj=0; tempj &lt; total_no_of_steps; tempj++) {
							unit_properties[tempk][tempi][tempj] = ""
						}
					}
				}
				var stcount = 1;
			</script>

			<xsl:for-each select="INFO[TYPE='SIMULATED-PATHS']/CONTENT/PATH/LIST-ITEM/LIST-ITEM/individual/@ref">
				<xsl:variable name="step" select="."/>
				<script type="text/javascript">
					var rcount<xsl:value-of select="translate($step,'-','_')"/> = 3; // for step info before execution and step: and special case
					var is_subevent<xsl:value-of select="translate($step,'-','_')"/> = <xsl:value-of select="count(//INFO[TYPE='SUBEVENTS']/CONTENT/LIST-ITEM/SUBEVENTS/SUBEVENT[individual/@ref=$step])"/>;
					var errorinstep<xsl:value-of select="translate($step,'-','_')"/> = 0;
					var errorinsubstep<xsl:value-of select="translate($step,'-','_')"/> = 0;
					var warninginstep<xsl:value-of select="translate($step,'-','_')"/> = 0;
					var warninginsubstep<xsl:value-of select="translate($step,'-','_')"/> = 0;
					simulated_steps[stcount]='<xsl:value-of select="$step"/>';
					stcount++;
				</script>
			</xsl:for-each>
			<xsl:if test="$fc">
				<script type="text/javascript">
                                        // xxxxxxxxxxxxxx changed stuff here xxxxxxxxxx 
					var rcount<xsl:value-of select="translate($fc,'-','_')"/> = 3; // for step info before execution and step: and special case
					var errorinstep<xsl:value-of select="translate($fc,'-','_')"/> = 0;
					var errorinsubstep<xsl:value-of select="translate($fc,'-','_')"/> = 0;
					var warninginstep<xsl:value-of select="translate($fc,'-','_')"/> = 0;
					var warninginsubstep<xsl:value-of select="translate($fc,'-','_')"/> = 0;
				</script>				
			</xsl:if>

			<!-- set the values for above variables -->
			<script>
                                var maxst = stcount-1;
                                var minst = 1;
			<xsl:for-each select="ERROR[SOURCE/individual/@ref = ../INFO[TYPE='SIMULATED-PATHS']/CONTENT/PATH/LIST-ITEM/LIST-ITEM/individual/@ref]">
				<xsl:variable name="step" select="SOURCE/individual/@ref"/>
				<xsl:if test="not(SOURCE='FAILED-CONDITION')">
					rcount<xsl:value-of select="translate($step,'-','_')"/>++;
				</xsl:if>

				<xsl:if test="SUCCESS='NIL'">
					<xsl:if test="LEVEL='WARNING'">
						
						warninginstep<xsl:value-of select="translate($step,'-','_')"/>++;
						<xsl:if test="//INFO[TYPE='SUBEVENTS']/CONTENT/LIST-ITEM/SUBEVENTS/SUBEVENT/individual/@ref=$step">
							
							warninginsubstep<xsl:value-of select="translate(//INFO[TYPE='SUBEVENTS']/CONTENT/LIST-ITEM[SUBEVENTS/SUBEVENT/individual/@ref=$step]/EVENT/individual/@ref,'-','_')"/>++;
						</xsl:if>
					</xsl:if>
					<xsl:if test="LEVEL='ERROR'">
						
						errorinstep<xsl:value-of select="translate($step,'-','_')"/>++;
						<xsl:if test="//INFO[TYPE='SUBEVENTS']/CONTENT/LIST-ITEM/SUBEVENTS/SUBEVENT/individual/@ref=$step">
							
							errorinsubstep<xsl:value-of select="translate(//INFO[TYPE='SUBEVENTS']/CONTENT/LIST-ITEM[SUBEVENTS/SUBEVENT/individual/@ref=$step]/EVENT/individual/@ref,'-','_')"/>++;
						</xsl:if>
					</xsl:if>
				</xsl:if>
			</xsl:for-each>
			<xsl:if test="$fc">
				<xsl:variable name="step" select="$fc"/>
				rcount<xsl:value-of select="translate($step,'-','_')"/>++;
				<xsl:if test="$fc/../../../SUCCESS='NIL'">					
					<xsl:if test="$fc/../../../LEVEL='ERROR'">				
						errorinstep<xsl:value-of select="translate($step,'-','_')"/>++;
						<xsl:if test="//INFO[TYPE='SUBEVENTS']/CONTENT/LIST-ITEM/SUBEVENTS/SUBEVENT/individual/@ref=$step">	
							errorinsubstep<xsl:value-of select="translate(//INFO[TYPE='SUBEVENTS']/CONTENT/LIST-ITEM[SUBEVENTS/SUBEVENT/individual/@ref=$step]/EVENT/individual/@ref,'-','_')"/>++;
						</xsl:if>
					</xsl:if>
				</xsl:if>
			</xsl:if>

			</script>


                        <table width="100%">
                        <tr><td align="left">
			  <input type="button" ID='show All Data' class="darkbluebutton" value="Show All Checks"  onclick="javascript:showAllData(this);"/>
                          <xsl:if test="not($static = 'true')">
			  <!--&#160;<input type="button" class="darkbluebutton" value="Re-Test"  onclick="javascript:document.location.reload();"/>-->
                          &#160;<input type="button" class="darkbluebutton" value="Go Back"  onclick="javascript:goBack();"/>
                          </xsl:if>
                        </td>
                        <td align="right">
			  <input type="button" class="darkbluebutton" ID="prevstep" value="&lt;&lt; Prev "  onclick="showStep('previous');"/>&#160;
			  <input type="button" class="darkbluebutton" value="First Step"  onclick="showStep('first');"/>&#160;
			  <input type="button" class="darkbluebutton" ID="nextstep" value=" Next &gt;&gt;"  onclick="showStep('next');"/>
                        </td>
                        </tr>
                        </table>

                        <p/>

			<!-- this is the main outermost table -->
			<table width="100%" id="outertable" border="0" cellpadding="5" cellspacing="0">

			<tr>
			<td valign="top" style="background-color:#336699">
			    <table>
				<tr>
					<td valign="top">
					<img style="cursor:pointer" onClick="javascript:toggleDisplayOfTabs(this);javascript:toggleDetailCorrespondingToTab(this,'outertable',0,0,1);">
                                          <xsl:if test="$static = 'true'">
				             <xsl:attribute name="src"><xsl:value-of select="$static_server"/>/images/kanal/checked.gif</xsl:attribute>
                                          </xsl:if>
                                          <xsl:if test="not($static = 'true')">
				             <xsl:attribute name="src">/images/kanal/checked.gif</xsl:attribute>
                                          </xsl:if>
					  <xsl:attribute name="ID">tab Summary of analysis</xsl:attribute></img>
					</td>
					
					<td>
                                          <xsl:attribute name="onclick">
                                              javascript:toggleDisplayOfTabs(document.getElementById('tab Summary of analysis'));
                                              javascript:toggleDetailCorrespondingToTab(document.getElementById('tab Summary of analysis'),'outertable',0,0,1);
                                          </xsl:attribute>
					  <xsl:attribute name="ID">texttab Summary of analysis</xsl:attribute>
					  <xsl:attribute name="class">highlargebluelink</xsl:attribute>					
					  <xsl:text> </xsl:text>
					  Summary of analysis
					</td>
				</tr>
				<tr></tr>
			    </table>
			</td>

			<td style="background-color:#e4f0fa">
			<!-- alternative paths list -->

			<xsl:if test="INFO/CONTENT/PATH/LIST-ITEM/LIST-ITEM">
				<div style="">
					<b>Summary of analysis</b>
					<ul>
						<font color="red">
						<xsl:if test="ERROR[SUCCESS='NIL' and LEVEL='ERROR']/SOURCE[individual/@ref=../../INFO/CONTENT/PATH/LIST-ITEM/LIST-ITEM/individual/@ref] or $fc">
							<li>
								Problems were found in the following steps:
								<ul>
								<xsl:for-each select="INFO[TYPE='SIMULATED-PATHS']/CONTENT/PATH/LIST-ITEM/LIST-ITEM">
									<xsl:variable name="stepname" select="./individual/@ref"/>
									<xsl:if test="//ERROR[SUCCESS='NIL' and LEVEL='ERROR']/SOURCE[individual/@ref=$stepname]">
										<li>
				                                                       <a class="smallbluelink">
                                                                                         <xsl:attribute name="onclick">
                                                                                              javascript:toggleStepForTab('<xsl:value-of select="$stepname"/>');
                                                                                         </xsl:attribute>
											 <xsl:apply-templates select="$stepname/.." mode="get-english"/>	
				                                                       </a>
										</li>
									</xsl:if>
								</xsl:for-each>
								<xsl:if test="$fc">
									<li>
				                                                       <a class="smallbluelink">
                                                                                         <xsl:attribute name="onclick">
                                                                                              javascript:toggleStepForTab('<xsl:value-of select="$fc"/>');
                                                                                         </xsl:attribute>
											 <xsl:apply-templates select="$fc/.." mode="get-english"/>	
				                                                       </a>
									</li>
								</xsl:if>
								</ul>
							</li>					
						</xsl:if>
						</font>
						<br/>
						<font color="brown">
						<xsl:if test="ERROR[SUCCESS='NIL' and LEVEL='WARNING']/SOURCE[individual/@ref=../../INFO/CONTENT/PATH/LIST-ITEM/LIST-ITEM/individual/@ref]">
							<li>
								Warnings were found in the following steps:
								<ul>
								<xsl:for-each select="INFO[TYPE='SIMULATED-PATHS']/CONTENT/PATH/LIST-ITEM/LIST-ITEM">
									<xsl:variable name="stepname" select="./individual/@ref"/>
									<xsl:if test="//ERROR[SUCCESS='NIL' and LEVEL='WARNING']/SOURCE[individual/@ref=$stepname]">
										<li>
				                                                       <a class="smallbluelink">
                                                                                         <xsl:attribute name="onclick">
                                                                                              javascript:toggleStepForTab('<xsl:value-of select="$stepname"/>');
                                                                                         </xsl:attribute>
											 <xsl:apply-templates select="$stepname/.." mode="get-english"/>	
				                                                       </a>
										</li>
									</xsl:if>
								</xsl:for-each>
								<xsl:if test="$fc">
									<xsl:if test="//ERROR[SUCCESS='NIL' and LEVEL='WARNING']/SOURCE[individual/@ref=$fc]">
										<li>
				                                                       <a class="smallbluelink">
                                                                                         <xsl:attribute name="onclick">
                                                                                              javascript:toggleStepForTab('<xsl:value-of select="$fc"/>');
                                                                                         </xsl:attribute>
											 <xsl:apply-templates select="$fc/.." mode="get-english"/>	
				                                                       </a>
										</li>
									</xsl:if>
								</xsl:if>
								</ul>
							</li>					
						</xsl:if>
						</font>
					</ul>
				</div>
			</xsl:if>

			<xsl:if test="not(INFO/CONTENT/PATH/LIST-ITEM/LIST-ITEM)">
				<div style="">
					No simulation path exists.
				</div>
			</xsl:if>

			</td>
			</tr>

			<tr>
			   <td style="background-color:#336699">
				<hr/>
			   </td>
			   <td style="background-color:#e4f0fa">
				<hr/>
			   </td>
			</tr>

			<tr>
			<td valign="top" style="background-color:#336699;width:150">
			<table>
				<tr>
					<td colspan="2">
						<span class="largebluelink">PATH SIMULATED</span>
						<br/><br/>
					</td>
				</tr>

				<xsl:for-each select="INFO/CONTENT/PATH/LIST-ITEM/LIST-ITEM">
					<xsl:call-template name="displaytab">
						<xsl:with-param name="step" select="./individual/@ref"/>
						<xsl:with-param name="innerloop" select="0"/>
					</xsl:call-template>
				</xsl:for-each>				
				<xsl:if test="$fc">
					<xsl:call-template name="displaytab">					
						<xsl:with-param name="step" select="$fc"/>
						<xsl:with-param name="innerloop" select="0"/>
					</xsl:call-template>				
				</xsl:if>
			</table>

			<hr/>
			<table>
				<tr>
					<td>
					<img style="cursor:pointer" onClick="javascript:toggleDisplayOfTabs(this);javascript:toggleDetailCorrespondingToTab(this,'kanalresults',resultendrow-1-numresults,resultendrow-2,0);">
                                          <xsl:if test="$static = 'true'">
				             <xsl:attribute name="src"><xsl:value-of select="$static_server"/>/images/kanal/checked.gif</xsl:attribute>
                                          </xsl:if>
                                          <xsl:if test="not($static = 'true')">
				             <xsl:attribute name="src">/images/kanal/checked.gif</xsl:attribute>
                                          </xsl:if>
					  <xsl:attribute name="ID">tab Results</xsl:attribute></img>
					</td>

					<xsl:element name="td">
                                          <xsl:attribute name="onclick">
                                              javascript:toggleDisplayOfTabs(document.getElementById('tab Results'));
                                              javascript:toggleDetailCorrespondingToTab(document.getElementById('tab Results'),'kanalresults',resultendrow-1-numresults,resultendrow-2,0);
                                          </xsl:attribute>
					  <xsl:attribute name="ID">texttab Results</xsl:attribute>
					  <xsl:attribute name="class">highlargebluelink</xsl:attribute>					
					  <xsl:text> </xsl:text>
					  Results
					</xsl:element>
					<!--<xsl:element name="td">

					<xsl:attribute name="style">white-space:nowrap</xsl:attribute>
					<xsl:attribute name="class">highlargebluelink</xsl:attribute>					
					<xsl:text> </xsl:text>
					Results
					</xsl:element>-->
				</tr>
				<tr></tr>

				<tr>
					<td>
					<img style="cursor:pointer" onClick="javascript:toggleDisplayOfTabs(this);javascript:toggleDetailCorrespondingToTab(this,'kanalresults',resultendrow-1,resultendrow,0);">
                                          <xsl:if test="$static = 'true'">
				             <xsl:attribute name="src"><xsl:value-of select="$static_server"/>/images/kanal/checked.gif</xsl:attribute>
                                          </xsl:if>
                                          <xsl:if test="not($static = 'true')">
				             <xsl:attribute name="src">/images/kanal/checked.gif</xsl:attribute>
                                          </xsl:if>
					  <xsl:attribute name="ID">tab Other Results</xsl:attribute></img>
					</td>

					<xsl:element name="td">
                                          <xsl:attribute name="onclick">
                                              javascript:toggleDisplayOfTabs(document.getElementById('tab Other Results'));
                                              javascript:toggleDetailCorrespondingToTab(document.getElementById('tab Other Results'),'kanalresults',resultendrow-1,resultendrow,0);
                                          </xsl:attribute>
					  <xsl:attribute name="ID">texttab Other Results</xsl:attribute>
					  <xsl:attribute name="class">highlargebluelink</xsl:attribute>					
					  <xsl:text> </xsl:text>
					  Other Results
					</xsl:element>
					<!--<xsl:element name="td">

					<xsl:attribute name="style">white-space:nowrap</xsl:attribute>
					<xsl:attribute name="class">highlargebluelink</xsl:attribute>					
					<xsl:text> </xsl:text>
					Other Results
					</xsl:element>-->
				</tr>					
				<tr></tr>
			</table>	
			</td>
			
			<td valign="top" style="background-color:#e4f0fa">

			<!-- table for displaying all the details of simulation results -->

			<table id="kanalresults" border="0" cellpadding="0" cellspacing="0">

			<tr style=""><td style="background-color:#e4f0fa" colspan="2">
				Please select the steps to see their details
			</td></tr>

			<xsl:for-each select="INFO/CONTENT/PATH/LIST-ITEM/LIST-ITEM">
				<xsl:call-template name="printstep">					
					<xsl:with-param name="step" select="./individual/@ref"/>
					<xsl:with-param name="innerloop" select="0"/>
				</xsl:call-template>
				<script>
					current_step++;
				</script>
			</xsl:for-each>

			<xsl:if test="$fc">
				<xsl:call-template name="printstep">					
					<xsl:with-param name="step" select="$fc"/>
					<xsl:with-param name="innerloop" select="0"/>
				</xsl:call-template>				
			</xsl:if>
			<tr><td colspan="2">
			<hr/>
			</td></tr>

			<!-- List info about the overall process -->
                        <script>
                           var numresults = 0;
                        </script>

			<xsl:call-template name="printresult">
				<xsl:with-param name="step" select="//request/parameters/parameter/value[../name = 'class']"/>
			</xsl:call-template>

			<tr>
			<td colspan="2">
			<xsl:call-template name="printotherresults">
				<xsl:with-param name="step" select="//request/parameters/parameter/value[../name = 'class']"/>
			</xsl:call-template>
			</td>
			</tr>
			</table>
			<!--end of details table-->

			</td>
			</tr>

			<!--Displaying time varying properties-->
			<tr>
				<td valign="top" width="150" style="background-color:#336699;width:150">
					<table>
						<tr><td colspan="2"><hr/></td></tr>
						<tr>
							<td valign="top">
								
								<img style="cursor:pointer" onClick="javascript:toggleDisplayOfTabs(this);javascript:toggleDetailCorrespondingToTab(this,'outertable',3,3,1);">
                                                                 <xsl:if test="$static = 'true'">
				                                    <xsl:attribute name="src"><xsl:value-of select="$static_server"/>/images/kanal/unchecked.gif</xsl:attribute>
                                                                 </xsl:if>
                                                                 <xsl:if test="not($static = 'true')">
				                                    <xsl:attribute name="src">/images/kanal/unchecked.gif</xsl:attribute>
                                                                 </xsl:if>
					                         <xsl:attribute name="ID">tab Time Varying Properties</xsl:attribute></img>
							</td>

					                <xsl:element name="td">
                                                          <xsl:attribute name="onclick">
                                                              javascript:toggleDisplayOfTabs(document.getElementById('tab Time Varying Properties'));
                                                              javascript:toggleDetailCorrespondingToTab(document.getElementById('tab Time Varying Properties'),'outertable',3,3,1);
                                                          </xsl:attribute>
					                  <xsl:attribute name="ID">texttab Time Varying Properties</xsl:attribute>
					                  <xsl:attribute name="class">largebluelink</xsl:attribute>					
					                  <xsl:text> </xsl:text>
					                  Time Varying Properties
					                </xsl:element>
					
							<!--<xsl:element name="td">
								<xsl:attribute name="class">largebluelink</xsl:attribute>
											
								<xsl:text> </xsl:text>
								Time Varying Properties
							</xsl:element>-->
						</tr>
						<tr style="display:none">
						</tr>					
					</table>
				</td>
				<td style="background-color:#e4f0fa">
					<div style="display:none">
					<table>
					<tr><td colspan="2"><hr/></td></tr>
					<tr>
					<td>
			                   <xsl:attribute name="ID">moreStuff</xsl:attribute>
					</td>


					<script type="text/javascript">
						var cur_property=0;
						var morestr = "";
						
						for(cur_property=0; cur_property &lt; no_of_properties; cur_property++) {
							morestr += '&lt;p class="label">&lt;b>' + unit_property_names[cur_property] + '&lt;/b>&lt;/p>';
							morestr += '&lt;table border="1" cellpadding="3" cellspacing="0" style="background-color:#deeef9">';
							morestr += '&lt;tr>';
							morestr += '	&lt;td class="sublabelwhite" style="background-color:#5588bb">Unit Names&lt;/td>';
							morestr += '	&lt;td class="sublabelwhite" style="background-color:#5588bb">Initial Values&lt;/td>';
							morestr += '	<xsl:for-each select="//INFO/CONTENT/PATH/LIST-ITEM/LIST-ITEM">';
							morestr += '		&lt;td class="sublabelwhite" style="background-color:#5588bb">';
							morestr += '			<xsl:apply-templates select="./individual" mode="get-english"/>';
							morestr += '		&lt;/td>';
							morestr += '	</xsl:for-each>';
							morestr += '	<xsl:if test="$fc">';
							morestr += '		&lt;td class="sublabelwhite" style="background-color:#5588bb">';
							morestr += '			<xsl:apply-templates select="$fc/.." mode="get-english"/>';
							morestr += '		&lt;/td>';
							morestr += '	</xsl:if>';
							morestr += '&lt;/tr>';
												
							for(tempi=0; tempi &lt; no_of_units; tempi++) {
								var areallnull=1;
								var oldval=0;
								for(tempj=0; tempj &lt; total_no_of_steps ; tempj++) {
									var str1 = unit_properties[cur_property][tempi][tempj];
									if(str1.length!=0){
										areallnull=0;
										break;
									}
								}
								if(!areallnull) {
									morestr += '&lt;tr>&lt;td class="sublabelwhite" style="background-color:#5588bb">' + unit_names[tempi] + '&lt;/td>';
									for(tempj=0; tempj &lt; total_no_of_steps ; tempj++) {
										var str1 = unit_properties[cur_property][tempi][tempj];
										if(str1.length==0 || str1=='NIL') {
											str1="1";
										}
										else if(!isNaN(parseFloat(str1))) {
											str1 = Math.round(parseFloat(str1)*100)/100;
										}
										//alert(simulated_steps[tempj]);
										if(event_unit[simulated_steps[tempj]]) {
										    //alert("agents/objects for this step exist");
										    if(event_unit[simulated_steps[tempj]][unit_refs[tempi]]) {
										       morestr += '&lt;td bgcolor="white">' + str1 + '&lt;/td>';
										    } else {
										       morestr += '&lt;td>' + str1 + '&lt;/td>';
										    }
										} else {
										   morestr += '&lt;td>' + str1 + '&lt;/td>';
										}
										//oldval = str1;
									}
									morestr += '&lt;/tr>';
								}
							}
							morestr += '&lt;/table>';
						}
					    var item = document.getElementById("moreStuff");
					    item.innerHTML = morestr;
					</script>
					</tr>
					</table>
					</div>
				</td>			
			</tr>
			</table>

		<script type="text/javascript">
		      function init() {
			setResultEndRow();
                        showStep('first');
		      }

		      window.onload = init;
		</script>

		<iframe id="userfeedback" src="" style="display:none" width="100%" height="200">
			Your browser doesn't support iframes. Upgrade.
		</iframe>

	</xsl:template>

</xsl:stylesheet>
