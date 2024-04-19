package xml2jtml;

import java.io.*;
import java.util.*;
import com.icl.saxon.*;
import org.xml.sax.SAXException;
import org.xml.sax.AttributeList;
import org.xml.sax.InputSource;

public class methodRenderer extends renderer {

  public final static int DEFAULTSIZE       = 0;
  public final static int METHODDESCRIPTION = 1;
  public final static int METHODGOAL        = 2;
  public final static int SUPERMETHOD       = 3;
  public final static int SUBMETHOD         = 4;
  public final static int REFERRINGPSNODES  = 5;
  public final static int REFERRINGEXENODES = 6;
  public final static int REFERRINGAGENDAIT = 7;
  public final static int REFERRINGGROUPS   = 8;
  public final static int REFERRINGMACROCMP = 9;
  public final static int METHODRESULT      = 10;
  public final static int METHODBODY        = 11;

  public final static int superMethodEmpty      = 0;
  public final static int subMethodEmpty        = 1;
  public final static int RefAgendaItemEmpty    = 2;
  public final static int RefGroupsEmpty        = 3;
  public final static int RefMacroCmpEmpty      = 4;
  public final static int RefPSNodesEmpty       = 5;
  public final static int RefEXENodesEmpty      = 6;


  public final static int numberOfItems = METHODBODY+1;
  public static int currentNumOfTabs = 0;
  protected final int jtmlTabSize = 4;

  public static String headingSizes[] = new String[numberOfItems];
  public static String fontColors[] = new String[numberOfItems];
  public static boolean elementEmpty[] = new boolean[8];
	
 
  public methodRenderer() {
    for(int i=0; i<numberOfItems; i++) {
      fontColors[i]="black";
      headingSizes[i]="H5";
    }
    headingSizes[METHODDESCRIPTION]="H4";
  }

  public static void setEmptyArray(int arrayIndex, boolean value) {
    if(arrayIndex>=0 && arrayIndex<8) {
      elementEmpty[arrayIndex] = value;
    }
  }
  
  public static boolean getEmptyArray(int arrayIndex) {
    if(arrayIndex<0 || arrayIndex>8) {
      System.out.println("Error: elementEmpty access on index out of bounds.");
      System.exit(1);
    }
    return elementEmpty[arrayIndex];
  }

  public String toHtml(String xmlString) {
	setEmptyArray(superMethodEmpty,false);
	setEmptyArray(subMethodEmpty,false);
	setEmptyArray(RefAgendaItemEmpty,false);
	setEmptyArray(RefGroupsEmpty,false);
        setEmptyArray(RefMacroCmpEmpty,false);
        setEmptyArray(RefPSNodesEmpty,false);
        setEmptyArray(RefEXENodesEmpty,false);

    setHandler("MethodBody", new metBodyHandler());
    setHandler("method", new methodHandler());
    setHandler("refPsnodes", new RefPSNHandler());
    setHandler("refExenodes", new RefEXNHandler());
    setHandler("refAgendaItems", new RefAGIHandler());
    setHandler("refGroups", new RefGRPHandler());
    setHandler("refMacrocomponents", new RefMACHandler());
    setHandler("superMethods", new superMHandler());
    setHandler("subMethods", new subMetHandler());
    setHandler("methodDescription", new methodDescHandler());
    setHandler("nlDescription", new nlDescHandler());
    setHandler("VarGoalForm", new varGoalFormHandler());
    setHandler("VarGoalArgument", new varGoalArgumentHandler());
    setHandler("MethodGoal", new methodGoalHandler());
    setHandler("GoalName", new goalNameHandler());
    setHandler("ParameterName", new parameterNameHandler());
    setHandler("VariableName", new variableNameHandler());
    setHandler("InstanceName", new instanceNameHandler());
    setHandler("ConceptName", new conceptNameHandler());
    setHandler("edt", new edtHandler());
    setHandler("t", new tagTHandler());
    setHandler("MethodResult", new methodResultHandler());
    setHandler("MethodGoalArgument", new methodGoalArgumentHandler());
    setHandler("ComplexData", new passiveActionHandler());
    setHandler("GoalForm", new goalFormHandler());
    setHandler("GoalParameter", new goalParameterHandler());
    setHandler("expression", new expressionHandler());
    setHandler("resultRefiner", new passiveActionHandler());
    setHandler("StorageInfo", new passiveActionHandler());
    setHandler("PostProcessing", new passiveActionHandler());
    setHandler("psnode", new psnodeHandler());
    setHandler("exenode", new exenodeHandler());
    setHandler("agitem", new agitemHandler());

    StringWriter methodBody = new StringWriter();
    setWriter("methodDescription",methodBody);

    methodBody.write("<!--- This is HTML created by methodRenderer. --->\n");
    methodBody.write("<HTML>\n");
    methodBody.write("<BODY bgcolor=\"#00bbbb\" text=\"#000000\">");
    runFromNamedParser(new InputSource(new StringReader(xmlString)), "com.ibm.xml.parser.SAXDriver");
    methodBody.write("</BODY>\n");
    methodBody.write("</HTML>\n");
    methodBody.write("<!--- End of HTML. --->\n");
 
    return(methodBody.toString());
  }
  
