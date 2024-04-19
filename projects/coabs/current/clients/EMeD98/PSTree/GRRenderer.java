package PSTree;

import java.util.*;
import java.net.*;
import java.io.*;
import java.awt.*;
import java.awt.event.*;
import java.awt.BorderLayout;
import java.awt.Color;
import java.awt.Dimension;
import java.awt.FlowLayout;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.WindowAdapter;
import java.awt.event.WindowEvent;
import com.sun.java.swing.event.*;
import com.sun.java.swing.text.*;
import com.sun.java.swing.tree.*;
import com.sun.java.swing.*;
import com.icl.saxon.*;
import org.xml.sax.*;
import org.xml.sax.helpers.*;

import Tree.expandableTreeNode;
import Tree.expandableTree;
import Connection.ExpectServer;

public class GRRenderer extends Distributor {

  Parser parser;
  Locator locator;
  expandableTreeNode top = new expandableTreeNode("Root"); 
  PrintStream o = System.err;
  expandableTreeNode currentParent;
  expandableTree tree;
  Stack nodeStack = new Stack();
  ExpectServer es;
  private String resultDesc;
  public GRRenderer (String xmlInput, ExpectServer theServer) {  
    prepare();
    es = theServer;
    runFromNamedParser(new InputSource(new StringReader(xmlInput)), 
		       "com.ibm.xml.parser.SAXDriver");
    tree = new expandableTree(top);
  }
  
  public expandableTree getTree() {
    return tree;
  }
  public Stack getNodeStack() {
    return nodeStack;
  }

  public void prepare () {
    setHandler("NODE", new nodeHandler());
    setHandler("NAME", new nameHandler());
    setHandler("method", new nameHandler());
    setHandler("goalNode", new nameHandler());
    setHandler("methodNode", new nameHandler());
    setHandler("goalInfoNode", new goalInfoHandler());
    setHandler("subgoal", new subgoalHandler());
    setHandler("possible-user", new possibleUserHandler());
  }
  
    class NSElementHandlerBase extends ElementHandlerBase {
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
  
  private class nodeHandler extends NSElementHandlerBase
   {
    public void startElement(ElementInfo e) throws SAXException {
      expandableTreeNode currentNode = new expandableTreeNode();
      expandableTreeNode parentNode;
      
      e.setUserData(currentNode);
      if (e.isRoot()) {
        top = currentNode;
	//tree = new expandableTree(top);
      } else {
        parentNode = (expandableTreeNode)e.getParent().getUserData();
        parentNode.add(currentNode);
      }
    }

  }

  boolean defined = false;
  private class nameHandler extends NSElementHandlerBase {
    public void startElement (ElementInfo e) throws SAXException  {
      ElementInfo parentElement = e.getParent();
      //      currentParent = node;

      expandableTreeNode node = (expandableTreeNode)parentElement.getUserData();
      String nodeID = e.getAttribute("name");
      String definedP = e.getAttribute("defined-p");
      if (null== definedP || definedP.startsWith("NIL"))
	defined = false;
      else defined = true;
      if (nodeID != null) node.setID(nodeID.trim());
    }
    
    public void characters (ElementInfo e, char ch[], int start, int length) throws SAXException {
      String contents = new String(ch,start,length);
      ElementInfo parentElement = e.getParent();
      expandableTreeNode node;
      node = (expandableTreeNode)parentElement.getUserData();

      String name = node.getID();
      if (defined) {
	node.setUserObject("CAPABILITY:"+removeExtraSpace(contents));
	//tree.expandPath(tree.findPath(node));
      }
      else if (name.equals("SYSTEM")) {
	node.setUserObject("SYSTEM    :"+removeExtraSpace(contents));
	nodeStack.push (node);
      }
      else if (name == null||name.equals("NIL"))
	node.setUserObject(removeExtraSpace(contents));
      else node.setUserObject("UNDEFINED:"+removeExtraSpace(contents));
      //o.println(" set user data for node:" + contents);
      //o.println(" id of the node:" + node.getID());
    }
  }

