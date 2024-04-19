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

public class goalRenderer extends renderer {
  expandableTreeNode top = new expandableTreeNode(); 
  private expandableTreeModel treeModel;
  String messages = "";
  String errorType;
  String collectionType;
  String collectionDescription;
  
  public goalRenderer(String response) {
    treeModel = new expandableTreeModel(top);
    setHandler("top-level-goal", new goalHandler());
    int result = runFromNamedParser(new InputSource(new StringReader(response)), 
				    "com.ibm.xml.parser.SAXDriver");

  }

public expandableTreeNode getMessagesAsTreeNode() {
    // put nodes in order based on source problem
    if (top.getChildCount()>0) 
      top.setUserObject("Top-Level-Goal");
    else top.setUserObject("");
    return top;
  }
  public String getMessagesAsString() {
    return messages;
  }


class goalHandler extends ElementHandlerBase {
    
    
    public void startElement (ElementInfo e) throws SAXException  {
     
      collectionDescription = removeExtraSpace(e.getAttribute ("text"));
      //System.out.println("org agenda:"+e.getAttribute ("text"));
      
      //System.out.println("agenda:"+description);
      //expandableTreeNode node = new expandableTreeNode();
      //node.setUserObject(description);
      //node.setID(description);
      /*ElementInfo parentElement = e.getParent();
      expandableTreeNode parent = (expandableTreeNode)parentElement.getUserData();
      parent.add(node);
      e.setUserData(node);*/
  }
  
  
  
  
  public void characters(ElementInfo e, char ch[], int start, int length) throws SAXException {
      String contents = new String(ch,start,length);
      messages = messages +"\n "+ contents;
      expandableTreeNode node = new expandableTreeNode();
      //commeneted now
      //node.setUserObject(contents);
      System.out.println("change :"+collectionDescription);
      node.setUserObject(collectionDescription);
      treeModel.insertNodeInto(node, top, 0);
    }
  
  
  
  }

  

  
}
