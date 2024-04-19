<%
    NL = chr(13) & chr(10)
    Set app = CreateObject("XRenderer.Java")
    dir = Request.QueryString("dir")

    app.selectBucket "PLAY", "main"
    app.selectBucket "PLAY/TITLE", "title" 
    app.selectBucket "PLAYSUBT", "subtitle"
    app.selectBucket "SCNDESCR", "scndescr" 
    app.selectBucket "PERSONAE", "personae" 
            
    app.setItemRendition "PLAY", "", ""
    app.setItemRendition "PLAY/TITLE", "", "" 
    app.setItemRendition "TITLE", "<CENTER><H3>", "</H3></CENTER>" & NL 
    app.setItemRendition "PLAYSUBT", "", ""
    app.setItemRendition "PERSONAE", "", ""
    app.setItemRendition "PERSONAE/PERSONA", "<TABLE><TR><TD VALIGN=TOP>", "</TD></TR></TABLE>"
    app.setItemRendition "PGROUP", "", ""
    app.setGroupRendition "PGROUP/PERSONA", "<TABLE><TR><TD WIDTH=160 VALIGN=TOP>", "<BR>" & NL, "</TD><TD WIDTH=20></TD>"
    app.setGroupRendition "PGROUP/GRPDESCR", "<TD VALIGN=BOTTOM>", "<BR>" & NL, "</TD></TR></TABLE>" & NL                                         
    app.setItemRendition "SCNDESCR", "", NL
    app.setItemRendition "ACT", "", ""
    app.setItemRendition "SCTITLE", "<A HREF='scene.asp?dir=" & dir & "&play=«PLAY/NAME»&scene=«SCTITLE/SCENE»&of=«PLAY/SCENES»'>", "</A><BR>" & NL

    filename = dir & "/" & Request.QueryString("play") & "/play.xml"
    resp = app.setInputFile (filename)

    if resp<>0 then
        s = app.errorText
        response.write("<HR>Failed to parse XML input file" & filename & "<BR>" & s & "<HR>")
        response.end
    end if
%>
<HTML><HEAD><TITLE>     <% = app.readBucket("title") %>     </TITLE></HEAD>
<BODY BGCOLOR='#FFFFCC'>
<CENTER><H1>            <% = app.readBucket("title") %>     </H1>
<H3>                    <% = app.readBucket("subtitle") %>  </H3> 
<I>                     <% = app.readBucket("scndescr") %>  </I></CENTER><BR><HR>
<TABLE><TR><TD WIDTH=350 VALIGN=TOP BGCOLOR='#88FF88'>
    <% = app.readBucket("personae") %>        
</TD><TD WIDTH=30></TD><TD VALIGN=TOP>
    <% = app.readBucket("main") %>
</TD></TR></TABLE><HR>
</BODY></HTML>
