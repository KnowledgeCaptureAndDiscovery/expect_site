import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;

import com.icl.saxon.*;

/**
 * ShowPlay Servlet<BR>
 * Outputs an XML Shakespeare play file in HTML 
 * @author Michael Kay
 * @version 11 May 1998
 */
 
public class ShowPlay extends HttpServlet {

    /**
    * service() - accept request and produce response<BR>
    * URL parameters: <UL>
    * <LI>dir - the directory in which all the XML is held
    * <LI>play - the directory name of this Shakespeare play
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

        String dir = req.getParameter("dir");
        String play = req.getParameter("play");

        app=new Renderer();

        StringWriter errorText = new StringWriter();
        app.setErrorOutput(errorText);

        app.setOption(app.RETAIN_ATTRIBUTES, true);

        StringWriter mainSW = new StringWriter();
        StringWriter titleSW = new StringWriter();
        StringWriter subtitleSW = new StringWriter();
        StringWriter scndescrSW = new StringWriter();
        StringWriter personaeSW = new StringWriter();

        app.setWriter ("PLAY", mainSW );
        app.setWriter ("PLAY/TITLE", titleSW );
        app.setWriter ("PLAYSUBT", subtitleSW);
        app.setWriter ("SCNDESCR", scndescrSW );
        app.setWriter ("PERSONAE", personaeSW );
            
        app.setItemRendition ("PLAY", "", "" );
        app.setItemRendition ("PLAY/TITLE", "", "" );
        app.setItemRendition ("TITLE", "<CENTER><H3>", "</H3></CENTER>" );
        app.setItemRendition ("PLAYSUBT", "", "" );
        app.setItemRendition ("PERSONAE", "", "" );
        app.setItemRendition ("PERSONAE/PERSONA", "<TABLE><TR><TD VALIGN=TOP>", "</TD></TR></TABLE>");
        app.setItemRendition ("PGROUP", "", "" );
        app.setGroupRendition ("PGROUP/PERSONA", "<TABLE><TR><TD WIDTH=160 VALIGN=TOP>", "<BR>\n", "</TD><TD WIDTH=20></TD>" );
        app.setGroupRendition ("PGROUP/GRPDESCR", "<TD VALIGN=BOTTOM>", "<BR>\n", "</TD></TR></TABLE>\n" );                                        
        app.setItemRendition ("SCNDESCR", "", "\n");
        app.setItemRendition ("ACT", "", "" );
        app.setItemRendition ("SCTITLE", "<A HREF='ShowScene?dir=" + dir + "&play=«PLAY/NAME»&scene=«SCTITLE/SCENE»&of=«PLAY/SCENES»'>", "</A><BR>\n" );

        String inputFile = dir + "\\" + play + "\\play.xml";

        int result = app.run ( new ExtendedInputSource( new File(inputFile) ) );
        if (result==0) {  
            out.println("<HTML><HEAD><TITLE>"  + titleSW.toString() + "</TITLE></HEAD>");
            out.println("<BODY BGCOLOR='#FFFFCC'><CENTER><H1>" + titleSW.toString() + "</H1>");
            out.println("<H3>" + subtitleSW.toString() + "</H3>");
            out.println("<I>" + scndescrSW.toString() + "</I></CENTER><BR><HR>");
            out.println("<TABLE><TR><TD WIDTH=350 VALIGN=TOP BGCOLOR='#88FF88'>");
            out.println(personaeSW.toString());       
            out.println("</TD><TD WIDTH=30></TD><TD VALIGN=TOP>");
            out.println(mainSW.toString());
            out.println("</TD></TR></TABLE><HR></BODY></HTML>");
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
        return "Returns an HTML representation of a Shakespeare play";
    }

}