  class NSElementCopier extends ElementCopier {
    
    public void startElement(ElementInfo e) throws SAXException {
      String thisName = e.getTag();
      
      if((e.getParent()!=null) &&
	 ((e.getParent()).getTag()).equals("methodDescription")) {
	currentNumOfTabs = 0;
      }
      if(currentNumOfTabs>0) {
	e.write("<SPACES="+(int)(currentNumOfTabs*jtmlTabSize)+">");
      }
      if(thisName.equals("superMethods")) {
	setEmptyArray(superMethodEmpty,true);
      } else if(thisName.equals("subMethods")) {
        setEmptyArray(subMethodEmpty,true);
      } else if(thisName.equals("refAgendaItems")) {
	setEmptyArray(RefAgendaItemEmpty,true);      
      } else if(thisName.equals("refGroups")) {
	setEmptyArray(RefGroupsEmpty,true);
      } else if(thisName.equals("refMacrocomponents")) {
	setEmptyArray(RefMacroCmpEmpty,true);
      } else if(thisName.equals("refPsnodes")) {
	setEmptyArray(RefPSNodesEmpty,true);
      } else if(thisName.equals("refExenodes")) {
	setEmptyArray(RefEXENodesEmpty,true);
      } else {}
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

  class methodDescHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      // AttributeList thisAL = e.getAttributeList();
      int nameIndex = 0;
      String primitivep = "";

      //for(int count=0; count<thisAL.getLength(); count++) {
      //  System.out.println("Name: "+thisAL.getName(count)+ " Type: " + thisAL.getType(count)+ " Value: " + thisAL.getValue(count));
      //  if((thisAL.getName(count)).equals("name"))
      //  nameIndex=count;
      //  }
      if ((e.getAttribute("primitivep").equals("T")))
	primitivep = "PRIMITIVE ";
      e.write("<TITLE>"+primitivep+"METHOD: "+e.getAttribute("name")+"</TITLE>\n");
      e.write("<"+headingSizes[METHODDESCRIPTION]+">METHOD <popup type=\"Method\">" +e.getAttribute("name")+"</popup> </"+headingSizes[METHODDESCRIPTION]+"><br>\n");
    }
    public void endElement(ElementInfo e) throws SAXException {
    }
  }
  
