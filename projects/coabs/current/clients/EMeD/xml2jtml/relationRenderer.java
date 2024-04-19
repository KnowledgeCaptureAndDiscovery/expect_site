package xml2jtml;

import java.io.*;
import java.util.*;
import com.icl.saxon.*;
import org.xml.sax.SAXException;
import org.xml.sax.AttributeList;
import org.xml.sax.InputSource;

public class relationRenderer extends renderer {

  public final static int DEFAULTSIZE        = 0;
  public final static int DESCRIPTION        = 1;
  public final static int DEFINITION         = 2;
  public final static int DOCUMENTATION      = 3;
  public final static int SUBRELATIONS       = 4;
  public final static int SUPERRELATIONS     = 5;
  public final static int SIBLINGS           = 6;
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

  public relationRenderer() {
    for(int i=0; i<numberOfItems; i++) {
      fontColors[i]="black";
      headingSizes[i]="H5";
    }
    headingSizes[DESCRIPTION]="H4";
  }

  public String toHtml(String xmlString) {

    setHandler("relationDescription", new relationDescriptionHandler());
    setHandler("Definition", new definitionHandler());
    setHandler("concept", new conceptHandler());
    setHandler("Documentation", new documentationHandler());
    setHandler("subRelations", new subRelationsHandler());
    setHandler("superRelations", new superRelationsHandler());
    setHandler("Siblings", new siblingsHandler());
    setHandler("Roles", new roleHandler());
    setHandler("MinCardinality", new ElementHandlerBase());
    setHandler("MaxCardinality", new ElementHandlerBase());
    setHandler("relation", new relationHandler());
    setHandler("instance", new instanceHandler());

    StringWriter relationBody = new StringWriter();
    setWriter("relationDescription",relationBody);
    PrintWriter relationWriter;

    relationBody.write("<!--- This is HTML created by relationRenderer. --->\n");
    relationBody.write("<HTML>\n");
    relationBody.write("<BODY bgcolor=\"#00bbbb\" text=\"#000000\">\n");
    runFromNamedParser(new InputSource(new StringReader(xmlString)), "com.ibm.xml.parser.SAXDriver");
    relationBody.write("</BODY>\n");
    relationBody.write("</HTML>\n");
    relationBody.write("<!--- End of HTML. --->\n");
 
    return(relationBody.toString());
  }
  
  class NSElementCopier extends ElementCopier {
    
    public void startElement(ElementInfo e) throws SAXException {
      String thisName = e.getTag();
      
      if(e.getTag().equals("relationDefinition") ||
	 e.getTag().equals("Definition") ||
	 e.getTag().equals("Documentation")) {
	currentNumOfTabs = 0;
      }
      if(currentNumOfTabs>0) {
	e.write("<BR><SPACES="+(int)(currentNumOfTabs*jtmlTabSize)+">");
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

  class relationDescriptionHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      AttributeList thisAL = e.getAttributeList();
      int nameIndex = 0;

      for(int count=0; count<thisAL.getLength(); count++) {
	if((thisAL.getName(count)).equals("name"))
	  nameIndex=count;
      }
      e.write("<TITLE>RELATION: "+thisAL.getValue(nameIndex)+"</TITLE>\n");
      e.write("<"+headingSizes[DESCRIPTION]+">RELATION <popup type=\"Relation\""+thisAL.getValue(nameIndex)+"</popup> </"+headingSizes[DESCRIPTION]+"><br>\n");
    }
    public void endElement(ElementInfo e) throws SAXException {
    }
  }
  
  class definitionHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      super.startElement(e);
      e.write("<"+headingSizes[DEFINITION]+">Definition of this relation: </"+headingSizes[DEFINITION]+"><br>\n");
      e.write("<P>");
    }
    public void endElement(ElementInfo e) throws SAXException {
      e.write("</P><br>\n");
    }
  }

  class documentationHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      super.startElement(e);
      e.write("<"+headingSizes[DOCUMENTATION]+">Relation Documentation: </"+headingSizes[DOCUMENTATION]+"><br>\n");
    }
    public void endElement(ElementInfo e) throws SAXException {
    }
  }

  class subRelationsHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      e.write("<"+headingSizes[SUBRELATIONS]+
	      ">Subrelation(s) of this relation: </"+
	      headingSizes[SUBRELATIONS]+"><br>\n");
      currentNumOfTabs=1;
    }
    public void endElement(ElementInfo e) throws SAXException {
      currentNumOfTabs=0;
      e.write("<BR>\n");
    }
  }

  class superRelationsHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      e.write("<"+headingSizes[SUPERRELATIONS]+
	      ">Superrelation(s) of this relation: </"+
	      headingSizes[SUPERRELATIONS]+"><br>\n");
      currentNumOfTabs=1;
    }
    public void endElement(ElementInfo e) throws SAXException {
      currentNumOfTabs=0;
      e.write("<BR>\n");
    }
  }
  
  class siblingsHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      if(e.isFirstOfType()) {
	e.write("<"+headingSizes[SIBLINGS]+
		">Sibling(s) of this relation: </"+
		headingSizes[SIBLINGS]+"><br>\n");
	currentNumOfTabs=1;
      }
    }
    public void endElement(ElementInfo e) throws SAXException {
      currentNumOfTabs=0;
    } 
  }
  
  class roleHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      e.write("<"+headingSizes[ROLES]+
	      "This relation's roles: </"+
	      headingSizes[ROLES]+"><br>\n");
      currentNumOfTabs=1;
    }
    public void endElement(ElementInfo e) throws SAXException {
      currentNumOfTabs=0;
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
      String lineBreak = "";
      ElementInfo parent = e.getParent();
      if (parent.getTag().equals("superRelations") ||
	  parent.getTag().equals("subRelations")) {
	lineBreak = "";
	}      
      e.write("</popup>"+lineBreak);
    }
  }
  

}