  // for method relation tree
  private class goalInfoHandler extends NSElementHandlerBase {
    public void startElement (ElementInfo e) throws SAXException  {
      ElementInfo parentElement = e.getParent();
      //      currentParent = node;

      expandableTreeNode node = (expandableTreeNode)parentElement.getUserData();
      String nodeID = e.getAttribute("name").trim();
      if (nodeID.equals("NIL")) nodeID = "";
      String goalDesc = removeExtraSpace(e.getAttribute("desc"));
      goalDesc = goalDesc.trim();
      String capabilityContent = removeExtraSpace(e.getAttribute("capability"));
      String simpleCapContent = removeExtraSpace(e.getAttribute("simplified-capability"));
      String bodyContent = removeExtraSpace(e.getAttribute("body"));
      String bodyDesc = removeExtraSpace(e.getAttribute("body-desc"));
      String expectedResult = removeExtraSpace(e.getAttribute("result"));
      String systemProposedName = removeExtraSpace(e.getAttribute("system-proposed-name"));
      String highlightResult = removeExtraSpace(e.getAttribute("highlight-result"));
      resultDesc = "";
      //String possibleUsers = removeExtraSpace(e.getAttribute("possible-users"));
      //o.println(" possible-users####:" + possibleUsers+"|");
      String edt = removeExtraSpace(e.getAttribute("edt"));
      //String subgoals = removeExtraSpace(e.getAttribute("subgoals"));
      if (nodeID != null) node.setID(nodeID.trim());
      //if (bodyContent != null) node.setUserObject(bodyContent); 
      //o.println(" nodeID:" + nodeID+"|");
      String nodeContent;
      if (nodeID == null || nodeID.equals("") ||
	   goalDesc.equals("set") || 
	   goalDesc.equals("covering-or-input")) {
        //o.println(" nodeID:" + nodeID+"|");
	  if (nodeID.equals("")) nodeContent = "Root         ";
	  else { // non method nodes
	      nodeContent = "{Capability:        "+simpleCapContent+"\n rfml:                    "+goalDesc;
	      if ((!expectedResult.equals("UNDEFINED")) &&
		  (!expectedResult.equals(edt))) 
		  resultDesc = resultDesc +"\n  Result-Declared: "+expectedResult;

	      if (!edt.equals("")) 
		  resultDesc = resultDesc+"\n Result-Obtained: "+edt;
	  }
      }
      else {
        if (systemProposedName == "" || bodyContent != "") nodeContent = "["+goalDesc;
        else { 
	nodeContent = "[UNDEFINED method:     "+goalDesc;
	node.setID(systemProposedName);
        }
        nodeContent = nodeContent+"\n"+capabilityContent;
        if (bodyContent != null && (!bodyContent.equals(""))) {// primitive methods don't have body 
	  nodeContent = nodeContent+"\n Body: ";
	  if (!bodyDesc.equals("")) 
	    nodeContent = nodeContent+bodyDesc; // added for clarity
	  if (!bodyContent.equals(bodyDesc)) {
	    if (!bodyDesc.equals("")) nodeContent = nodeContent+"\n           ";
	    nodeContent = nodeContent+bodyContent;
	  }
	}
        if (highlightResult =="") {
	  if (!expectedResult.equals(edt)) 
	    resultDesc = resultDesc +"\n Result-Declared:  "+expectedResult;
	  if (!edt.equals("")) resultDesc = resultDesc +"\n Result-Obtained: "+edt;
        }
        else {
	  resultDesc = resultDesc +"\n Result-DECLARED:  "+expectedResult;
	  if (!edt.equals("")) resultDesc = resultDesc +"\n Result-OBTAINED: "+edt;
        }

      }
      //System.out.println("nodeID"+nodeID);
      node.setUserObject(nodeContent);

    }
    public void endElement (ElementInfo e) throws SAXException  {
      ElementInfo parentElement = e.getParent();
      expandableTreeNode node = (expandableTreeNode)parentElement.getUserData();
      
      if (((String) node.getUserObject()).startsWith("["))
	node.setUserObject((String) node.getUserObject() + resultDesc + "\n]");
      else if (((String) node.getUserObject()).startsWith("{"))
        node.setUserObject((String) node.getUserObject() + resultDesc + "\n}");
      
    }
  }


