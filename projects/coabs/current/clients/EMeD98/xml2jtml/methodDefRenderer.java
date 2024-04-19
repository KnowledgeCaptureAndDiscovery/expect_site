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
  public methodDefRenderer() {
  }
 
  public String toHtml(String xmlString) {
    setHandler("MethodBody", new metBodyHandler());
    setHandler("methodDescription", new methodDescHandler());
    setHandler("VarGoalForm", new goalFormHandler());
    setHandler("VarGoalArgument", new roleExpressionHandler());
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
    setHandler("resultRefiner", new passiveHandler());
    setHandler("StorageInfo", new passiveHandler());
    setHandler("PostProcessing", new passiveHandler());
    setHandler("FilterForm", new goalFormHandler());
    setHandler("primitiveBody", new primBodyHandler());

    StringWriter methodBody = new StringWriter();
    setWriter("methodDescription",methodBody);

    runFromNamedParser(new InputSource(new StringReader(xmlString)), "com.ibm.xml.parser.SAXDriver");
    return(methodBody.toString());
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
	newCh = ((new String(ch)).substring(newStart,newEnd+1).toLowerCase()).toCharArray();
	super.characters(e,newCh,0,newEnd-newStart+1);
      } else {}
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
	   e.write(" ");
      e.write("(");
      lastCharIsParen = true;
  }
    public void endElement(ElementInfo e) throws SAXException {
      if (setOf) e.write(")");
      e.write(")\n");
      tabSize = tabSize - parameterLength - 1;
    }
  }

  class goalNameHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
    }
    public void endElement(ElementInfo e) throws SAXException {
      tabSize = tabSize + 4;
      e.write("\n");
    }
  }
  
  class instanceNameHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      e.write(" ");
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
    if (lastCharIsParen == false) e.write(" ");
    lastCharIsParen = false;
    }
  }

  class relFormHandler extends NSElementCopier {    
    public void startElement(ElementInfo e) throws SAXException {
      e.write(" (");
    }
    public void characters(ElementInfo e, char ch[], int start, int length) throws SAXException {
      tabSize = tabSize + length + 1;
      parameterLength = length;
      super.characters(e,ch,start,length);
    }
    public void endElement(ElementInfo e) throws SAXException {
     e.write(")");

    }
  }

  class ifFormHandler extends NSElementCopier {    
    public void startElement(ElementInfo e) throws SAXException {
      e.write(" (");
    }
    public void characters(ElementInfo e, char ch[], int start, int length) throws SAXException {
      tabSize = tabSize + length + 1;
      parameterLength = length;
      super.characters(e,ch,start,length);
    }
    public void endElement(ElementInfo e) throws SAXException {
     e.write(")");

    }
  }

  class NameHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
    if (lastCharIsParen == false) e.write(" ");
    }
    public void endElement(ElementInfo e) throws SAXException {
    lastCharIsParen = false;
    }
  }

  class methodGoalArgumentHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      if (lastCharIsParen == false) e.write(" ");
      e.write("(");
      lastCharIsParen = true;
    }
    public void endElement(ElementInfo e) throws SAXException {
      e.write(")");
    }
  }

  /*
   * <t></t> can be caught by tagTHandler, <VariableName> when
   * the parent is <METHODGoalArgument> can also use.
   */
  class tagTHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      if (lastCharIsParen == false) e.write(" ");
      if (!e.isFirstOfType() && !e.getAttribute("name").equals("IS"))
	e.write("(");

      if (e.getAttribute("name").equals("THEN") ||
	  e.getAttribute("name").equals("ELSE")) {
	e.write("\n");
	if(tabSize>0)
	  for(int i=1; i<(int)(tabSize);i++)
	    e.write(" ");
      }

      e.write(e.getAttribute("name").toLowerCase());
      lastCharIsParen = false;  

      if (e.getAttribute("name").equals("SET-OF")) {
	setOf = true;
      }  
    }
    public void endElement(ElementInfo e) throws SAXException {
      
    /**if (e.getAttribute("name").equals("FILTER")) {
       e.write(" (");
       lastCharIsParen = true;
       } else {};*/
    }
  }

  class complexDataHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
    if (lastCharIsParen == false) e.write(" ");
    e.write("(");
    lastCharIsParen = true;
    }
    public void endElement(ElementInfo e) throws SAXException {
    e.write(")");
    }
  }


 class goalFormHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      if (lastCharIsParen == false) e.write(" ");
      e.write("(");
      lastCharIsParen = true;
    }
    public void endElement(ElementInfo e) throws SAXException {
       if(tabSize>0) {
	for(int i=1; i<(int)(tabSize);i++)
	  e.write(" ");
      }
      e.write(")");
      tabSize = tabSize - 3;
    }
  }

  class methodDescHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      int nameIndex = 0;
      String primitivep = "";

      e.write("((name "+(e.getAttribute("name")).toLowerCase()+")\n");
      if ((e.getAttribute("primitivep").equals("T"))) {
	e.write(" (primitivep t)\n");
	} else {}
    }
    public void endElement(ElementInfo e) throws SAXException {
    e.write(")");
    }
  }
  
  class methodGoalHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      e.write(" (capability");
      tabSize = 13;
      lastCharIsParen = false;
    }
    public void endElement(ElementInfo e) throws SAXException {
      e.write(")\n");
    }
  }

  class methodResultHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      super.startElement(e);
      e.write(" (result-type");
      lastCharIsParen = false;
    }
    public void endElement(ElementInfo e) throws SAXException {
      e.write(")\n");
    }
  }
    
  class metBodyHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      super.startElement(e);
      e.write(" (method ");
      tabSize = 9;
      lastCharIsParen = false;
    }
    public void endElement(ElementInfo e) throws SAXException {
      e.write(")\n");
    }
  }

  class primBodyHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      super.startElement(e);
      e.write(" (method ");
      tabSize = 9;
      lastCharIsParen = false;
    }
    public void endElement(ElementInfo e) throws SAXException {
      e.write(")\n");
    }
  }
  

}