  class nlDescHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      super.startElement(e);
      e.write("\n<"+headingSizes[METHODDESCRIPTION]+">Natural Language Description: </"+headingSizes[METHODDESCRIPTION]+"><br>\n");
    }
    public void endElement(ElementInfo e) throws SAXException {
      e.write("<br>\n");
    }
  }

  class methodGoalHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      super.startElement(e);
      e.write("\n<"+headingSizes[METHODGOAL]+">Method Goal (Capability): </"+headingSizes[METHODGOAL]+"><br>\n");
    }
    public void endElement(ElementInfo e) throws SAXException {
    }
  }

  class varGoalArgumentHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      if(e.getParent().getTag().equals("VarGoalForm") ||
	 e.getParent().getTag().equals("ManyVarGoalArgument"))
	 super.startElement(e);
      e.write("(");
    }
    public void endElement(ElementInfo e) throws SAXException {
      e.write(")<br>\n");
    }
  }

  class varGoalFormHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      e.write("(");
    }
    public void endElement(ElementInfo e) throws SAXException {
      e.write(")<br>\n");
    }
  }
  
  class goalNameHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      e.write("<popup type=\"Verb\">");
    }
    public void endElement(ElementInfo e) throws SAXException {
      e.write("</popup><br>\n");
      currentNumOfTabs++;
    }
  }
  
  class parameterNameHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      e.write("<popup type=\"Relation\">");
    }
    public void endElement(ElementInfo e) throws SAXException {
      e.write("</popup> ");
    }
  }

  class psnodeHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      e.write("<popup type=\"PSNode\">");
    }
    public void endElement(ElementInfo e) throws SAXException {
      e.write("</popup> ");
    }
  }
  
  class exenodeHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      e.write("<popup type=\"EXENode\">");
    }
    public void endElement(ElementInfo e) throws SAXException {
      e.write("</popup> ");
    }
  }
  
  class agitemHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      e.write("<popup type=\"AgendaItem\">");
    }
    public void endElement(ElementInfo e) throws SAXException {
      e.write("</popup> ");
    }
  }

  class conceptNameHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      e.write("<popup type=\"Concept\">");
    }
    public void endElement(ElementInfo e) throws SAXException {
      ElementInfo prevSib;
      int numberOfCloseParens=0;

      e.write("</popup>");
      prevSib = e.getPreviousSibling();
      while(prevSib!=null) {
	if(prevSib.getTag().equals("SET-OF") ||
	   prevSib.getTag().equals("INST-OF") ||
	   prevSib.getTag().equals("SPEC-OF")) {
	  numberOfCloseParens++;
	}
	prevSib = prevSib.getPreviousSibling();
      }
      for(int count=0; count<numberOfCloseParens; count++) {
	e.write(")");
      }
    }
  }

  class relationNameHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      e.write("<popup type=\"Relation\">");
    }
    public void endElement(ElementInfo e) throws SAXException {
      e.write("</popup> ");
    }
  }

  class instanceNameHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      e.write("<popup type=\"Instance\">");
    }
    public void endElement(ElementInfo e) throws SAXException {
      e.write("</popup> ");
    }
  }

  class variableNameHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
    }
    public void endElement(ElementInfo e) throws SAXException {
      e.write(" ");
    }
  }

  class methodGoalArgumentHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      e.write("(");
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
      AttributeList thisAL = e.getAttributeList();
      String tempValue = thisAL.getValue(0);
      if(tempValue.equals("IS") || tempValue.equals("INST") ||
	 tempValue.equals("DESC")) {
	e.write(tempValue+" ");
      } else if(tempValue.equals("SET-OF") || tempValue.equals("INST-OF") ||
		tempValue.equals("SPEC-OF")) {
	e.write("("+thisAL.getValue(0)+" ");
      }
    }
    public void endElement(ElementInfo e) throws SAXException {
    }
  }

  class edtHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      AttributeList thisAL = e.getAttributeList();
      if(e.getParent().getTag().equals("methodGoalArgument")) {
	e.write(thisAL.getValue(0)+" ");
      } else {
	e.write("("+thisAL.getValue(0)+" ");
      }
    }
    public void endElement(ElementInfo e) throws SAXException {
    }
  }

  class methodResultHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      super.startElement(e);
      e.write("<"+headingSizes[METHODRESULT]+">Result Type: </"+headingSizes[METHODRESULT]+"><br>\n");
    }
    public void endElement(ElementInfo e) throws SAXException {
      e.write("<br>\n");
    }
  }
    
  /*
   * passiveActionHandler simply understands that a tag has been
   * encountered but does nothing useful about it.
   */
  class passiveActionHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
    }
    public void endElement(ElementInfo e) throws SAXException {
    }
  }

  class goalFormHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      e.write("(");
    }
    public void endElement(ElementInfo e) throws SAXException {
      e.write(")<br>\n");
    }
  }

  class goalParameterHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      super.startElement(e);
      if(e.getParent().getTag().equals("GoalForm"))
	super.startElement(e);
      e.write("(");
    }
    public void endElement(ElementInfo e) throws SAXException {
      e.write(")<br>\n");
    }
  }

  class expressionHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
    }
    public void endElement(ElementInfo e) throws SAXException {
    }
  }

  class superMHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      super.startElement(e);
      e.write("\n<P><"+headingSizes[SUPERMETHOD]+">Methods that subsume this method:</"+headingSizes[SUPERMETHOD]+"></P><br>\n");
      e.write("<TT>\n");
    }
    public void endElement(ElementInfo e) throws SAXException {
      if(getEmptyArray(superMethodEmpty)) {
	e.write("None\n");
      }
      e.write("</TT>\n");
    }
  }

  class subMetHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      super.startElement(e);
      e.write("\n<P><"+headingSizes[SUBMETHOD]+">Methods subsumed by this method:</"+headingSizes[SUBMETHOD]+"></P><br>\n");
      e.write("<TT>\n");
    }
    public void endElement(ElementInfo e) throws SAXException {
      if(getEmptyArray(subMethodEmpty)) {
	e.write("None\n");
      }
      e.write("</TT>\n");
    }
  }
  
  class RefPSNHandler extends NSElementCopier {
    private boolean tree = true;
    public void startElement(ElementInfo e) throws SAXException {
      super.startElement(e);
      e.write("\n<P><"+headingSizes[REFERRINGPSNODES]+"> PS nodes that refer to this method:</"+headingSizes[REFERRINGPSNODES]+"><br>\n");
      if (e.getAttribute("STATUS").equals("NOTREE")) {
	tree = false; 
	} else {
	tree = true;
	}
      if(!tree) e.write("No PS tree available.");
    }
    public void endElement(ElementInfo e) throws SAXException {
      if(getEmptyArray(RefPSNodesEmpty) && tree) {
	 e.write("None ");
	 }
      e.write("</P>\n");
    }
  }

  class RefEXNHandler extends NSElementCopier {
    private boolean tree = true;
    public void startElement(ElementInfo e) throws SAXException {
      super.startElement(e);
      e.write("\n<P><"+headingSizes[REFERRINGEXENODES]+"> EXE nodes that refer to this method:</"+headingSizes[REFERRINGEXENODES]+"><br>\n");
      if (e.getAttribute("STATUS").equals("NOTREE")) {
	tree = false; 
	} else {
	tree = true;
	}
      if(!tree) e.write("No EXE tree available");
    }
    public void endElement(ElementInfo e) throws SAXException {
      if(getEmptyArray(RefEXENodesEmpty) && tree) {
	 e.write("None ");
	 }
      e.write("</P>\n");
    }
  }

  class RefAGIHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      super.startElement(e);
      e.write("\n<P><"+headingSizes[REFERRINGAGENDAIT]+">Agenda items that refer to this method:</"+headingSizes[REFERRINGAGENDAIT]+"></P><br>\n");
      e.write("<TT>\n");
    }
    public void endElement(ElementInfo e) throws SAXException {
      if(getEmptyArray(RefAgendaItemEmpty)) {
	e.write("None\n");
      }
      e.write("</TT>\n");
    }
  }

  class RefGRPHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      super.startElement(e);
      e.write("<P><"+headingSizes[REFERRINGGROUPS]+">Groups that this method belongs to:</"+headingSizes[REFERRINGGROUPS]+"></P><br>\n");
      e.write("<TT>\n");
    }
    public void endElement(ElementInfo e) throws SAXException {
      if(getEmptyArray(RefGroupsEmpty)) {
	e.write("None\n");
      }
      e.write("</TT>\n");
    }
  }

  class RefMACHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      super.startElement(e);
      e.write("\n<P><"+headingSizes[REFERRINGMACROCMP]+">Macrocomponents that this method belongs to:</"+headingSizes[REFERRINGMACROCMP]+"></P><br>\n");
      e.write("<TT>\n");
    }
    public void endElement(ElementInfo e) throws SAXException {
      if(getEmptyArray(RefAgendaItemEmpty)) {
	e.write("None\n");
      }
      e.write("</TT>\n");
    }
  }

  class methodHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      e.write("<popup type=\"Method\">");
    }
    public void endElement(ElementInfo e) throws SAXException {
      e.write("</popup><br>");
    }
  }

  class metBodyHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      super.startElement(e);
      e.write("\n<P><"+headingSizes[METHODBODY]+">Method Body:</"+headingSizes[METHODBODY]+"></P><br>\n");
      e.write("<TT>\n");
    }
    public void endElement(ElementInfo e) throws SAXException {
      e.write("</TT>\n");
    }
  }

}




