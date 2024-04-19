import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;

import com.icl.saxon.*;

/**
 * ShowScene Servlet<BR>
 * Displays a scene of a Shakespeare play encoded in XML 
 * @author Michael Kay
 * @version 1997 May 11
 */
 
public class ShowScene extends HttpServlet {

    /**
    * service() - accept request and produce response<BR>
    * URL parameters: <UL>
    * <LI>dir - the directory in which all the XML is held
    * <LI>play - the directory name of this Shakespeare play
    * <LI>scene - the sequential number of this scene
    * <LI>of - the number of the last scene in the play
    * </UL>
    * @param req The HTTP request
    * @param res The HTTP response
    */
    
    public void service(HttpServletRequest req, HttpServletResponse res)
	throws ServletException, IOException
    {
        Renderer app;
     
        res.setContentType("text/html");
        ServletOutputStream out = res.getOutputStream();
        
        String play = req.getParameter("play");
        String scene = req.getParameter("scene");
        String dir = req.getParameter("dir");
        String lastScene = req.getParameter("of");
        
        app=new Renderer();    

        StringWriter errorText = new StringWriter();
        app.setErrorOutput(errorText);

        app.setOption(app.RETAIN_ATTRIBUTES, true);
        
        StringWriter titleSW = new StringWriter();
        StringWriter contextSW = new StringWriter();
        StringWriter mainSW = new StringWriter();
        
        app.setWriter ("SCTITLE", titleSW);
        app.setWriter ("CONTEXT", contextSW);
        app.setWriter ("SCENE", mainSW);

        app.setItemRendition(  "PLAY",            "<A HREF='ShowPlay?dir=" + dir + "&play=" + play + "'>«PLAY/TITLE»</A>", "<BR>\n" );
        app.setItemRendition(  "ACT",             "«ACT/TITLE»", "<BR>\n" );
       
        app.setItemRendition(  "SCENE",           "", ""       );             
        app.setItemRendition(  "SCTITLE",         "", ""       );                  
        app.setItemRendition(  "SPEECH",          "<TABLE><TR>", "</TR></TABLE>\n" );                          
        app.setGroupRendition( "SPEAKER",         "<TD WIDTH=160 VALIGN=TOP><B>", "<BR>", "</B></TD><TD VALIGN=TOP>" );         
        app.setItemRendition(  "SCENE/STAGEDIR",  "<CENTER><H3>", "</H3></CENTER>\n" );
        app.setItemRendition(  "SPEECH/STAGEDIR", "<P><I>", "</I></P>" );                 
        app.setItemRendition(  "LINE/STAGEDIR",   " [ <I>", "</I> ] " );
        app.setItemRendition(  "SCENE/SUBHEAD",   "<CENTER><H3>", "</H3></CENTER>\n" );                           
        app.setItemRendition(  "SPEECH/SUBHEAD",  "<P><B>", "</B></P>" );
        app.setItemRendition(  "LINE",            "", "<BR>\n" );

        String inputFile = dir + "\\" + play + "\\scene" + scene + ".xml";

        int result = app.run ( new ExtendedInputSource( new File(inputFile) ) );
        if (result==0) {
            out.println("<HTML><HEAD><TITLE>" + titleSW.toString() + "</TITLE></HEAD>");
            out.println("<BODY BGCOLOR='#FFFFCC'>" + contextSW.toString() + "<HR>");
            out.println("<CENTER><H1>" + titleSW.toString() + "</H1></CENTER>");
            out.println(mainSW.toString() + "<HR>");
            if (!scene.equals(lastScene)) {
                int nextScene = Integer.parseInt(scene) + 1;
                String nextSceneLink = "ShowScene?dir=" + dir + "&play=" + play + "&scene=" + nextScene + "&of=" + lastScene;
                out.println("<A HREF='" + nextSceneLink + "'>Next scene</A>");
            }
            out.println("</BODY></HTML>");
        }
        else {
            out.println("<HTML><HEAD><TITLE>Error processing XML</TITLE></HEAD>");
            out.println("<BODY><H1>Error processing XML</H1>");
            out.println(errorText.toString());
            out.println("<BR><HR></BODY></HTML>");
        }
    }

    /**
    * getServletInfo<BR>
    * Required by Servlet interface
    */   

    public String getServletInfo() {
        return "Returns an HTML representation of a Shakespeare scene";
    }

}
