package Tree;

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
import org.apache.xerces.parsers.*;

public class capOrgRenderer extends renderer {
  Parser parser;
  Locator locator;
  expandableTreeNode top = new expandableTreeNode("Root"); 
  PrintStream o = System.err;
  expandableTreeNode currentParent;
  expandableTree tree;


  public capOrgRenderer (String xmlInput) {  
    prepare();
    
    runFromNamedParser(new InputSource(new StringReader(xmlInput)), 
		       "com.ibm.xml.parser.SAXDriver");
    tree = new expandableTree(top);
  }
  
  public expandableTree getTree() {
    return tree;
  }


  public void prepare () {
    setHandler("NODE", new nodeHandler());
    setHandler("goalNode", new goalHandler());
  }
  

  
  private class nodeHandler extends ElementHandlerBase
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
  String desc;
  private class goalHandler extends ElementHandlerBase {
    public void startElement (ElementInfo e) throws SAXException  {
      ElementInfo parentElement = e.getParent();
      //      currentParent = node;

      expandableTreeNode node = (expandableTreeNode)parentElement.getUserData();
      String nodeID = e.getAttribute("name").trim();
      String packageName = e.getAttribute("package");
     
      if (packageName != null && (!nodeID.equals("SYSTEM")) &&
	  (!nodeID.equals("NIL"))) 
	nodeID = packageName.trim()+"::"+nodeID;
      String definedP = e.getAttribute("defined-p");
      desc = removeExtraSpace(e.getAttribute("desc"));
      if (null== definedP || definedP.startsWith("NIL"))
	defined = false;
      else defined = true;
      if (nodeID != null) node.setID(nodeID);
    }
    
    public void characters (ElementInfo e, char ch[], int start, int length) throws SAXException {
      String goal = new String(ch,start,length);
      goal = removeExtraSpace(goal.replace('\n',' '));

      ElementInfo parentElement = e.getParent();
      expandableTreeNode node;
      node = (expandableTreeNode)parentElement.getUserData();

      String name = node.getID();
      if (defined) {
	node.setUserObject(": "+desc);
      }
      else if (name.equals("SYSTEM")) {
	node.setUserObject(desc);
      }
      else if (name == null||name.equals("NIL"))
	node.setUserObject(desc);
      else {
	node.setUserObject("UNDEFINED: "+desc);
      }
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
  
