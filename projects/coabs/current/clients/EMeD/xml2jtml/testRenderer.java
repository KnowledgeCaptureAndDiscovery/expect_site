package xml2jtml;
import java.io.*;
import java.util.*;
import com.icl.saxon.*;
import org.xml.sax.*;
import org.xml.sax.helpers.*;

public class testRenderer {

public static void main(String argv[]) {
    String out = "";
    String in = "";
    
    //    tboxDefRenderer r = new tboxDefRenderer();
//    methodRenderer r = new methodRenderer();
//    instanceRenderer r = new instanceRenderer();
//    KBSummaryRenderer r = new KBSummaryRenderer();
//    PSNodeRenderer r = new PSNodeRenderer();
//    agendaItemRenderer r = new agendaItemRenderer();
//    relationRenderer r = new relationRenderer();
    methodDefRenderer r = new methodDefRenderer();
    
    //in = r.readFileToString("/home/jihie/expect/interface/ni/xml2jtml/conceptDef.xml");
    in = r.readFileToString("/home/jihie/expect/EMeD/Client2/xml2jtml/methodDef.xml");
    out = r.toHtml(in);
    if (out.equals("")) {
	System.out.println("Error: run returned empty string");
	} else {
	System.out.println(out);
	}    
    return ;
    
    }

}
