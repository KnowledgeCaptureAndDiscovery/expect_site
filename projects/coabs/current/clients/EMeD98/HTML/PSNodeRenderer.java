package xml2jtml;

import java.io.*;
import java.util.*;
import com.icl.saxon.*;
import org.xml.sax.SAXException;
import org.xml.sax.AttributeList;
import org.xml.sax.InputSource;

public class PSNodeRenderer extends renderer {

  public final static int DEFAULTSIZE        = 0;
  public final static int DESCRIPTION        = 1;
  public final static int EXPRESSION         = 2;
  public final static int SUBEXPRESSION      = 3;
  public final static int EXPANDEDEXPRESSION = 4;
  public final static int NODERESULT         = 5;
  public final static int PARENTPSNODE       = 6;
  public final static int CHILDPSNODE        = 7;
  public final static int ORIGINMETHOD       = 8;
  public final static int CURRENTANODE       = 9;
  public final static int PREFERENCENOTTRIED = 10;
  public final static int FAILEDANODE        = 11;

  public final static int numberOfItems = FAILEDANODE+1;
  public static int currentNumOfTabs = 0;
  protected final int jtmlTabSize = 4;

  public static String headingSizes[] = new String[numberOfItems];
  public static String fontColors[] = new String[numberOfItems];
  public static boolean haveRoles = false;

  public PSNodeRenderer() {
  }
  
  public PSNodeRenderer(String xmlFile) {
    for(int i=0; i<numberOfItems; i++) {
      fontColors[i]="black";
      headingSizes[i]="H5";
    }
    headingSizes[DESCRIPTION]="H4";
  }

  public String toHtml(String xmlString) {

    setHandler("psnodeDescription", new psnodeDescriptionHandler());
    setHandler("NodeExpression", new nExpressionHandler());
    setHandler("NodeSubExpression", new nSubExpressionHandler());
    setHandler("NodeExpandedExpression", new nExpExpressionHandler());
    setHandler("NodeResult", new nodeResultHandler());
    setHandler("ParentPsnodes", new ParentPSNHandler());
    setHandler("ChildPsnodes", new ChildPSNHandler());
    setHandler("OriginatingMethods", new originatingMethodsHandler());
    setHandler("CurrentAnode", new currentANodeHandler());
    setHandler("PreferencesNotTried", new prefNotTriedHandler());
    setHandler("FailedAnodes", new failedAnodesHandler());
    setHandler("relation", new relationHandler());
    setHandler("instance", new instanceHandler());
    setHandler("concept", new conceptHandler());
    setHandler("psnode", new psnodeHandler());

    StringWriter psnodeBody = new StringWriter();
    setWriter("psnodeDescription",psnodeBody);
    PrintWriter psnodeWriter;

    psnodeBody.write("<!--- This is HTML created by PSNodeRenderer. --->\n");
    psnodeBody.write("<HTML>\n");
    psnodeBody.write("<BODY bgcolor=\"#00bbbb\" text=\"#000000\">\n");
    runFromNamedParser(new InputSource(new StringReader(xmlString)), "com.ibm.xml.parser.SAXDriver");
    psnodeBody.write("</BODY>\n");
    psnodeBody.write("</HTML>\n");
    psnodeBody.write("<!--- End of HTML.--->\n");
    return(psnodeBody.toString());
  }
  
  class NSElementCopier extends ElementCopier {
    
    public void startElement(ElementInfo e) throws SAXException {
      String thisName = e.getTag();
      
      if(e.getTag().equals("psnodeDescription") ||
	 e.getTag().equals("NodeExpression") ||
	 e.getTag().equals("NodeSubExpression") ||
	 e.getTag().equals("NodeExpandedExpression") ||
	 e.getTag().equals("NodeResult")) {
	currentNumOfTabs = 0;
      }
      if(currentNumOfTabs>0) {
	e.write("<SPACES="+(int)(currentNumOfTabs*jtmlTabSize)+">");
      }
    }

    public void characters(ElementInfo e, char ch[], int start, int length) throws SAXException {
      
      int newStart, end, newEnd, newLength;
      char newCh[];
      
      for(newStart=start;ch[newStart]==' ';newStart++);
      end = start + length - 1;
      for(newEnd=end;ch[newEnd]==' ';newEnd--);
      if(newEnd>=newStart) {
	newCh = ((new String(ch)).substring(newStart,newEnd+1)).toCharArray();
	super.characters(e,newCh,0,newEnd-newStart+1);
      } else {
      }
    }
  }

