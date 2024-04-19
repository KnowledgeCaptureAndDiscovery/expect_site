package Tree;

import java.io.*;
import java.util.*;
import com.icl.saxon.*;
import org.xml.sax.SAXException;
import org.xml.sax.AttributeList;
import org.xml.sax.InputSource;
import com.sun.java.swing.tree.*;
import com.sun.java.swing.JTree;

public class messageListRenderer extends renderer {
  expandableTreeNode top = new expandableTreeNode("Message List"); 
  private expandableTreeModel treeModel;
  String messages = "";

  public messageListRenderer(String response) {
    treeModel = new expandableTreeModel(top);
    setHandler("error", new errorHandler());
    setHandler("result", new errorHandler());
    int result = runFromNamedParser(new InputSource(new StringReader(response)), 
				    "com.ibm.xml.parser.SAXDriver");

  }

  public expandableTreeNode getMessagesAsTreeNode() {
    return top;
  }
  public String getMessagesAsString() {
    return messages;
  }

  
  class errorHandler extends ElementHandlerBase {
    public void characters(ElementInfo e, char ch[], int start, int length) throws SAXException {
      String contents = new String(ch,start,length);
      messages = messages +"\n "+ contents;
      expandableTreeNode node = new expandableTreeNode();
      node.setUserObject(contents);
      treeModel.insertNodeInto(node, top, 0);
    }
 
  }
  
}
