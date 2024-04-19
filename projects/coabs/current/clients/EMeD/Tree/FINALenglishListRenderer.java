package Tree;

import java.io.*;
import java.util.*;
import com.icl.saxon.*;
import org.xml.sax.SAXException;
import org.xml.sax.AttributeList;
import org.xml.sax.InputSource;
import javax.swing.tree.*;
import javax.swing.JTree;
import PSTree.*;

public class englishListRenderer extends renderer {
  expandableTreeNode top = new expandableTreeNode(); 
  private expandableTreeModel treeModel;
  String messages = "";
  String methodType;
  String collectionType;
  String collectionDescription;
  public englishListRenderer(String response) {
    treeModel = new expandableTreeModel(top);
    setHandler("all-methods-list", new allmethodsHandler());
    setHandler("name", new nameHandler());
    setHandler("capability", new capabilityHandler());
    setHandler("method-description", new descHandler());
    setHandler("method-result", new resultHandler());
    

    //setHandler("error", new errorHandler());
    //setHandler("result", new errorHandler());
    int result = runFromNamedParser(new InputSource(new StringReader(response)), 
				    "com.ibm.xml.parser.SAXDriver");

  }


public expandableTreeNode getMessagesAsTreeNode() {
    // put nodes in order based on source problem
  /*if (top.getChildCount()>0) 
      top.setUserObject("Methods");
    else */
    top.setUserObject("");
    return top;
  }
    
public String getMessagesAsString() {
    return messages;
  }
  class allmethodsHandler extends ElementHandlerBase {
    public void startElement (ElementInfo e) throws SAXException  {
      //collectionType = e.getAttribute("type");
      //collectionDescription = e.getAttribute("description");
      //String sourceName = e.getAttribute("name");
      //String packageName = e.getAttribute("package");
      expandableTreeNode node = new expandableTreeNode();
      node.setUserObject("Main Methods"); 
      //node.setID(collectionDescription);
      //node.setType(collectionType);
      //node.setPackage(packageName); // server package name
      treeModel.insertNodeInto(node, top, 0);
      e.setUserData (node);
    }
  }

  
  
  
  
  class nameHandler extends ElementHandlerBase {
    String description;
    public void startElement (ElementInfo e) throws SAXException  {
      description = removeExtraSpace(e.getAttribute ("text"));  
      expandableTreeNode node = new expandableTreeNode();
      node.setUserObject(description);
      node.setID(description);
      ElementInfo parentElement = e.getParent();
      expandableTreeNode parent = (expandableTreeNode)parentElement.getUserData();
      parent.add(node);
      e.setUserData(node);
       
    }
  }
  
  class capabilityHandler extends ElementHandlerBase {
    String agendaID;
    String description;
    public void startElement (ElementInfo e) throws SAXException  {
      //agendaID = e.getAttribute("agenda-id");
      description = removeExtraSpace(e.getAttribute ("text"));
      //System.out.println("org agenda:"+e.getAttribute ("text"));
      //description = description.replace('#','\n');
      //System.out.println("agenda:"+description);
      expandableTreeNode node = new expandableTreeNode();
      node.setUserObject("Capability: "+description);
      //node.setID(description);
      ElementInfo parentElement = e.getParent();
      expandableTreeNode parent = (expandableTreeNode)parentElement.getUserData();
      parent.add(node);
      e.setUserData(node);
    }
  }

  class descHandler extends ElementHandlerBase {
    String description;
    public void startElement (ElementInfo e) throws SAXException  {
      description = removeExtraSpace(e.getAttribute ("text"));
      expandableTreeNode node = new expandableTreeNode();
      node.setUserObject("Method: "+description);
      
       
      ElementInfo parentElement = e.getParent();
      expandableTreeNode parent = (expandableTreeNode)parentElement.getUserData();
      parent.add(node);
      e.setUserData(node);
    }
  }
 
  
  class resultHandler extends ElementHandlerBase {
    String description;
    public void startElement (ElementInfo e) throws SAXException  {
      description = removeExtraSpace(e.getAttribute ("text"));
      expandableTreeNode node = new expandableTreeNode();
      node.setUserObject("Result: "+description);
      ElementInfo parentElement = e.getParent();
      expandableTreeNode parent = (expandableTreeNode)parentElement.getUserData();
      parent.add(node);
      e.setUserData(node);
      
    }
  }
 
  
}
