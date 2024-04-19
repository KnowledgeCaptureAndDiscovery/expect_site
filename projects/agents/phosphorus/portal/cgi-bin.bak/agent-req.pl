#!/local/bin/perl

use CGI;
use XML::DOM;

$DATADIR = "/nfs/web/htdocs/expect/projects/agents/phosphorus/portal/groups/elves";
$RELDATADIR = "groups/elves";
$DOCDIR = "/expect/projects/agents/phosphorus/portal";

#####################################
# Global Variables
#####################################
$CGI;              # Cgi Handle
$EMAIL;            # User ID
$AGENT;


#####################################
# Initializtion Function
#####################################

sub Initialize {
    $CGI = CGI->new();
    $EMAIL = $CGI->param("email");
    $AGENT = $CGI->param("agent");
	 print "Content-type: text/html\n\n";
}

sub printHTML {
	 @concepts=();
	 @params=();
	 @types=();
	 local(%mappings);
	 $file = "$DATADIR/$AGENT/capabilities.xml";
	 if(-f $file) {
        my $parser = XML::DOM::Parser->new();
	     my $doc = $parser->parsefile($file);
	     $conceptname = $doc->getElementsByTagName('ConceptName')->item(0)->getFirstChild->getNodeValue;
	     $goalname = $doc->getElementsByTagName('GoalName')->item(0)->getFirstChild->getNodeValue;
	     #$goalname =~ tr/A-Z/a-z/;
	     $conceptname =~ s/-/ /g;
		  $i=0;
        foreach my $conceptitems ($doc->getElementsByTagName('ConceptName')){
			  $i++;
			  $val = $conceptitems->getFirstChild->getNodeValue;
			  if($i eq 1) { next; }
           push(@concepts,$val);
			  $mappings{$val}=$i-1;
	     }
		  $i=0;
        foreach my $paramitems ($doc->getElementsByTagName('ParameterName')){
			  $i++;
			  $val = $paramitems->getFirstChild->getNodeValue;
			  if($i eq 1) { next; }
           push(@params,$val);
	     }
        # types: 0 = string, 1 = number, 2 = enumeration, followed by enum values (\01 delim), 3 = date
		  for($k=0; $k<$i; $k++) {
			  $types[$i]="-1";
		  }
		  $total = $i;
	 }
	 $file = "$DATADIR/$AGENT/constraints.xml";
	 if(-f $file) {
        my $parser = XML::DOM::Parser->new();
	     my $doc = $parser->parsefile($file);
		  $i=0;
		  $enumi=0;
		  @typectr = $doc->getElementsByTagName('type-ctr');
		  @enumctr = $doc->getElementsByTagName('ctr-enum');
        foreach my $conceptitems ($doc->getElementsByTagName('name')) {
			  $i++;
			  $conc = $conceptitems->getFirstChild->getNodeValue;
			  #print $conc,"\n";
			  $map = $mappings{$conc}-1;
			  $typeval = $typectr[$i-1]->getFirstChild->getNodeValue;
			  #print $typeval,"\n";
			  if($typeval eq "number") {
					$types[$map]="1";
					#print "types[$map]=1<br>\n";
			  } elsif($typeval eq "one-of") {
					$enumi++;
					$enumvals = $enumctr[$enumi-1]->getFirstChild->getNodeValue;
					$types[$map]="2\01$enumvals";
					#print "types[$map]=2<br>\n";
			  } elsif($typeval eq "date") {
					$types[$map]="3";
			  } elsif($typeval eq "string") {
					$types[$map]="0";
			  } else {
					#print "types[$map]=0<br>\n";
			  }
		  }
	 }
	 print<<Marker;
    <html><head>
    <title>$AGENT Agent Requestor</title>

    <script>
     var reason = '';
	  var maps = new Array();
	  var params = new Array();

     function y2k(number) { return (number < 1000) ? number + 1900 : number; }

     function isValidDate (myDate,sep) {
      if (myDate.length == 10) {
        if (myDate.substring(2,3) == sep && myDate.substring(5,6) == sep) {
            var month  = myDate.substring(0,2);
            var date = myDate.substring(3,5);
            var year  = myDate.substring(6,10);

            var test = new Date(year,month-1,date);

            if (year == y2k(test.getYear()) && (month-1 == test.getMonth()) && (date == test.getDate())) {
                reason = '';
                return true;
            }
            else {
                reason = 'valid format but an invalid date';
                return false;
            }
        }
        else {
            reason = 'invalid spearators';
            return false;
        }
      }
      else {
        reason = 'invalid length';
        return false;
      }
    }

    function checkDate(myDate) {
     //if (isValidDate(myDate,'/'))
	    return 1;    
     //else
     //   return 0;
    }


    function validate() {
      var flag = 0
Marker
      for($i=0; $i<$total; $i++) {
			 $conc = $concepts[$i];
			 if($types[$i] eq "0") {
				  print<<Temp;
      if(document.AgentForm.arg$i.value == "") { 
    	  alert("$conc must be a string");
	     flag = 1
      }
Temp
          } elsif($types[$i] eq "1") {
				  print<<Temp;
      if(isNaN(document.AgentForm.arg$i.value)) { 
	     alert("$conc must be a number");
    	  flag = 1
      }
Temp
		    } elsif($types[$i] eq "3") {
				  print<<Temp;
      if(!checkDate(document.AgentForm.arg2.value)) {
    	  alert("$conc must be a valid date mm/dd/yyyy");
	     flag = 1
      }
Temp
		    }
		}
      print<<Marker;

      if(flag == 1) {
        return false
		}
      else {
	    //alert("CHECKED");
	     return true;
      }	
   }

   function sendReq() {
	     if(validate()) {
	        var str = "<font face='Arial' size=-1><b>Your request has been sent to the agent.</b></font>";
			  //if(document.all) {
	        //   Message.innerHTML = str;
			  //} else {
			//	  var message = document.layers["Message"];
			//	  message.document.open();
			//	  message.document.write(str);
			//	  message.document.close();
			 // }
		     document.AgentForm.submit();
	     }
   }
   </script>
   </head>

	 <body bgcolor="white">
	 <table cellpadding=5 cellspacing=0 border=0 width=100%>
      <tr><td align=left><a href="http://www.isi.edu/agents-united" target="_blank">
		<img src="$DOCDIR/elves.gif" border=0></a></td>
      <td align=left><img src="$DOCDIR/meet.jpg"></td>
      <td align=right><b>User-ID:</b><br><font size=-1 face="Arial">$EMAIL</b>
      <br><br>
		 [If you have not registered yet, click <a href="http://www.isi.edu/teamcore/elves/" target="_blank">
		 here</a>]</td></tr>
    </table>
	 <hr><br>
	 <b><font face='Arial,Helvetica'>$goalname the $conceptname</font></b>
	 <font size=-1>
    <form name="AgentForm" action="http://excalibur.isi.edu:8888/cgi-bin/elves/makeAndGetResults.pl" method=post target='_blank'>
	 <table cellpadding=1 cellspacing=1 border=0>
Marker
		  $len = @params;
		  for($i=0; $i<$len; $i++) {
				$con = $concepts[$i];
				$con =~ s/-/ /g;
				$par = $params[$i];
				$par =~ tr/A-Z/a-z/;
				$par =~ s/\d//g;
				print "<tr><td><font size=-1 face='Arial,Helvetica'>$par</font></td>\n";
				print "<td><font size=-1 face='Arial,Helvetica'>$con</font></td>\n";
				if($types[$i] =~ "^2") {
					 ($junk,$val) = split(/\01/,$types[$i],2);
					 print "<td><select name=\"arg$i\">\n";
					 @vals = split(/\s*[;,]\s*/,$val);
					 foreach $val(@vals) {
						  print "<option value=\"$val\">$val</option>\n";
					 }
					 print "</select></td></tr>\n";
				} else {
				    print "<td><input type=text name=\"arg$i\" value=\"\"></td></tr>\n";
				}
		  }
	     print<<Marker;
	</table>
   <input type=hidden name=agentname value="$AGENT">
   <input type=hidden name=email value="$EMAIL">
	<br><font size=+0>
   <input type=button value="Send Request" onclick="sendReq()">&nbsp;&nbsp;
   <input type=button value="Capabilities in XML" onclick="window.open('$DOCDIR/$RELDATADIR/$AGENT/capabilities.xml')">
	</font>
Marker
   $len = @params; 
	for($i=0;$i<$len; $i++) {
		 $t = $params[$i];
		 $u = $concepts[$i];
		 print "<input type=hidden name=\"argval$i\" value=\"$t\">\n";
		 print "<input type=hidden name=\"conceptval$i\" value=\"$u\">\n";
	}
   print<<Marker;
	</form>
	<br>
   <!--<div id="Message" style="position:absolute;left:15;top:450"><font face='Arial,Helvetica'><b></b></font></div>
	-->
Marker
	 print "</body></html>\n";
}


#####################################
# Main
#####################################
{
	 Initialize();
	 printHTML();
}
