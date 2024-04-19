<%
    NL = chr(13) & chr(10)
    play = Request.QueryString("play")
    scene = Request.QueryString("scene")
    dir = Request.QueryString("dir")
    numScenes = Request.QueryString("of")
    
    Set app = CreateObject("XRenderer.Java")

    app.selectBucket "SCENE", "main"
    app.selectBucket "SCTITLE", "title"
    app.selectBucket "CONTEXT", "context"

    app.setItemRendition  "PLAY",            "<A HREF='play.asp?dir=" & dir & "&play=" & play & "'>«PLAY/TITLE»</A>", "<BR>" & NL
    app.setItemRendition  "ACT",             "«ACT/TITLE»", "<BR>" & NL
    app.setItemRendition  "SCENE",           "", ""                    
    app.setItemRendition  "SCTITLE",         "", ""                          
    app.setItemRendition  "SPEECH",          "<TABLE><TR>", "</TR></TABLE>" & NL                           
    app.setGroupRendition "SPEAKER",         "<TD WIDTH=160 VALIGN=TOP><B>", "<BR>", "</B></TD><TD VALIGN=TOP>" & NL         
    app.setItemRendition  "SCENE/STAGEDIR",  "<CENTER><H3>", "</H3></CENTER>" & NL                           
    app.setItemRendition  "SPEECH/STAGEDIR", "<P><I>", "</I></P>" & NL                           
    app.setItemRendition  "LINE/STAGEDIR",   " [ <I>", "</I> ] "
    app.setItemRendition  "SCENE/SUBHEAD",   "<CENTER><H3>", "</H3></CENTER>" & NL                           
    app.setItemRendition  "SPEECH/SUBHEAD",  "<P><B>", "</B></P>" & NL 
    app.setItemRendition  "LINE",            "", "<BR>" & NL 
                
    filename = dir + "/" + play & "/scene" & scene & ".xml"
    resp = app.setInputFile(filename)
    
    if resp <> 0 then
        s = app.errortext
        response.write("<HR>Failed to parse input XML file " & filename & "<BR>" & s & "<HR>")
        response.end
    end if
%>
<HTML><HEAD><TITLE>          <% = app.readBucket("title") %>    </TITLE></HEAD>
<BODY BGCOLOR='#FFFFCC'>     <% = app.readBucket("context") %>  <HR>
<CENTER><H1>                 <% = app.readBucket("title") %>    </H1></CENTER>
    <% = app.readBucket("main") %>
<HR>
    <% if scene <> numScenes then
          nextScene = "scene.asp?dir=" & dir & "&play=" & play & "&scene=" & (scene+1) & "&of=" & numScenes
          response.write("<A HREF='" & nextScene & "'>Next scene</A>")
       end if 
    %>
</BODY></HTML>
