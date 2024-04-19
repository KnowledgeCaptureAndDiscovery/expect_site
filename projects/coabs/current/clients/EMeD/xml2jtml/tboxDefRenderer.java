package xml2jtml;

import java.io.*;
import java.util.*;
import com.icl.saxon.*;
import org.xml.sax.*;
import org.xml.sax.helpers.*;

public class tboxDefRenderer extends renderer {

  public tboxDefRenderer() {
  }
  
  public String toHtml(String xmlString) {
    setHandler("tboxDescription", new vanillaHandler());
    setHandler("conceptDescription", new vanillaHandler());
    setHandler("relationDescription", new vanillaHandler());
    setHandler("Definition", new definitionHandler());
    setHandler("concept", new nameHandler());
    setHandler("Documentation", new vanillaHandler());
    setHandler("relation", new nameHandler());
    setHandler("instance", new nameHandler());

    StringWriter tboxBody = new StringWriter();
    setWriter("tboxDescription",tboxBody);

    runFromNamedParser(new InputSource(new StringReader(xmlString)), "com.ibm.xml.parser.SAXDriver");
    
    return(tboxBody.toString());
  }
  
  class NSElementCopier extends ElementCopier {
    
    public void startElement(ElementInfo e) throws SAXException {
    }
    
    /** 
    * Notice that this method calls e.write instead of a call to the
    * superclass method. This is because we needed to ouput double quotes
    * (that occur e.g. in documentation strings) intact, while the default method
    * escapes them into html sequences
    */
    
    public void characters(ElementInfo e, char ch[], int start, int length) throws SAXException {
      
      int newStart, end, newEnd, newLength;
      char newCh[];
      
      for(newStart=start;ch[newStart]==' ';newStart++);
      end = start + length - 1;
      for(newEnd=end;ch[newEnd]==' ';newEnd--);
      if(newEnd>=newStart) {
	newCh = ((new String(ch)).substring(newStart,newEnd+1)).toLowerCase().toCharArray();
	e.write(newCh,0,newEnd-newStart+1);
      } else {
      }
    }
  }

  class vanillaHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
    }
    public void endElement(ElementInfo e) throws SAXException {
    }
  }
  
  class definitionHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      super.startElement(e);
      e.write("\n");
    }
    public void endElement(ElementInfo e) throws SAXException {
    }
  }

  class nameHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
    e.write(" ");
    }
    public void endElement(ElementInfo e) throws SAXException {
    }
  }

}



