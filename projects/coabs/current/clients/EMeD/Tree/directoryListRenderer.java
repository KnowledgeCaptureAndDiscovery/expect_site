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

public class directoryListRenderer extends renderer {
  expandableTreeNode top = new expandableTreeNode(); 
  private expandableTreeModel treeModel;
  String messages = "";
  String errorType;
  String collectionType;
  String collectionDescription;
  public directoryListRenderer(String response) {
    treeModel = new expandableTreeModel(top);
    setHandler("directory-files", new directoryHandler());
    setHandler("file", new fileListHandler());
    
    int result = runFromNamedParser(new InputSource(new StringReader(response)), 
				    "com.ibm.xml.parser.SAXDriver");

  }



  public expandableTreeNode getMessagesAsTreeNode() {
    // put nodes in order based on source problem
    if (top.getChildCount()>0) 
      top.setUserObject("Directory");
    else top.setUserObject("");
    return top;
  }
  public String getMessagesAsString() {
    return messages;
  }

  
  
  class directoryHandler extends ElementHandlerBase {
    public void startElement (ElementInfo e) throws SAXException  {
      //collectionType = e.getAttribute("type");
      //collectionDescription = e.getAttribute("description");
      //String sourceName = e.getAttribute("name");
      //String packageName = e.getAttribute("package");
      expandableTreeNode node = new expandableTreeNode();
      node.setUserObject(""); 
      //node.setID(collectionDescription);
      //node.setType(collectionType);
      //node.setPackage(packageName); // server package name
      treeModel.insertNodeInto(node, top, 0);
      e.setUserData (node);
    }
  }

  class fileListHandler extends ElementHandlerBase {
    public void startElement (ElementInfo e) throws SAXException  {
      //collectionType = e.getAttribute("type");
      collectionDescription = e.getAttribute("text");
      //String sourceName = e.getAttribute("name");
      //String packageName = e.getAttribute("package");
      expandableTreeNode node = new expandableTreeNode();
      node.setUserObject(removeExtraSpace(collectionDescription)); 
      node.setID(collectionDescription);
      //node.setType(collectionType);
      //node.setPackage(packageName); // server package name
      //commeneted by Mukta
      /*treeModel.insertNodeInto(node, top, 0);
      e.setUserData (node);*/
      ElementInfo parentElement = e.getParent();
      expandableTreeNode parent = (expandableTreeNode)parentElement.getUserData();
      parent.add(node);
      e.setUserData(node);
       
    }
  }
  
 
  
}
