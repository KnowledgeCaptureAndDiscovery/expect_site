package Tree;

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


public class treeRenderer extends Distributor {

  Parser parser;
  Locator locator;
  expandableTreeNode top = new expandableTreeNode("Root"); 
  PrintStream o = System.err;
  expandableTreeNode currentParent;
  expandableTree tree;

  public static void main (String args[]) throws java.lang.Exception {      
    
    // Check the command-line arguments.
    //if (args.length != 1) {
    //  System.err.println("Usage: java treeRenderer input-file >output-file");
    //  System.exit(1);
    //} 
    
    // Instantiate and run the application
    treeRenderer app = new treeRenderer("<NODE> <NAME>bridge</NAME>        <NODE> <NAME>military bridge</NAME>                 <NODE> <NAME>fixed bridge</NAME>                       <NODE> <NAME>military bridge</NAME>                           <NODE> <concept>guga</concept> </NODE>                          <NODE> <relation>guiga gaga</relation> </NODE>                       </NODE>                  </NODE>                <NODE> <NAME>floating bridge</NAME> </NODE>        </NODE>        <NODE> <NAME>civilian bridge</NAME> </NODE></NODE>");
    app.drawTree();  
  }
 
  /* 
  public treeRenderer (String filename) {  
    prepare();
    runFromNamedParser(new ExtendedInputSource(new File(filename)), "com.ibm.xml.parser.SAXDriver");
    tree = new expandableTree(top);
  }
  */

  public treeRenderer (String xmlInput) {  
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
    setHandler("NAME", new nameHandler());
    setHandler("concept", new conceptHandler());
    setHandler("relation", new nameHandler());
    setHandler("method", new nameHandler());
    setHandler("psnode", new nameHandler());
    setHandler("exenode", new nameHandler());
    setHandler("conceptNode", new conceptHandler());
    setHandler("relationNode", new nameHandler());
    setHandler("goalNode", new nameHandler());
    setHandler("methodNode", new nameHandler());
    setHandler("psnodeNode", new nameHandler());
    setHandler("exenodeNode", new nameHandler());
    //setHandler("goalInfoNode", new goalInfoHandler());
    //setHandler("subgoal", new subgoalHandler());
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
	node.setUserObject(":"+removeExtraSpace(contents));
	//node.setUserObject("CAPABILITY:"+removeExtraSpace(contents));
	//tree.expandPath(tree.findPath(node));
      }
      else if (name.equals("SYSTEM")) {
	node.setUserObject(removeExtraSpace(contents));
	//node.setUserObject("SYSTEM    :"+removeExtraSpace(contents));
      }
      else if (name == null||name.equals("NIL"))
	node.setUserObject(removeExtraSpace(contents));
      else node.setUserObject("UNDEFINED:"+removeExtraSpace(contents));
      //o.println(" set user data for node:" + contents);
      //o.println(" id of the node:" + node.getID());
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
    if (result.equals(" NIL ")) return " ROOT  ";
    else {
      //System.out.println("Content:"+result+"|");
      if (result.equals("NIL")) return "";
      if (result.equals("UNDEFINED")) return result;
      return result.toLowerCase()+"  ";
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
  
