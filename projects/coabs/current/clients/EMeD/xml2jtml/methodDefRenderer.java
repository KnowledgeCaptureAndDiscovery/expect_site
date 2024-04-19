package xml2jtml;

import java.io.*;
import java.util.*;
import com.icl.saxon.*;
import org.xml.sax.SAXException;
import org.xml.sax.AttributeList;
import org.xml.sax.InputSource;

public class methodDefRenderer extends renderer {

  public static int tabSize = 0;
  public static int nOpenPar = 0;
  public static boolean lastCharIsParen = false;
  public static int parameterLength = 0;
  private boolean setOf = false;
  StringWriter otherWriter; // hack
  public methodDefRenderer() {
  }
 
  public String toHtml(String xmlString) {
    setHandler("MethodBody", new metBodyHandler());
    setHandler("methodDescription", new methodDescHandler());
    setHandler("VarGoalForm", new goalFormHandler());
    setHandler("VarGoalArgument", new roleExpressionHandler());
    setHandler("ManyVarGoalArgument", new passiveHandler());
    setHandler("MethodGoal", new methodGoalHandler());
    setHandler("GoalName", new goalNameHandler());
    setHandler("ParameterName", new parameterNameHandler());
    setHandler("VariableName", new NameHandler());
    setHandler("InstanceName", new instanceNameHandler());
    setHandler("ConceptName", new NameHandler());
    setHandler("method", new passiveHandler());
    setHandler("t", new tagTHandler());
    setHandler("MethodResult", new methodResultHandler());
    setHandler("MethodGoalArgument", new methodGoalArgumentHandler());
    setHandler("ComplexData", new complexDataHandler());
    setHandler("GoalForm", new goalFormHandler());
    setHandler("GoalParameter", new roleExpressionHandler());
    setHandler("RelationForm", new relFormHandler());
    setHandler("IfForm", new ifFormHandler());
    setHandler("RelationName", new NameHandler());
    setHandler("expression", new passiveHandler());
    setHandler("resultRefiner", new resultRefinerHandler());
    setHandler("StorageInfo", new passiveHandler());
    setHandler("PostProcessing", new postProcessingHandler());
    setHandler("FilterForm", new goalFormHandler());
    setHandler("primitiveBody", new primBodyHandler());
    
    //setHandler("nlDescription", new passiveHandler());
   

    StringWriter methodBody = new StringWriter();
    //otherWriter = new StringWriter();
    setWriter("methodDescription",methodBody);

    runFromNamedParser(new InputSource(new StringReader(xmlString)), "com.ibm.xml.parser.SAXDriver");
    return(methodBody.toString());
    //System.out.println("out:"+otherWriter.toString());
    //return (otherWriter.toString());
  }
  
  class NSElementCopier extends ElementCopier {
    public void ewrite (ElementInfo e, String content) throws SAXException {
      e.write(content);
      //otherWriter.write(content);
    }
    public boolean whiteSpacesOnly (char ch[], int length) {
      boolean whiteOnly = true;
      for (int i = 0; i < length; i++)
	if (ch[i] != '\n' && ch[i] != ' ')
	  whiteOnly = false;
      return whiteOnly;
    }

    public void startElement(ElementInfo e) throws SAXException {
    }

    public void characters(ElementInfo e, char ch[], int start, int length) throws SAXException {
      
      int newStart, end, newEnd, newLength;
      char newCh[];
      
      for(newStart=start;ch[newStart]==' ';newStart++);
      end = start + length - 1;
      for(newEnd=end;ch[newEnd]==' ';newEnd--);
      if (newEnd>=newStart) {
	newCh = ((new String(ch)).substring(newStart,newEnd+1).toLowerCase()).toCharArray();
	if (whiteSpacesOnly (newCh, newEnd-newStart+1))
	  { // this is a kind of hack?
	  }
	else {
	  super.characters(e,newCh,0,newEnd-newStart+1);
	  //System.out.println("NSL copy:"+new String (newCh,0,newEnd-newStart+1)+"|");
	  //otherWriter.write(new String (newCh,0,newEnd-newStart+1));
	}
      } 
      else {}
    }
  }

