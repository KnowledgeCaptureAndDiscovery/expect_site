package xml2jtml;

import java.io.*;
import java.util.*;
import com.icl.saxon.*;
import org.xml.sax.SAXException;
import org.xml.sax.AttributeList;
import org.xml.sax.InputSource;

public class KBSummaryRenderer extends renderer {

  private String KBName;
  private String KBInfo;
  private String InfoFile;
  private String outPutFile;

  public KBSummaryRenderer() {
    KBName = "";
    KBInfo = "";
    outPutFile = "";
  }
  public void setInfoString(String givenInfo) {
    KBInfo = givenInfo;
  }
  public String getInfoString() {
    return KBInfo;
  }

  public String toHtml(String theInfoString) {

    setHandler("kbReport", new kbReportHandler());
    setHandler("nMethods", new nMethodsHandler());
    setHandler("nInstances", new nInstancesHandler());
    setHandler("nRelations", new nRelationsHandler());
    setHandler("nConcepts", new nConceptsHandler());

    StringWriter resultBody = new StringWriter();
    setWriter("kbReport",resultBody);

    resultBody.write("<!--- This is HTML created by KBSummaryRenderer. --->\n");
    resultBody.write("<HTML>\n");
    resultBody.write("<BODY bgcolor=\"#00bbbb\" text=\"#000000\">\n");
    if(theInfoString == null && KBInfo == null && InfoFile==null) {
	System.out.println("No KB Info to Render!!!");
    } else if(theInfoString!=null) {
	int result = runFromNamedParser(new InputSource(new StringReader(theInfoString)), "com.ibm.xml.parser.SAXDriver");
    } else if(KBInfo != null) {
	int result = runFromNamedParser(new InputSource(new StringReader(KBInfo)), "com.ibm.xml.parser.SAXDriver");
    } 
    resultBody.write("</BODY>\n");
    resultBody.write("</HTML>\n");
    resultBody.write("<!--- End of HTML. --->\n");
    return resultBody.toString();
  }
  
    class NSElementCopier extends ElementCopier {
      public void startElement(ElementInfo e) throws SAXException {
      }
      public void endElement(ElementInfo e) throws SAXException {
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

  class kbReportHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      e.write("</TITLE>KB Summary for: "+e.getAttribute("name")+"</TITLE><BR>\n");
      e.write("<P>\n");
    }
    public void endElement(ElementInfo e) throws SAXException {
      e.write("</P>\n");
    }
  }
  
  class nMethodsHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      e.write("The number of methods in this KB: ");
    }
    public void endElement(ElementInfo e) throws SAXException {
      e.write("<br>\n");
    }
  }
  class nInstancesHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      e.write("The number of instances in this KB: ");
    }
    public void endElement(ElementInfo e) throws SAXException {
      e.write("<br>\n");
    }
  }
  class nRelationsHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      e.write("The number of relations in this KB: ");
    }
    public void endElement(ElementInfo e) throws SAXException {
      e.write("<br>\n");
    }
  }

  class nConceptsHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      e.write("The number of concepts in this KB: ");
     }
    public void endElement(ElementInfo e) throws SAXException {
      e.write("<br>\n");
    }
  }
}
