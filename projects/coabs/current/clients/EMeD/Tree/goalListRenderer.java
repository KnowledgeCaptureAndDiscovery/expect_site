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

public class goalListRenderer extends renderer {
  expandableTreeNode top = new expandableTreeNode(); 
  private expandableTreeModel treeModel;
  String messages = "";
  String errorType;
  String collectionType;
  String collectionDescription;
  
  public goalListRenderer(String response) {
    treeModel = new expandableTreeModel(top);
    setHandler("top-level-goal-list", new goalHandler());
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

class groupErrorHandler extends ElementHandlerBase {
    public void startElement (ElementInfo e) throws SAXException  {
    messages = "Top Level Execution Goals List" + "\n";  
    }
  
  
  }


  class goalHandler extends ElementHandlerBase {
    public void startElement (ElementInfo e) throws SAXException  {
      //errorType = e.getAttribute("type");
    }
  
  public void characters(ElementInfo e, char ch[], int start, int length) throws SAXException {
      String contents = new String(ch,start,length);
      messages = messages +"\n "+ contents;
      expandableTreeNode node = new expandableTreeNode();
      node.setUserObject(contents);
      treeModel.insertNodeInto(node, top, 0);
    }
  
  
  
  }

  

  
}