  class psnodeDescriptionHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      e.write("<TITLE>CONCEPT: "+e.getAttribute("name")+"</TITLE>\n");
      e.write("<"+headingSizes[DESCRIPTION]+">PSNODE: "+e.getAttribute("name")+
	      "\n<SPACES=4>Node Type: "+e.getAttribute("type")+
	      "\n<SPACES=4>ENode or ANode: " + e.getAttribute("enodeOrAnode") +
	      "</"+headingSizes[DESCRIPTION]+"><br>\n");
    }
    public void endElement(ElementInfo e) throws SAXException {
    }
  }
  
  class nExpressionHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      super.startElement(e);
      e.write("<"+headingSizes[EXPRESSION]+">Node Expression: </"+headingSizes[EXPRESSION]+"><br>\n");
      e.write("<P>");
    }
    public void endElement(ElementInfo e) throws SAXException {
      e.write("</P><br>\n");
    }
  }

  class nSubExpressionHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      super.startElement(e);
      e.write("<"+headingSizes[SUBEXPRESSION]+">Node SubExpression: </"+headingSizes[SUBEXPRESSION]+"><br>\n");
    }
    public void endElement(ElementInfo e) throws SAXException {
    }
  }

  class nExpExpressionHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      super.startElement(e);
      e.write("<"+headingSizes[EXPANDEDEXPRESSION]+
	      ">Node Expanded Expression: </"+
	      headingSizes[EXPANDEDEXPRESSION]+"><br>\n");
    }
    public void endElement(ElementInfo e) throws SAXException {
      e.write("<br>\n");
    }
  }

  class nodeResultHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      super.startElement(e);
      e.write("<"+headingSizes[NODERESULT]+
	      ">Node Results: </"+
	      headingSizes[NODERESULT]+"><br>\n");
    }
    public void endElement(ElementInfo e) throws SAXException {
      e.write("<br>\n");
    }
  }
  
  class ParentPSNHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      e.write("<"+headingSizes[PARENTPSNODE]+
	      ">Parent PS Nodes: </"+
	      headingSizes[PARENTPSNODE]+"><br>\n");
      currentNumOfTabs=1;
    }
    public void endElement(ElementInfo e) throws SAXException {
      currentNumOfTabs=0;
      e.write("<br>\n");
    } 
  }
  
  class ChildPSNHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      e.write("<"+headingSizes[CHILDPSNODE]+
	      ">Child PS Nodes: </"+
	      headingSizes[CHILDPSNODE]+"><br>\n");
      currentNumOfTabs=1;
    }
    public void endElement(ElementInfo e) throws SAXException {
      currentNumOfTabs=0;
      e.write("<br>\n");
    }
  }

  class originatingMethodsHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      e.write("<"+headingSizes[ORIGINMETHOD]+
	      ">Originating Methods: </"+
	      headingSizes[ORIGINMETHOD]+">\n");
      currentNumOfTabs=1;
    }
    public void endElement(ElementInfo e) throws SAXException {
      currentNumOfTabs=0;
      e.write("<br>\n");
    }
  }

  class currentANodeHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      e.write("<"+headingSizes[CURRENTANODE]+
	      ">Current ANodes: </"+
	      headingSizes[CURRENTANODE]+">\n");
      currentNumOfTabs=1;
    }
    public void endElement(ElementInfo e) throws SAXException {
      currentNumOfTabs=0;
      e.write("<BR>\n");
    }
  }
  
  class prefNotTriedHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      e.write("<"+headingSizes[PREFERENCENOTTRIED]+
	      ">Preferences Not Tried: </"+
	      headingSizes[PREFERENCENOTTRIED]+">\n");
      currentNumOfTabs=1;
    }
    public void endElement(ElementInfo e) throws SAXException {
      currentNumOfTabs=0;
      e.write("<BR>\n");
    }
  }

  class failedAnodesHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      e.write("<"+headingSizes[FAILEDANODE]+
	      ">Failed ANodes: </"+
	      headingSizes[FAILEDANODE]+">\n");
      currentNumOfTabs=1;
    }
    public void endElement(ElementInfo e) throws SAXException {
      currentNumOfTabs=0;
      e.write("<BR>\n");
    }
  }

  class conceptHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      super.startElement(e);
      e.write("<popup type=\"Concept\">");
    }
    public void endElement(ElementInfo e) throws SAXException {
      e.write("</popup>\n");
    }
  }

  class instanceHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      super.startElement(e);
      e.write("<popup type=\"Instance\">");
    }
    public void endElement(ElementInfo e) throws SAXException {
      e.write("</popup>\n");
    }
  }

  class relationHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      super.startElement(e);
      e.write("<popup type=\"Relation\">");
    }
    public void endElement(ElementInfo e) throws SAXException {
      e.write("</popup>\n");
    }
  }

  class psnodeHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      super.startElement(e);
      e.write("<popup type=\"PSnode\">");
    }
    public void endElement(ElementInfo e) throws SAXException {
      e.write("</popup>\n");
    }
  }
}




