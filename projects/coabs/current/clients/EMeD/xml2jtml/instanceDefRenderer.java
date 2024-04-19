package xml2jtml;

import java.io.*;
import java.util.*;
import com.icl.saxon.*;
import org.xml.sax.*;
import org.xml.sax.helpers.*;

public class instanceDefRenderer extends renderer {

  public instanceDefRenderer() {
  }
  
  public String toHtml(String xmlString) {
    setHandler("instanceDefinition", new instanceDescriptionHandler());
    setHandler("Definition", new definitionHandler());
    setHandler("concept", new nameHandler());
    setHandler("Documentation", new documentationHandler());
    setHandler("relation", new nameHandler());
    setHandler("instance", new nameHandler());

    StringWriter instanceBody = new StringWriter();
    setWriter("instanceDefinition",instanceBody);

    runFromNamedParser(new InputSource(new StringReader(xmlString)), "com.ibm.xml.parser.SAXDriver");
    
    return(instanceBody.toString());
  }
  
  class NSElementCopier extends ElementCopier {
    
    public void startElement(ElementInfo e) throws SAXException {
    }

    public void characters(ElementInfo e, char ch[], int start, int length) throws SAXException {
      
      int newStart, end, newEnd, newLength;
      char newCh[];
      
      for(newStart=start;ch[newStart]==' ';newStart++);
      end = start + length - 1;
      for(newEnd=end;ch[newEnd]==' ';newEnd--);
      if(newEnd>=newStart) {
	newCh = ((new String(ch)).substring(newStart,newEnd+1)).toLowerCase().toCharArray();
	super.characters(e,newCh,0,newEnd-newStart+1);
      } else {
      }
    }
  }

  class instanceDescriptionHandler extends NSElementCopier {
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

  class documentationHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
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



