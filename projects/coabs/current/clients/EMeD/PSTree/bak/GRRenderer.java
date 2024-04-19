package PSTree;

import java.util.*;
import java.net.*;
import java.io.*;
import java.awt.*;
import java.awt.event.*;
import javax.swing.event.*;
import javax.swing.text.*;
import javax.swing.tree.*;
import javax.swing.*;
import com.icl.saxon.*;
import org.xml.sax.*;
import org.xml.sax.helpers.*;

import Tree.expandableTreeNode;
import Tree.expandableTree;
import Tree.renderer;
import Connection.*;
public class GRRenderer extends renderer {
  static public final Color newMethodColor= new Color (160,120,20);

  expandableTreeNode top = new expandableTreeNode("Root"); 
  PrintStream o = System.err;
  expandableTreeNode currentParent;
  expandableTree tree;
  Stack nodeStack = new Stack();
  ExpectSocketAPI es;
  private GRObject data;
  private String resultDesc;

 public GRRenderer (String xmlInput, ExpectSocketAPI theServer) {  
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
      System.out.println("started a node1");
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
    public void endElement(ElementInfo e) throws SAXException {
      System.out.println("ended a node");
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
      System.out.println("start a goal info");
      boolean undefinedMethodNode = false;
      ElementInfo parentElement = e.getParent();

      expandableTreeNode node = (expandableTreeNode)parentElement.getUserData();
      String nodeID = e.getAttribute("name").trim();
      String packageName = e.getAttribute("package").trim();

      if (nodeID.equals("NIL") || nodeID == null) nodeID = "";
      else nodeID = packageName+"::"+nodeID;
      String goalDesc = removeExtraSpace(e.getAttribute("desc"));
      goalDesc = goalDesc.trim();
      String capabilityContent = removeExtraSpace(e.getAttribute("capability"));
      String simpleCapContent = removeExtraSpace(e.getAttribute("simplified-capability"));
      String bodyContent = removeExtraSpace(e.getAttribute("body"));
      String bodyDesc = removeExtraSpace(e.getAttribute("body-desc"));
      

      String expectedResult = removeExtraSpace(e.getAttribute("result"));
      String systemProposedName = removeExtraSpace(e.getAttribute("system-proposed-name"));
      String highlightResult = removeExtraSpace(e.getAttribute("highlight-result"));
      String usingNewMethod = removeExtraSpace(e.getAttribute("using-new-method"));
      String expandNode = removeExtraSpace(e.getAttribute("expand"));

      //System.out.println("node:"+nodeID);
      //System.out.println("usingNewMethod:"+usingNewMethod+"|");
      //System.out.println("expandNode:"+expandNode+"|");

      resultDesc = "";
      data = new GRObject();
      if (!expandNode.equals("t")) data.setExpand(false);
      if (usingNewMethod.equals("t")) data.setColor (newMethodColor);
      //String possibleUsers = removeExtraSpace(e.getAttribute("possible-users"));
      //o.println(" possible-users####:" + possibleUsers+"|");
      String edt = removeExtraSpace(e.getAttribute("edt"));
      //String subgoals = removeExtraSpace(e.getAttribute("subgoals"));
      if (nodeID != null) node.setID(nodeID);
      //if (bodyContent != null) node.setUserObject(bodyContent); 
      //o.println(" nodeID:" + nodeID+"|");
      String nodeContent;
      if (nodeID == null || nodeID.equals("") ||
	   bodyDesc.equals("set") || 
	   bodyDesc.equals("covering-or-input")) {
	if (bodyDesc.equals("set")) bodyDesc = "satisfy this for each item";
	else bodyDesc = "satisfy all the followings to cover different cases";
        //o.println(" nodeID:" + nodeID+"|");
	  if (nodeID.equals("")) nodeContent = "Root         ";
	  else { // non method nodes
	      nodeContent = "{An alternative for the undefined method: "+goalDesc+"\n reformulate ------ "+bodyDesc;
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
	  nodeContent = "[UNDEFINED:     "+goalDesc;
	  node.setID(systemProposedName);
	  undefinedMethodNode = true;
        }
        nodeContent = nodeContent+"\n"+capabilityContent;
        if (bodyDesc != null && (!bodyDesc.equals("")) && 
	    (!bodyDesc.equals(" ")) &&(!bodyDesc.equals(" primitive"))) {// primitive methods don't have body 
	  //bodyDesc = bodyDesc.replace('#','\n');
	  //System.out.println("body-desc:"+bodyDesc);
	  nodeContent = nodeContent+"\n How: "+bodyDesc;
	  if (!bodyContent.equals(bodyDesc)) {
	    nodeContent = nodeContent+"\n           "+bodyContent;
	  }
	}
        if (highlightResult =="") {
	  if (!expectedResult.equals(edt)) {
	    if (undefinedMethodNode) {
	      resultDesc = resultDesc +"\n Expected-Result:  "+expectedResult;
	      resultDesc = resultDesc +"\n Expected Result:  "+es.getNLOfDataType(expectedResult);
	    }
	    else resultDesc = resultDesc +"\n Result-Declared:  "+expectedResult;
	  }
	  if (!edt.equals("")) resultDesc = resultDesc +"\n Result-Obtained: "+edt;
        }
        else {
	  resultDesc = resultDesc +"\n Result-DECLARED:  "+expectedResult;
	  if (!edt.equals("")) resultDesc = resultDesc +"\n Result-OBTAINED: "+edt;
        }

      }
      //System.out.println("nodeID"+nodeID);
      // node.setUserObject(nodeContent);
      data.setContent(nodeContent);
      //System.out.println("set:"+nodeContent);
      node.setUserObject (data);
    }
    public void endElement (ElementInfo e) throws SAXException  {

      ElementInfo parentElement = e.getParent();
      expandableTreeNode node = (expandableTreeNode)parentElement.getUserData();
      //String nodeContent = (String) node.getUserObject();
      GRObject data = (GRObject) node.getUserObject();
      String nodeContent = data.getContent();
      if (nodeContent.startsWith("["))
	nodeContent = nodeContent + resultDesc + "\n]";
      else if (nodeContent.startsWith("{"))
        nodeContent = nodeContent + resultDesc + "\n}";
      data.setContent (nodeContent);
      System.out.println("a goal info:"+nodeContent);
      node.setUserObject(data);
      System.out.println("finished");
    }
  }


