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
$PASSWORD;         # Password

@DIRNAMES;
@TITLES;


#####################################
# Initializtion Function
#####################################

sub Initialize {
    $CGI = CGI->new();
    $EMAIL = $CGI->param("email");
    $PASSWORD = $CGI->param("password");
	 print "Content-type: text/html\n\n";
}

sub printHTML {
	 @dirs = `ls $DATADIR`;
	 print<<Marker;
	 <html>
	 <head><title>Meet The Elves</title></head>
	 <script>
	  function popUp(location, xsize, ysize) {
       loc = location;
       window.open(loc);
     }
	  function goBack() {
       top.location.href="$DOCDIR/";
     }

     function getCookie(name) {
        var bikky = document.cookie;
        var index = bikky.indexOf(name + "=");
        if (index == -1) return null;
        index = bikky.indexOf("=", index) + 1;
        var endstr = bikky.indexOf(";", index);
        if (endstr == -1) endstr = bikky.length;
        return unescape(bikky.substring(index, endstr));
     }

	 </script>

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

    <form>
    <table cellpadding=5 cellspacing=0 border=1 width=100%>
      <tr><td colspan=4 bgcolor=#c0a0b8>
        <input type=button value="Exit" onclick="goBack()">
      </td></tr>
Marker

	 foreach $dir(@dirs) {
		  chop($dir);
		  push(@DIRNAMES,$dir);
		  $agentname = $dir;
		  $agentname =~ s/-/ /g;

		  $file = "$DATADIR/$dir/capabilities.xml";
		  if(-f $file) {
           my $parser = XML::DOM::Parser->new();
		     my $doc = $parser->parsefile($file);
			  $conceptname = $doc->getElementsByTagName('ConceptName')->item(0)->getFirstChild->getNodeValue;
			  $goalname = $doc->getElementsByTagName('GoalName')->item(0)->getFirstChild->getNodeValue;
			  $goalname =~ tr/A-Z/a-z/;
			  $conceptname =~ s/-/ /g;
			  $title = "Hi, I am the '$agentname' agent, and I can $goalname the $conceptname";
			  print<<Marker;
			  <tr>
			    <td><font color=green face=Arial size=-1>$title</font></td>
			    <td><input type=button value='Go' onclick="popUp('agent-req.pl?agent=$dir&email=$EMAIL')"></td>
			    <!--<td><input type=button value='Capabilities in XML' onclick="popUp('$DOCDIR/$RELDATADIR/$dir/capabilities.xml')"></td>-->
			    <td><input type=button value='Recent and Past Responses' onclick="popUp('$DOCDIR/$RELDATADIR/$dir/users/$EMAIL/log')"></td>
           </tr>
Marker
           #foreach my $concepts ($doc->getElementsByTagName('ConceptName')){
           #  print $concepts->getFirstChild->getNodeValue;
           #  print "\n";
           #}
		  } else {
			  $title = "Hi, I am the '$agentname' agent, and I CANNOT do anything right now !";
			  print<<Marker;
			  <tr>
			    <td><font color=red face=Arial size=-1>$title</font></td>
			    <td><input type=button value='Go' disabled></td>
			    <!--<td><input type=button value='Capabilities in XML' disabled></td>-->
			    <td><input type=button value='Recent and Past Responses' disabled></td>
			  </tr>
Marker
		  }
	 }
	 print "</table></form></body></html>\n";
}


#####################################
# Main
#####################################
{
	 Initialize();
	 printHTML();
}
