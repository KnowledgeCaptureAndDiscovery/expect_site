package xml2jtml;

import java.io.*;
import java.util.*;
import com.icl.saxon.*;
import org.xml.sax.SAXException;
import org.xml.sax.AttributeList;
import org.xml.sax.InputSource;

public class instanceRenderer extends renderer {

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

  public instanceRenderer() {
    for(int i=0; i<numberOfItems; i++) {
      fontColors[i]="black";
      headingSizes[i]="H5";
    }
    headingSizes[DESCRIPTION]="H4";
  }

  public String toHtml(String xmlString) {

    setHandler("instanceDescription", new instanceDescriptionHandler());
    setHandler("Documentation", new documentationHandler());
    setHandler("InstanceTypes", new InstanceTypesHandler());
    setHandler("BaseType", new BaseTypeHandler());
    setHandler("AssertedTypes", new AssertedTypesHandler());
    setHandler("DirectTypes", new DirectTypesHandler());
    setHandler("InstanceRoles", new InstanceRolesHandler());
    setHandler("DetailedRole", new DetailedRoleHandler());
    setHandler("RoleValues", new ElementHandlerBase());
    setHandler("concept", new conceptHandler());
    setHandler("relation", new relationHandler());
    setHandler("instance", new instanceHandler());

    StringWriter instanceBody = new StringWriter();
    setWriter("instanceDescription",instanceBody);

    instanceBody.write("<!--- This is HTML created by instanceRenderer. --->\n");
    instanceBody.write("<HTML>\n");
    instanceBody.write("<BODY bgcolor=\"#00bbbb\" text=\"#000000\">\n");
    runFromNamedParser(new InputSource(new StringReader(xmlString)), "com.ibm.xml.parser.SAXDriver");
    instanceBody.write("</BODY>\n");
    instanceBody.write("</HTML>\n");
    instanceBody.write("<!--- End of HTML.--->\n");
 
    return(instanceBody.toString());
  }
  
  class NSElementCopier extends ElementCopier {
    
    public void startElement(ElementInfo e) throws SAXException {
      String thisName = e.getTag();
      
      if(e.getTag().equals("InstanceTypes") ||
	 e.getTag().equals("InstanceRoles") ||
	 e.getTag().equals("Documentation")) {
	currentNumOfTabs = 0;
      }
      if(currentNumOfTabs>0) {
	e.write("\n<BR><SPACES="+(int)(currentNumOfTabs*jtmlTabSize)+">");
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
	    if (ch[i]=='\n') {
		Intermediary = Intermediary + "<BR>";
		finalLength = finalLength + 4;
		}
	    if (ch[i]==' ' && ch[i+1]==' ') {
		for (j=0;ch[i+j]==' ';j++);
		Intermediary = Intermediary + "<SPACES=" + j + ">";
		if (j<10) {
		    finalLength = finalLength + 10;
		    } else {
		    finalLength = finalLength + 11;
		    }
		i = i+j-1;
		}
	    Intermediary = Intermediary + ch[i];
	    finalLength = finalLength + 1;
	    }
	newCh = Intermediary.toLowerCase().toCharArray();
	e.write(newCh,0,finalLength-1);
      } else {
      }
    }  }

  class instanceDescriptionHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      AttributeList thisAL = e.getAttributeList();
      int nameIndex = 0;

      for(int count=0; count<thisAL.getLength(); count++) {
	if((thisAL.getName(count)).equals("name"))
	  nameIndex=count;
      }
      e.write("<TITLE>instance: "+thisAL.getValue(nameIndex)+"</TITLE>\n");
      e.write("<"+headingSizes[DESCRIPTION]+">Instance <popup type=\"Instance\">"+e.getAttribute("name")+"</popup> </"+headingSizes[DESCRIPTION]+"><br>\n");
    }
    public void endElement(ElementInfo e) throws SAXException {
    }
  }
  
  class documentationHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      super.startElement(e);
      e.write("<"+headingSizes[DOCUMENTATION]+">Instance Documentation: </"+headingSizes[DOCUMENTATION]+"><br>\n");
    }
    public void endElement(ElementInfo e) throws SAXException {
    }
  }

  class InstanceTypesHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      e.write("<"+headingSizes[INSTANCETYPES]+
	      ">Types of this instance: </"+
	      headingSizes[INSTANCETYPES]+"><br>\n");
      currentNumOfTabs=1;
    }
    public void endElement(ElementInfo e) throws SAXException {
      currentNumOfTabs=0;
      e.write("<BR>\n");
    }
  }

    class BaseTypeHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      e.write("<"+headingSizes[BASETYPE]+
	      ">Base type:</"+
	      headingSizes[BASETYPE]+">");
      currentNumOfTabs=1;
    }
    public void endElement(ElementInfo e) throws SAXException {
      currentNumOfTabs=0;
      e.write("<BR>\n");
    }
  }
  
   class AssertedTypesHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      e.write("<"+headingSizes[ASSERTEDTYPES]+
	      ">Asserted types:</"+
	      headingSizes[ASSERTEDTYPES]+"><br>\n");
      currentNumOfTabs=1;
    }
    public void endElement(ElementInfo e) throws SAXException {
      currentNumOfTabs=0;
      e.write("<BR>\n");
    }
  }
  
  class DirectTypesHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      e.write("<"+headingSizes[DIRECTTYPES]+
	      ">Direct types:</"+
	      headingSizes[DIRECTTYPES]+"><br>\n");
      currentNumOfTabs=1;
    }
    public void endElement(ElementInfo e) throws SAXException {
      currentNumOfTabs=0;
      e.write("<BR>\n");
    }
  }
  
  class InstanceRolesHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      e.write("<"+headingSizes[ROLES]+
	      ">The following assertions were made about this instance:</"+
	      headingSizes[ROLES]+"><br>\n");
      currentNumOfTabs=1;
    }
    public void endElement(ElementInfo e) throws SAXException {
      currentNumOfTabs=0;
    }
  }

  class DetailedRoleHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      e.write("<SPACES="+(int)jtmlTabSize+">(");
      currentNumOfTabs=0;
    }
    public void endElement(ElementInfo e) throws SAXException {
      e.write(")<BR>\n");
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
      ElementInfo parent = e.getParent();
      if (parent.getTag().equals("AssertedTypes") ||
	  parent.getTag().equals("DirectTypes")) {
	e.write("</popup><BR>\n");
	} else {
	e.write("</popup>\n");
      }
    }
  }

  class relationHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      super.startElement(e);
      e.write("<popup type=\"Relation\">");
    }
    public void endElement(ElementInfo e) throws SAXException {
      ElementInfo parent = e.getParent();
      if (parent.getTag().equals("DetailedRole")) {
	e.write("</popup> \n");
	} else {
	e.write("</popup>\n");
      }
    }
  }
}