  private class subgoalHandler extends NSElementHandlerBase {
    public void characters (ElementInfo e, char ch[], int start, int length) throws SAXException {
      String contents = new String(ch,start,length);
      ElementInfo parentElement = e.getParent().getParent();
      expandableTreeNode node;

      node = (expandableTreeNode)parentElement.getUserData();
      //String goalInfo = (String)node.getUserObject();
      GRObject data = (GRObject) node.getUserObject();
      String goalInfo = data.getContent();
      String subgoalInfo = removeExtraSpace(contents.replace('\n',' '));
      //node.setUserObject(goalInfo +"\n       subgoal:  "+subgoalInfo);
      data.setContent(goalInfo +"\n       subgoal:  "+subgoalInfo);
      //System.out.println("set:"+data.getContent());
      node.setUserObject(data);
      // o.println(" set user data for node:" + goalInfo +"\n  subgoal:  "+subgoalInfo);
    }
  }
 
  private class possibleUserHandler extends NSElementHandlerBase {
    public void characters (ElementInfo e, char ch[], int start, int length) throws SAXException {
      String contents = new String(ch,start,length);
      ElementInfo parentElement = e.getParent().getParent();
      expandableTreeNode node;

      node = (expandableTreeNode)parentElement.getUserData();
      //String goalInfo = (String)node.getUserObject();
      GRObject data = (GRObject) node.getUserObject();
      String goalInfo = data.getContent();
      String possibleUserInfo = removeExtraSpace(contents);
      data.setContent(goalInfo+"\n Potential Child");
      //System.out.println("set:"+data.getContent());
      node.setUserObject(data);
      //node.setUserObject(goalInfo+"\n Potential Child");
     
      //String goalDesc = es.getNLOfCapability("",contents.trim());
      //node.setUserObject(goalInfo +"\n Potential-User:  "+goalDesc.trim());

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


}
  