  /*
   * passiveHandler simply understands that a tag has been
   * encountered but does nothing useful about it.
   */
  class passiveHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
    }
    public void endElement(ElementInfo e) throws SAXException {
    }
  }

  class roleExpressionHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      setOf = false;
      if(tabSize>0)
	for(int i=1; i<(int)(tabSize);i++) 
	   ewrite(e," ");
      ewrite(e,"(");
      lastCharIsParen = true;
  }
    public void endElement(ElementInfo e) throws SAXException {
      if (setOf) 
	ewrite(e,")");
      ewrite(e,")\n");
      tabSize = tabSize - parameterLength - 1;
    }
  }

  class goalNameHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
    }
    public void endElement(ElementInfo e) throws SAXException {
      tabSize = tabSize + 4;
      ewrite(e,"\n");
    }
  }
  
  class instanceNameHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      ewrite(e," ");
    }
    public void endElement(ElementInfo e) throws SAXException {
    }
  }
  
  class parameterNameHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
    }
    public void characters(ElementInfo e, char ch[], int start, int length) throws SAXException {
      tabSize = tabSize + length + 1;
      parameterLength = length;
      super.characters(e,ch,start,length);
    }
    public void endElement(ElementInfo e) throws SAXException {
      if (lastCharIsParen == false) 
	ewrite(e," ");
      lastCharIsParen = false;
    }
  }

  class relFormHandler extends NSElementCopier {    
    public void startElement(ElementInfo e) throws SAXException {
      ewrite(e," (");
    }
    public void characters(ElementInfo e, char ch[], int start, int length) throws SAXException {
      tabSize = tabSize + length + 1;
      parameterLength = length;
      super.characters(e,ch,start,length);
    }
    public void endElement(ElementInfo e) throws SAXException {
     ewrite(e,")");

    }
  }

  class ifFormHandler extends NSElementCopier {    
    public void startElement(ElementInfo e) throws SAXException {
      ewrite(e," (");
    }
    public void characters(ElementInfo e, char ch[], int start, int length) throws SAXException {
      tabSize = tabSize + length + 1;
      parameterLength = length;
      super.characters(e,ch,start,length);
    }
    public void endElement(ElementInfo e) throws SAXException {
     ewrite(e,")");
    }
  }

  class NameHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      if (lastCharIsParen == false) 
	ewrite(e," ");
    }
    public void endElement(ElementInfo e) throws SAXException {
    lastCharIsParen = false;
    }
  }

  class methodGoalArgumentHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      if (lastCharIsParen == false)
	ewrite(e," ");

      ewrite(e,"(");
      lastCharIsParen = true;
    }
    public void endElement(ElementInfo e) throws SAXException {
      ewrite(e,")");
    }
  }

  /*
   * <t></t> can be caught by tagTHandler, <VariableName> when
   * the parent is <METHODGoalArgument> can also use.
   */
  class tagTHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      if (lastCharIsParen == false) {
	ewrite(e," ");
      }
      if (!e.isFirstOfType() && !e.getAttribute("name").equals("IS")) {
	ewrite(e,"(");
      }

      if (e.getAttribute("name").equals("THEN") ||
	  e.getAttribute("name").equals("ELSE")) {
	ewrite(e,"\n");
	if(tabSize>0)
	  for(int i=1; i<(int)(tabSize);i++) 
	    ewrite(e," ");
      }

      ewrite(e,e.getAttribute("name").toLowerCase());
      lastCharIsParen = false;  

      if (e.getAttribute("name").equals("SET-OF")) {
	setOf = true;
      }  
    }
    public void endElement(ElementInfo e) throws SAXException {
      
    /**if (e.getAttribute("name").equals("FILTER")) {
       ewrite(e," (");
       lastCharIsParen = true;
       } else {};*/
    }
  }

  class complexDataHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
    if (lastCharIsParen == false) 
      ewrite(e," ");
    ewrite(e,"(");
    lastCharIsParen = true;
    }
    public void endElement(ElementInfo e) throws SAXException {
      ewrite(e,")");
    }
  }


 class goalFormHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      if (lastCharIsParen == false) ewrite(e," ");
      ewrite(e,"(");
      lastCharIsParen = true;
    }
    public void endElement(ElementInfo e) throws SAXException {
       if(tabSize>0) {
	 for(int i=1; i<(int)(tabSize);i++) 
	  ewrite(e," ");
      }
      ewrite(e,")");
      tabSize = tabSize - 3;
    }
  }

  class methodDescHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      int nameIndex = 0;
      String primitivep = "";

      ewrite(e,"((name "+(e.getAttribute("name")).toLowerCase()+")\n");
      if ((e.getAttribute("primitivep").equals("T"))) {
	ewrite(e," (primitivep t)\n");
	} else {}
    }
    public void endElement(ElementInfo e) throws SAXException {
    ewrite(e,")");
    }
  }
  
  class methodGoalHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      ewrite(e," (capability");
      tabSize = 13;
      lastCharIsParen = false;
    }
    public void endElement(ElementInfo e) throws SAXException {
      ewrite(e,")\n");
    }
  }

  class methodResultHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      super.startElement(e);
      ewrite(e," (result-type");
      lastCharIsParen = false;
    }
    public void endElement(ElementInfo e) throws SAXException {
      ewrite(e,")\n");
    }
  }

  
  class postProcessingHandler extends NSElementCopier {
     boolean specified = false;
     public void startElement(ElementInfo e) throws SAXException {
     }
     public void characters(ElementInfo e, char ch[], int start, int length) throws SAXException {
      String content = new String(ch,start,length);
      if (content != null && content.length() >0) {
         ewrite(e," (post-process ");
	 super.characters(e,ch,start,length);
         specified = true;
         lastCharIsParen = false;
      }
    }
    public void endElement(ElementInfo e) throws SAXException {
      if (specified) ewrite(e,")\n");
    }
  }

  class resultRefinerHandler extends NSElementCopier {
     boolean specified = false;
     public void startElement(ElementInfo e) throws SAXException {
     }
     public void characters(ElementInfo e, char ch[], int start, int length) throws SAXException {
      String content = new String(ch,start,length);
      if (content != null && content.length() >0) {
         ewrite(e," (result-refiner ");
	 super.characters(e,ch,start,length);
         specified = true;
         lastCharIsParen = false;
      }
    }
    public void endElement(ElementInfo e) throws SAXException {
      if (specified) ewrite(e,")\n");
    }
  }
  
  class metBodyHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      super.startElement(e);
      ewrite(e," (method ");
      tabSize = 9;
      lastCharIsParen = false;
    }
    public void endElement(ElementInfo e) throws SAXException {
      ewrite(e,")\n");
    }
  }

  class primBodyHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      super.startElement(e);
      ewrite(e," (method ");
      tabSize = 9;
      lastCharIsParen = false;
    }
    public void endElement(ElementInfo e) throws SAXException {
      ewrite(e,")\n");
    }
  }
  

}


