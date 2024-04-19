package HTML;

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
	e.write("\n"+getSpaces((int)(currentNumOfTabs*jtmlTabSize)));
	//e.write("<BR><SPACES="+(int)(currentNumOfTabs*jtmlTabSize)+">");
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
      e.write(" <"+headingSizes[DESCRIPTION]+">RELATION <A HREF = \""+e.getAttribute("name")+".relation\">"+ e.getAttribute("name")+"</A> </"+headingSizes[DESCRIPTION]+"><br>\n");
    }
    public void endElement(ElementInfo e) throws SAXException {
    }
  }
  
  class definitionHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      super.startElement(e);
      e.write("<"+headingSizes[DEFINITION]+">Definition: </"+headingSizes[DEFINITION]+"><br>\n");
      e.write("<P>");
    }
    public void endElement(ElementInfo e) throws SAXException {
      e.write("</P><br>\n");
    }
  }

  class documentationHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      super.startElement(e);
      e.write("<"+headingSizes[DOCUMENTATION]+">Documentation: </"+headingSizes[DOCUMENTATION]+"><br>\n");
    }
    public void endElement(ElementInfo e) throws SAXException {
    }
  }

  class subRelationsHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      e.write("<"+headingSizes[SUBRELATIONS]+
	      ">Subrelations: </"+
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
	      ">Superrelations: </"+
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
    }
    public void characters (ElementInfo e, char ch[], int start, int length) throws SAXException {
      String contents = new String(ch,start,length);
      contents = contents.trim();
      ElementInfo parent = e.getParent();
      e.write(" <A HREF =\""+contents+".concept\">"+contents);
    }
    public void endElement(ElementInfo e) throws SAXException {
      e.write("</A>");
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
	e.write ("<p> Instance:");
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
      ElementInfo parent = e.getParent();
      contents = contents.trim();
      e.write(" <A HREF =\""+contents+".concept\">"+contents);
    }
    public void endElement(ElementInfo e) throws SAXException {
      e.write("</A> ");
    }
  }
   private String getSpaces(int n) {
    String result = "";
    for (int i=0; i<n; i++)
      result = result + " ";
    return result;
  }

}