  private class subgoalHandler extends NSElementHandlerBase {
    public void characters (ElementInfo e, char ch[], int start, int length) throws SAXException {
      String contents = new String(ch,start,length);
      ElementInfo parentElement = e.getParent().getParent();
      expandableTreeNode node;

      node = (expandableTreeNode)parentElement.getUserData();
      String goalInfo = (String)node.getUserObject();
      String subgoalInfo = removeExtraSpace(contents);
      node.setUserObject(goalInfo +"\n       subgoal:  "+contents);
      // o.println(" set user data for node:" + goalInfo +"\n  subgoal:  "+contents);
    }
  }
 
  private class possibleUserHandler extends NSElementHandlerBase {
    public void characters (ElementInfo e, char ch[], int start, int length) throws SAXException {
      String contents = new String(ch,start,length);
      ElementInfo parentElement = e.getParent().getParent();
      expandableTreeNode node;

      node = (expandableTreeNode)parentElement.getUserData();
      String goalInfo = (String)node.getUserObject();
      String possibleUserInfo = removeExtraSpace(contents);
      int subGoalIdx = possibleUserInfo.indexOf("\n");
      if (subGoalIdx > 0) {// if the subgoal is known
        //node.setUserObject(goalInfo +"\n Potential-User:  "+possibleUserInfo.substring(0,subGoalIdx) + "\n                             "+ possibleUserInfo.substring(subGoalIdx+1));
	node.setUserObject(goalInfo+"\n Potential Child");
      }
      else {
        //node.setUserObject(goalInfo +"\n Potential-User:  "+possibleUserInfo);
	node.setUserObject(goalInfo+"\n Potential Child");
      }
      //String goalDesc = es.getNLOfCapability("",contents.trim());
      //node.setUserObject(goalInfo +"\n Potential-User:  "+goalDesc.trim());

      //System.out.println("==desc|"+goalDesc+"|");
    }
  }
 
  private class conceptHandler extends nameHandler {
    public void endElement (ElementInfo e) throws SAXException  {
      ElementInfo parentElement = e.getParent();
      //      currentParent = node;
    }
    
  }

  public String removeExtraSpace(String input) {
    String result = "";
    int i;
    boolean space = false;
    if (input == null) return "";
    for (i=0; i<input.length();i++) {
      if (input.charAt(i) == ' ') {
	if (!space) {
	  result = result + input.substring(i,i+1);
	  space = true;
	}
      }
      else {
	space = false;
	result = result + input.substring(i,i+1);
      }
      
    }
    if (result.equals(" NIL ")) return " ROOT   ";
    else {
      //System.out.println("Content:"+result+"|");
      if (result.equals("NIL")) return "";
      if (result.equals("UNDEFINED")) return result;
      //return result.toLowerCase()+"  ";
      return result.toLowerCase();
    }
  }
 
  public void drawTree() {
          JFrame frame = new JFrame("Method Tree");
 
      frame.addWindowListener(new WindowAdapter() {
        public void windowClosing(WindowEvent e) {
                  System.exit(0);
        }
      });
      frame.getContentPane().add("Center", new JScrollPane(tree));
      frame.setSize(400, 300);
      frame.setVisible(true);

  }

  private int runFromNamedParser(InputSource in, String parserClassName) {            
    // Create a new parser instance 
    parser = ParserManager.makeParser(parserClassName);
    if (parser!=null)
      parser.setDocumentHandler(this);
    else {
      try {
        o.println("No XML Parser established\n");
      } catch (Exception e) {}
      return(4);
    }
    try {
      parser.parse(in);           // this is the real work!
      return(0);
    }
    catch (java.io.IOException e) {
      try {
        o.println("Input/Output error during parsing\n");
        o.println("Details: " + e.getMessage() + "\n");
      } catch (Exception e2) {}
      return(3);
    }
    catch (SAXException e) {
      try {
        o.println("Unable to parse XML document\n");
        o.println("Problem: " + e.getMessage() + "\n");
        if (locator!=null) {
	o.println("  URL:    " + locator.getSystemId() + "\n");
	o.println("  Line:   " + locator.getLineNumber() + "\n");
	o.println("  Column: " + locator.getColumnNumber() + "\n");
        }
      } catch (Exception e2) {};
      return(2);
    }   
  }

}
  
