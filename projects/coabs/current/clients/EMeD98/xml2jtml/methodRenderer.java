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

  public static boolean RefPSNodesEmpty    = true;
  public static boolean RefEXENodesEmpty   = true;


  public final static int numberOfItems = METHODBODY+1;
  public static int currentNumOfTabs = 0;
  protected final int jtmlTabSize = 4;

  public static String headingSizes[] = new String[numberOfItems];
  public static String fontColors[] = new String[numberOfItems];
  public static boolean elementEmpty[] = new boolean[RefMacroCmpEmpty];
 
  public methodRenderer() {
    for(int i=0; i<numberOfItems; i++) {
      fontColors[i]="black";
      headingSizes[i]="H5";
    }
    headingSizes[METHODDESCRIPTION]="H4";
  }

  public static void setEmptyArray(int arrayIndex, boolean value) {
    if(arrayIndex>=0 && arrayIndex<RefMacroCmpEmpty) {
      elementEmpty[arrayIndex] = value;
    }
  }
  
  public static boolean getEmptyArray(int arrayIndex) {
    if(arrayIndex<0 || arrayIndex>RefMacroCmpEmpty) {
      System.out.println("Error: elementEmpty access on index out of bounds.");
      System.exit(1);
    }
    return elementEmpty[arrayIndex];
  }

  public String toHtml(String xmlString) {

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
      } else {}
      if(e.getAncestor("superMethods")!=null) {
	setEmptyArray(superMethodEmpty,false);
      } else if(e.getAncestor("subMethods")!=null) {
	setEmptyArray(subMethodEmpty,false);
      } else if(e.getAncestor("refAgendaItems")!=null) {
	setEmptyArray(RefAgendaItemEmpty,false);
      } else if(e.getAncestor("refGroups")!=null) {
	setEmptyArray(RefGroupsEmpty,false);
      } else if(e.getAncestor("refMacrocomponents")!=null) {
        setEmptyArray(RefMacroCmpEmpty,false);
      } else {}
      
      if(e.getAncestor("refPsnodes")!=null) {
	RefPSNodesEmpty = false;
	}
      if(e.getAncestor("refExenodes")!=null) {
	RefEXENodesEmpty = false;
	}
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
      e.write("<"+headingSizes[METHODDESCRIPTION]+">Description of this method: </"+headingSizes[METHODDESCRIPTION]+"><br>\n");
      e.write("<P>");
    }
    public void endElement(ElementInfo e) throws SAXException {
      e.write("</P><br>\n");
    }
  }

  class methodGoalHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      super.startElement(e);
      e.write("<"+headingSizes[METHODGOAL]+">METHOD GOAL(CAPABILITIES): </"+headingSizes[METHODGOAL]+"><br>\n");
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
      e.write("<"+headingSizes[METHODRESULT]+">RESULT(S) OF THIS METHOD: </"+headingSizes[METHODRESULT]+"><br>\n");
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
      e.write("<P><"+headingSizes[SUPERMETHOD]+">METHODS THAT SUBSUME THIS METHOD:</"+headingSizes[SUPERMETHOD]+"></P><br>\n");
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
      e.write("<P><"+headingSizes[SUBMETHOD]+">METHODS SUBSUMED BY THIS METHOD:</"+headingSizes[SUBMETHOD]+"></P><br>\n");
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
    public void startElement(ElementInfo e) throws SAXException {
      super.startElement(e);
      e.write("<P><"+headingSizes[REFERRINGPSNODES]+">PS NODES THAT REFER TO THIS METHOD:</"+headingSizes[REFERRINGPSNODES]+"></P><br>\n");
      AttributeList thisAL = e.getAttributeList();

      e.write("<TT>\n");
      if(thisAL.getValue(0).equals("NOTREE")) {
	e.write("No PS tree available");
      }
    }
    public void endElement(ElementInfo e) throws SAXException {
      if(RefPSNodesEmpty) {
	e.write("None ");
      }
      e.write("</TT>\n");
    }
  }

  class RefEXNHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      super.startElement(e);
      e.write("<P><"+headingSizes[REFERRINGEXENODES]+">EXE NODES THAT REFER TO THIS METHOD:</"+headingSizes[REFERRINGEXENODES]+"></P><br>\n");
      AttributeList thisAL = e.getAttributeList();

      e.write("<TT>\n");
      if(thisAL.getValue(0).equals("NOTREE")) {
	e.write("No EXE tree available");
      } 
    }
    public void endElement(ElementInfo e) throws SAXException {
      if(RefEXENodesEmpty) {
	e.write("None ");
      }
      e.write("</TT>\n");
    }
  }

  class RefAGIHandler extends NSElementCopier {
    public void startElement(ElementInfo e) throws SAXException {
      super.startElement(e);
      e.write("<P><"+headingSizes[REFERRINGAGENDAIT]+">AGENDA ITEMS THAT REFER TO THIS METHOD/GOAL:</"+headingSizes[REFERRINGAGENDAIT]+"></P><br>\n");
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
      e.write("<P><"+headingSizes[REFERRINGGROUPS]+">GROUPS THAT THIS METHOD BELONGS TO:</"+headingSizes[REFERRINGGROUPS]+"></P><br>\n");
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
      e.write("<P><"+headingSizes[REFERRINGMACROCMP]+">MACROCOMPONENTS THIS METHOD IS PART OF:</"+headingSizes[REFERRINGMACROCMP]+"></P><br>\n");
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
      e.write("<P><"+headingSizes[METHODBODY]+">METHOD BODY:</"+headingSizes[METHODBODY]+"></P><br>\n");
      e.write("<TT>\n");
    }
    public void endElement(ElementInfo e) throws SAXException {
      e.write("</TT>\n");
    }
  }

}




