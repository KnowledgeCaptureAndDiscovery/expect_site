package xml2jtml;

import java.io.*;
import java.util.*;
import com.icl.saxon.*;
import org.xml.sax.SAXException;
import org.xml.sax.AttributeList;
import org.xml.sax.InputSource;

public class agendaItemRenderer extends renderer {

  public final static int DEFAULTSIZE        = 0;
  public final static int DESCRIPTION        = 1;
  public final static int DOCUMENTATION      = 2;
  public final static int INSTANCETYPES      = 3;
  public final static int ASSERTEDTYPES      = 4;
  public final static int DIRECTTYPES        = 5;
  public final static int BASETYPE           = 6;
  public final static int ROLES              = 7;
  public final static int INSTANCES          = 8;
  public final static int DIRECTINSTANCES    = 9;
  public final static int INDIRECTINSTANCES  = 10;

  public final static int numberOfItems = INDIRECTINSTANCES+1;
  public static int currentNumOfTabs = 0;
  protected final int jtmlTabSize = 4;

  public static String headingSizes[] = new String[numberOfItems];
  public static String fontColors[] = new String[numberOfItems];
  public static boolean haveRoles = false;

  public agendaItemRenderer() {
    for(int i=0; i<numberOfItems; i++) {
      fontColors[i]="black";
      headingSizes[i]="H5";
    }
    headingSizes[DESCRIPTION]="H4";
  }

  public String toHtml(String xmlString) {

    setHandler("agitemDescription", new agendaItemDescriptionHandler());
    setHandler("ExpectErrorType", new ExpectErrorTypeHandler());
    setHandler("ItemReferencingElement", new ItemReferencingElementHandler());
    setHandler("TextDescription", new TextDescriptionHandler());
    setHandler("Source", new SourceHandler());
    setHandler("ProblemNode", new ProblemNodeHandler());
    setHandler("ErrorCauses", new ErrorCausesHandler());
    setHandler("concept", new conceptHandler());
    setHandler("relation", new relationHandler());
    setHandler("instance", new instanceHandler());
    setHandler("Method", new methodHandler());
    setHandler("psnode", new psnodeHandler());
    setHandler("exenode", new exenodeHandler());

    StringWriter agendaItemBody = new StringWriter();
    setWriter("agitemDescription",agendaItemBody);
    PrintWriter agendaItemWriter;

    agendaItemBody.write("<!--- This is HTML created by agendaItemRenderer. --->\n");
    agendaItemBody.write("<HTML>\n");
    agendaItemBody.write("<BODY bgcolor=\"#00bbbb\" text=\"#000000\">\n");
    runFromNamedParser(new InputSource(new StringReader(xmlString)), "com.ibm.xml.parser.SAXDriver");
    agendaItemBody.write("</BODY>\n");
    agendaItemBody.write("</HTML>\n");
    agendaItemBody.write("<!--- End of HTML.--->\n");
    return(agendaItemBody.toString());
}
  
  class NSElementCopier extends ElementCopier {
    
    public void startElement(ElementInfo e) throws SAXException {
      String thisName = e.getTag();
      
      if(e.getTag().equals("ExpectErrorType") ||
	 e.getTag().equals("TextDescription")) {
	currentNumOfTabs = 0;
      }
      if(currentNumOfTabs>0) {
	e.write("\n<BR><SPACES="+(int)(currentNumOfTabs*jtmlTabSize)+">");
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

  class agendaItemDescriptionHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      AttributeList thisAL = e.getAttributeList();
      int nameIndex = 0;

      for(int count=0; count<thisAL.getLength(); count++) {
	if((thisAL.getName(count)).equals("name"))
	  nameIndex=count;
      }
      e.write("<TITLE>Agenda Item: "+thisAL.getValue(nameIndex)+"</TITLE>\n");
      e.write("<"+headingSizes[DESCRIPTION]+">Agenda Item "+thisAL.getValue(nameIndex)+"</"+headingSizes[DESCRIPTION]+"><br>\n");
    }
    public void endElement(ElementInfo e) throws SAXException {
    }
  }
  
  class TextDescriptionHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      super.startElement(e);
      e.write("<"+headingSizes[DOCUMENTATION]+">Textual description of error: </"+headingSizes[DOCUMENTATION]+"><br>\n");
    }
    public void endElement(ElementInfo e) throws SAXException {
      currentNumOfTabs=0;
      e.write("<BR>\n");
    }
  }

  class ItemReferencingElementHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      super.startElement(e);
      e.write("<"+headingSizes[DOCUMENTATION]+">This agenda item makes reference to the following elements: </"+headingSizes[DOCUMENTATION]+"><br>\n");
    }
    public void endElement(ElementInfo e) throws SAXException {
      currentNumOfTabs=0;
      e.write("<BR>\n");
    }
  }

  class ExpectErrorTypeHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      super.startElement(e);
      e.write("<"+headingSizes[DOCUMENTATION]+">Error type: </"+headingSizes[DOCUMENTATION]+">");
    }
    public void endElement(ElementInfo e) throws SAXException {
      currentNumOfTabs=0;
      e.write("<BR>\n");
    }
  }

  class SourceHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      super.startElement(e);
      e.write("<"+headingSizes[DOCUMENTATION]+">Source of the error: </"+headingSizes[DOCUMENTATION]+">\n");
    }
    public void endElement(ElementInfo e) throws SAXException {
      currentNumOfTabs=0;
      e.write("<BR>\n");
    }
  }

  class ProblemNodeHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      super.startElement(e);
      e.write("<"+headingSizes[DOCUMENTATION]+">Problem occured in node: </"+headingSizes[DOCUMENTATION]+">\n");
    }
    public void endElement(ElementInfo e) throws SAXException {
      currentNumOfTabs=0;
      e.write("<BR>\n");
    }
  }

  class ErrorCausesHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      e.write("<"+headingSizes[INSTANCETYPES]+
	      ">Cause of the error was:: </"+
	      headingSizes[INSTANCETYPES]+"><br>\n");
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
      e.write("</popup>");
    }
  }

  class instanceHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      super.startElement(e);
      e.write("<popup type=\"Instance\">");
    }
    public void endElement(ElementInfo e) throws SAXException {
      e.write("</popup>");
      }
    }

  class relationHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      super.startElement(e);
      e.write("<popup type=\"Relation\">");
    }
    public void endElement(ElementInfo e) throws SAXException {
      e.write("</popup>");
      }
    }

  class methodHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      super.startElement(e);
      e.write("<popup type=\"Method\">");
    }
    public void endElement(ElementInfo e) throws SAXException {
      e.write("</popup>");
      }
    }
  
  class psnodeHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      super.startElement(e);
      e.write("<popup type=\"PSnode\">");
    }
    public void endElement(ElementInfo e) throws SAXException {
      e.write("</popup>");
      }
    }
    
  class exenodeHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      super.startElement(e);
      e.write("<popup type=\"EXEnode\">");
    }
    public void endElement(ElementInfo e) throws SAXException {
      e.write("</popup>");
      }
    }  
  
  }

