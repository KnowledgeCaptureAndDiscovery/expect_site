package xml2jtml;

import java.io.*;
import java.util.*;
import com.icl.saxon.*;
import org.xml.sax.SAXException;
import org.xml.sax.AttributeList;
import org.xml.sax.InputSource;

public class KBListParser extends renderer {

  String xmlKBList;
  Vector listOfKBs;

  public KBListParser() {
    this("");
  }

  public KBListParser(String KBList) {
    xmlKBList = KBList;
  }

  public void setKBList(String KBList) {
    xmlKBList = KBList;
  }

  public Vector getKBs(String KBList) {

    setHandler("kb", new KBHandler());
    
    listOfKBs = new Vector();

    if(KBList==null) {
      int result = runFromNamedParser(new InputSource(new StringReader(xmlKBList)), "com.ibm.xml.parser.SAXDriver");
    } else {
      int result = runFromNamedParser(new InputSource(new StringReader(KBList)), "com.ibm.xml.parser.SAXDriver");
    }

    return(listOfKBs);
  }
  

  class KBHandler extends ElementHandlerBase {
    public void characters(ElementInfo e, char ch[], int start, int length) throws SAXException {
      
      int newStart, end, newEnd, newLength;
      char newCh[];
      
      for(newStart=start;ch[newStart]==' ';newStart++);
      end = start + length - 1;
      for(newEnd=end;ch[newEnd]==' ';newEnd--);
      if(newEnd>=newStart) {
	listOfKBs.addElement((new String(ch)).substring(newStart,newEnd+1));
      } else {
      }
    }
  }

}




