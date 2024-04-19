package HTML;

import java.io.*;
import java.util.*;
import com.icl.saxon.*;
import org.xml.sax.SAXException;
import org.xml.sax.AttributeList;
import org.xml.sax.InputSource;
import xml2jtml.renderer;

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
    setHandler("Type", new typeHandler());
    setHandler("MinCardinality", new ElementHandlerBase());
    setHandler("MaxCardinality", new ElementHandlerBase());
    setHandler("StrictValues", new ElementHandlerBase());
    setHandler("DefaultValues", new ElementHandlerBase());
    setHandler("relation", new relationHandler());
    setHandler("Relation", new relationHandler());
    setHandler("instance", new instanceHandler());
    setHandler("WithCommonParent", new withCommonParentHandler());

    conceptBody.write("<!--- This is HTML created by conceptRenderer. --->\n");
    conceptBody.write("<HTML>\n");
    conceptBody.write("<BODY bgcolor=\"#00bbbb\" text=\"#000000\">\n");
    runFromNamedParser(new InputSource(new StringReader(xmlString)), "com.ibm.xml.parser.SAXDriver");
    conceptBody.write("</BODY>\n");
    conceptBody.write("</HTML>\n");
    conceptBody.write("<!--- End of HTML. --->\n");

    System.out.println("RESULT HTML in renderer"+conceptBody.toString());
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
	e.write("\n"+getSpaces((int)(currentNumOfTabs*jtmlTabSize)));
      }
    }

    /** 
    * Notice that this method calls e.write instead of a call to the
    * superclass method. This is because we needed to ouput double quotes
    * (that occur e.g. in documentation strings) intact, while the default method
    * escapes them into html sequences
    * This method is alspo exceptionsl in that it scans for specific characters
    * in the formatted xml produced by Loom in order to substitute them for
    * HTML equivalents.   
    */
    
    public void characters(ElementInfo e, char ch[], int start, int length) throws SAXException {
      
      int newStart, end, newEnd, newLength, finalLength = 0;
      char newCh[];
      String Intermediary = "";
      int i,j;
      
      for(newStart=start;ch[newStart]==' ';newStart++);
      end = start + length - 1;
      for(newEnd=end;ch[newEnd]==' ';newEnd--);
      if(newEnd>=newStart) {
	for(i=newStart;i<=newEnd+1;i++) {
	  /*if (ch[i]=='\n') {
		Intermediary = Intermediary + "\n";
		finalLength = finalLength + 1;
		}*/
	    if (ch[i]==' ' && ch[i+1]==' ') {
		for (j=0;ch[i+j]==' ';j++);
		Intermediary = Intermediary + getSpaces(j);
		finalLength = finalLength + j;
		    
		i = i+j-1;
		}
	    Intermediary = Intermediary + ch[i];
	    finalLength = finalLength + 1;
	    }
	newCh = Intermediary.toLowerCase().toCharArray();
	e.write(newCh,0,finalLength-1);
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
      e.write(" <"+headingSizes[DESCRIPTION]+">CONCEPT <A HREF = \""+e.getAttribute("name")+".concept\">"+ e.getAttribute("name")+"</A> </"+headingSizes[DESCRIPTION]+"><br>\n");
    }
    public void endElement(ElementInfo e) throws SAXException {
    }
  }
  
  class definitionHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      super.startElement(e);
      e.write("<"+headingSizes[DEFINITION]+">Definition: </"+headingSizes[DEFINITION]+">\n");
      e.write("<P>\n<pre>");
    }
    public void endElement(ElementInfo e) throws SAXException {
      System.out.println("** end definition **");
      e.write("</P></pre>\n");
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
	      ">Subconcepts: </"+
	      headingSizes[SUBCONCEPTS]+">\n<pre>");
      currentNumOfTabs=1;
    }
    public void endElement(ElementInfo e) throws SAXException {
      currentNumOfTabs=0;
      e.write("\n</pre> <BR>\n");
    }
  }

  class superConceptsHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      e.write("<"+headingSizes[SUPERCONCEPTS]+
	      ">Superconcepts: </"+
	      headingSizes[SUPERCONCEPTS]+"><br>\n<pre>");
      currentNumOfTabs=1;
    }
    public void endElement(ElementInfo e) throws SAXException {
      currentNumOfTabs=0;
      e.write("\n</pre><BR>\n");
    }
  }
  
  class siblingsHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      if(e.isFirstOfType()) {
	e.write("<"+headingSizes[SIBLINGS]+
		">Siblings: </"+
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
      e.write("<p><"+headingSizes[ROLES]+
	      ">Roles: </"+
	      headingSizes[ROLES]+">\n<pre>");
      currentNumOfTabs=1;
    }
    public void endElement(ElementInfo e) throws SAXException {
      e.write("</pre>");
      currentNumOfTabs=0;
    }
  }

  class instancesHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      e.write("\n<"+headingSizes[INSTANCES]+
	      ">Number of Instances: </"+
	      headingSizes[INSTANCES]+"> ");
      e.write(e.getAttribute("total")+" (");
      e.write(e.getAttribute("direct")+" direct, ");
      e.write(e.getAttribute("nonDirect")+" inferred)<BR>\n");
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
      e.write("<p>Direct Instances:\n");
      currentNumOfTabs=1;
    }
    public void endElement(ElementInfo e) throws SAXException {
      currentNumOfTabs=0;
      e.write("<BR>\n");
    }
  }
  
  class nonDirectInstancesHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      e.write("\n<p>Inferred Instances:\n<pre>");
      currentNumOfTabs=1;
    }
    public void endElement(ElementInfo e) throws SAXException {
      currentNumOfTabs=0;
      e.write("</pre><BR>\n");
    }
  }

  class conceptHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      super.startElement(e);
    }
    public void characters  (ElementInfo e, char ch[], int start, int length) throws SAXException {
      String contents = new String(ch,start,length);
      ElementInfo parent = e.getParent();
      contents = contents.trim();
      if (parent.getTag().equals("superConcepts") ||
	parent.getTag().equals("subConcepts") ||
	parent.getTag().equals("WithCommonParent")) {
        e.write(" <li> ");
      }   
      e.write(" <A HREF =\""+contents+".concept\">"+contents);
    }

    public void endElement(ElementInfo e) throws SAXException {
      e.write("</A> ");
    }
  }

  class instanceHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      super.startElement(e);
    }
    public void characters  (ElementInfo e, char ch[], int start, int length) throws SAXException {
      String contents = new String(ch,start,length);
      contents = contents.trim();
      if (!contents.equals("NIL")) {
        ElementInfo parent = e.getParent();
        if (parent.getTag().equals("DirectInstances") ||
	  parent.getTag().equals("NonDirectInstances")) {
	  e.write(" <li> ");
        }  
	else e.write ("<p> Instance:");
        e.write(" <A HREF =\""+contents+".instance\">"+contents+"</A> \n");
      }
    }
    public void endElement(ElementInfo e) throws SAXException {
      
    }
  }

  class relationHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      super.startElement(e);
    }
    public void characters  (ElementInfo e, char ch[], int start, int length) throws SAXException {
      String contents = new String(ch,start,length);
      contents = contents.trim();
      ElementInfo parent = e.getParent();
      if (parent.getTag().equals("DetailedRole")) {
        e.write(" <li> ");
      }
      e.write(" <A HREF =\""+contents+".relation\">"+contents);
    }
    public void endElement(ElementInfo e) throws SAXException {
      e.write("</A> ");
    }
  }

  class typeHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      super.startElement(e);
      e.write(" -- ");
    }
  }
  
  class withCommonParentHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      
      e.write("Siblings with the common parent: <A HREF=\""+e.getAttribute("name")+".concept\">"+ e.getAttribute("name")+"</A> <pre>");
      currentNumOfTabs=1;
    }
    public void endElement(ElementInfo e) throws SAXException {
      currentNumOfTabs=0;
      e.write("</pre><br>\n");
    }
  }
  private String getSpaces(int n) {
    String result = "";
    for (int i=0; i<n; i++)
      result = result + " ";
    return result;
  }
}



