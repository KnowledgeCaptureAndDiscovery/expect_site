package xml2jtml;

import java.io.*;
import java.util.*;
import com.icl.saxon.*;
import org.xml.sax.*;
import org.xml.sax.helpers.*;
import xml2jtml.renderer;

public class searchResultRenderer extends renderer {

  private String searchString;
  private String resultString;

  public searchResultRenderer() {
    searchString = "";
    resultString = "";
  }
  public searchResultRenderer(String theResultString) {
    resultString = theResultString;
    searchString = "";
  }
  public searchResultRenderer(String theResultString, String theSearchString) {
    resultString = theResultString;
    searchString = theSearchString;
  }
  public void setResultString(String theResultString) {
    resultString = theResultString;
  }
  public String getResultString() {
    return resultString;
  }

  public String toHtml(String xmlString) {

    setHandler("searchResults", new searchResultsHandler());
    setHandler("method", new methodHandler());
    setHandler("instance", new instanceHandler());
    setHandler("relation", new relationHandler());
    setHandler("concept", new conceptHandler());

    StringWriter resultBody = new StringWriter();
    setWriter("searchResults",resultBody);

    resultBody.write("<!--- This is HTML created by searchResultRenderer. --->\n");
    resultBody.write("<HTML>\n");
    resultBody.write("<BODY bgcolor=\"#00bbbb\" text=\"#000000\">");
    runFromNamedParser(new InputSource(new StringReader(xmlString)), "com.ibm.xml.parser.SAXDriver");
    resultBody.write("</BODY>\n");
    resultBody.write("</HTML>\n");
    resultBody.write("<!--- End of HTML.--->\n");
    return(resultBody.toString());

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

  class searchResultsHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      AttributeList thisAL = e.getAttributeList();

      e.write("<TITLE>Search Results on: "+searchString+"</TITLE>\n");
      e.write("<H3>Number of Possible Matches:     "+thisAL.getValue(0)+"</H3><br>\n");
      e.write("<H3>Search Results:</H3><br>\n");
    }
    public void endElement(ElementInfo e) throws SAXException {
    }
  }
  
  class methodHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      if(e.isFirstOfType()) {
	e.write("<H3>Methods that match query:</H3><br>\n");
      }
      e.write("<popup type=\"Method\">");
    }
    public void endElement(ElementInfo e) throws SAXException {
      e.write("</popup><br>\n");
    }
  }
  class instanceHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      if(e.isFirstOfType()) {
	e.write("<H3>Instances that match query:</H3><br>\n");
      }
      e.write("<popup type=\"Instance\">");
    }
    public void endElement(ElementInfo e) throws SAXException {
      e.write("</popup><br>\n");
    }
  }
class relationHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      if(e.isFirstOfType()) {
	e.write("<H3>Relations that match query:</H3><br>\n");
      }
      e.write("<popup type=\"Relation\">");
    }
    public void endElement(ElementInfo e) throws SAXException {
      e.write("</popup><br>\n");
    }
  }
class conceptHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      if(e.isFirstOfType()) {
	e.write("<H3>Concepts that match query:</H3><br>\n");
      }
      e.write("<popup type=\"Concept\">");
    }
    public void endElement(ElementInfo e) throws SAXException {
      e.write("</popup><br>\n");
    }
  }
}
