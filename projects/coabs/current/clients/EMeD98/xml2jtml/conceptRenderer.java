package xml2jtml;

import java.io.*;
import java.util.*;
import com.icl.saxon.*;
import org.xml.sax.SAXException;
import org.xml.sax.AttributeList;
import org.xml.sax.InputSource;

public class conceptRenderer extends renderer {

  public final static int DEFAULTSIZE        = 0;
  public final static int DESCRIPTION        = 1;
  public final static int DEFINITION         = 2;
  public final static int DOCUMENTATION      = 3;
  public final static int SUBCONCEPTS        = 4;
  public final static int SUPERCONCEPTS      = 5;
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

  public conceptRenderer() {
    for(int i=0; i<numberOfItems; i++) {
      fontColors[i]="black";
      headingSizes[i]="H5";
    }
    headingSizes[DESCRIPTION]="H4";
  }

  public String toHtml(String xmlString) {
    StringWriter conceptBody = new StringWriter();
    setWriter("conceptDescription",conceptBody);
      
    setHandler("conceptDescription", new conceptDescriptionHandler());
    setHandler("Definition", new definitionHandler());
    setHandler("concept", new conceptHandler());
    setHandler("Documentation", new documentationHandler());
    setHandler("subConcepts", new subConceptsHandler());
    setHandler("superConcepts", new superConceptsHandler());
    setHandler("Siblings", new siblingsHandler());
    setHandler("Roles", new roleHandler());
    setHandler("Instances", new instancesHandler());
    setHandler("DirectInstances", new directInstancesHandler());
    setHandler("NonDirectInstances", new nonDirectInstancesHandler());
    setHandler("DetailedRole", new ElementHandlerBase());
    setHandler("Type", new ElementHandlerBase());
    setHandler("MinCardinality", new ElementHandlerBase());
    setHandler("MaxCardinality", new ElementHandlerBase());
    setHandler("StrictValues", new ElementHandlerBase());
    setHandler("DefaultValues", new ElementHandlerBase());
    setHandler("relation", new relationHandler());
    setHandler("instance", new instanceHandler());
    setHandler("WithCommonParent", new withCommonParentHandler());

    conceptBody.write("<!--- This is HTML created by conceptRenderer. --->\n");
    conceptBody.write("<HTML>\n");
    conceptBody.write("<BODY bgcolor=\"#00bbbb\" text=\"#000000\">\n");
    runFromNamedParser(new InputSource(new StringReader(xmlString)), "com.ibm.xml.parser.SAXDriver");
    conceptBody.write("</BODY>\n");
    conceptBody.write("</HTML>\n");
    conceptBody.write("<!--- End of HTML. --->\n");
  
    return(conceptBody.toString());
  }
  
  class NSElementCopier extends ElementCopier {
    
    public void startElement(ElementInfo e) throws SAXException {
      String thisName = e.getTag();
      
      if(e.getTag().equals("conceptDefinition") ||
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

  class conceptDescriptionHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      AttributeList thisAL = e.getAttributeList();
      int nameIndex = 0;

      for(int count=0; count<thisAL.getLength(); count++) {
	if((thisAL.getName(count)).equals("name"))
	  nameIndex=count;
      }
      e.write("<TITLE>CONCEPT: "+thisAL.getValue(nameIndex)+"</TITLE>\n");
      e.write("<"+headingSizes[DESCRIPTION]+">CONCEPT <popup type=\"Concept\">"+e.getAttribute("name")+"</popup> </"+headingSizes[DESCRIPTION]+"><br>\n");
    }
    public void endElement(ElementInfo e) throws SAXException {
    }
  }
  
  class definitionHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      super.startElement(e);
      e.write("<"+headingSizes[DEFINITION]+">Definition of this concept: </"+headingSizes[DEFINITION]+"><br>\n");
      e.write("<P>");
    }
    public void endElement(ElementInfo e) throws SAXException {
      e.write("</P><br>\n");
    }
  }

  class documentationHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      super.startElement(e);
      e.write("<"+headingSizes[DOCUMENTATION]+">Concept Documentation: </"+headingSizes[DOCUMENTATION]+"><br>\n");
    }
    public void endElement(ElementInfo e) throws SAXException {
    }
  }

  class subConceptsHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      e.write("<"+headingSizes[SUBCONCEPTS]+
	      ">Subconcept(s) of this concept: </"+
	      headingSizes[SUBCONCEPTS]+"><br>\n");
      currentNumOfTabs=1;
    }
    public void endElement(ElementInfo e) throws SAXException {
      currentNumOfTabs=0;
      e.write("<BR>\n");
    }
  }

  class superConceptsHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      e.write("<"+headingSizes[SUPERCONCEPTS]+
	      ">Superconcept(s) of this concept: </"+
	      headingSizes[SUPERCONCEPTS]+"><br>\n");
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
		">Sibling(s) of this concept: </"+
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
	      "This concept's roles: </"+
	      headingSizes[ROLES]+"><br>\n");
      currentNumOfTabs=1;
    }
    public void endElement(ElementInfo e) throws SAXException {
      currentNumOfTabs=0;
    }
  }

  class instancesHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      e.write("<"+headingSizes[INSTANCES]+
	      "Instances of this concept: </"+
	      headingSizes[INSTANCES]+">\n");
      e.write("<BR>Number of Instance(s) of this concept: "+
	      e.getAttribute("total")+"\n");
      e.write("<BR>Number of direct Instance(s) of this concept: "+
	      e.getAttribute("direct")+"\n");
      e.write("<BR>Number of nondirect Instance(s) of this concept: "+
	      e.getAttribute("nonDirect")+"\n");
      e.write("<BR>\n");
    }
    public void endElement(ElementInfo e) throws SAXException {
    }
  }

  class directInstancesHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      /*
	e.write("Number of Direct Instance(s): "+
	e.getParent().getAttribute("direct")+"\n");
	*/
      e.write("Direct Instances:\n");
      currentNumOfTabs=1;
    }
    public void endElement(ElementInfo e) throws SAXException {
      currentNumOfTabs=0;
      e.write("<BR>\n");
    }
  }
  
  class nonDirectInstancesHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      /*
	e.write("Number of Non-Direct Instance(s): "+
	e.getParent().getAttribute("nonDirect")+"\n");
	*/
      e.write("Non-direct Instances:\n");
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
      String lineBreak = "";
      ElementInfo parent = e.getParent();
      if (parent.getTag().equals("superConcepts") ||
	  parent.getTag().equals("subConcepts")) {
	lineBreak = "";
	}      
      e.write("</popup>"+lineBreak);
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
  
  class withCommonParentHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      e.write("Siblings with the common parent: <popup type=\"Concept\">"+
	      e.getAttribute("name")+"</popup>");
      currentNumOfTabs=1;
    }
    public void endElement(ElementInfo e) throws SAXException {
      currentNumOfTabs=0;
      e.write("<br>\n");
    }
  }
}



