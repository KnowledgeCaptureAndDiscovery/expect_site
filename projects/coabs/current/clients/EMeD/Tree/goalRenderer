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

public class messageListRenderer extends renderer {
  expandableTreeNode top = new expandableTreeNode(); 
  private expandableTreeModel treeModel;
  String messages = "";
  String errorType;
  String collectionType;
  String collectionDescription;
  public messageListRenderer(String response) {
    treeModel = new expandableTreeModel(top);
    setHandler("error-group", new groupErrorHandler());
    setHandler("related-errors", new relatedErrorHandler());
    setHandler("agenda", new agendaHandler());
    setHandler("agenda-list", new agendaListHandler());
    setHandler("solution", new solutionHandler());
    setHandler("solution-list", new solutionListHandler());

    setHandler("error", new errorHandler());
    setHandler("result", new errorHandler());
    int result = runFromNamedParser(new InputSource(new StringReader(response)), 
				    "com.ibm.xml.parser.SAXDriver");

  }



  public expandableTreeNode getMessagesAsTreeNode() {
    // put nodes in order based on source problem
    if (top.getChildCount()>0) 
      top.setUserObject("<Warnings>\n------------------\nRed: Warning\nBlue: Proposed Fixes\n------------------");
    else top.setUserObject("<Warnings>");
    return top;
  }
  public String getMessagesAsString() {
    return messages;
  }

  
  class errorHandler extends ElementHandlerBase {
    public void startElement (ElementInfo e) throws SAXException  {
      errorType = e.getAttribute("type");
    }
    public void characters(ElementInfo e, char ch[], int start, int length) throws SAXException {
      String contents = new String(ch,start,length);
      messages = messages +"\n "+ contents;
      expandableTreeNode node = new expandableTreeNode();
      node.setUserObject(contents);
      treeModel.insertNodeInto(node, top, 0);
    }
 
  }

  class groupErrorHandler extends ElementHandlerBase {
    public void startElement (ElementInfo e) throws SAXException  {
      collectionType = e.getAttribute("type");
      collectionDescription = e.getAttribute("description");
      //String sourceName = e.getAttribute("name");
      //String packageName = e.getAttribute("package");
      expandableTreeNode node = new expandableTreeNode();
      node.setUserObject(removeExtraSpace(collectionDescription)); 
      node.setID(collectionDescription);
      node.setType(collectionType);
      //node.setPackage(packageName); // server package name
      treeModel.insertNodeInto(node, top, 0);
      e.setUserData (node);
    }
  }

  class relatedErrorHandler extends ElementHandlerBase {
    public void startElement (ElementInfo e) throws SAXException  {
      collectionType = e.getAttribute("type");
      collectionDescription = e.getAttribute("text");
      String sourceName = e.getAttribute("name");
      //String packageName = e.getAttribute("package");
      expandableTreeNode node = new expandableTreeNode();
      node.setUserObject(removeExtraSpace(collectionDescription)); 
      node.setID(sourceName);
      node.setType(collectionType);
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
  class agendaHandler extends ElementHandlerBase {
    String agendaID;
    String description;
    public void startElement (ElementInfo e) throws SAXException  {
      agendaID = e.getAttribute("agenda-id");
      description = removeExtraSpace(e.getAttribute ("text"));
      //System.out.println("org agenda:"+e.getAttribute ("text"));
      description = description.replace('#','\n');
      //System.out.println("agenda:"+description);
      expandableTreeNode node = new expandableTreeNode();
      node.setUserObject(description);
      node.setID(agendaID);
      ElementInfo parentElement = e.getParent();
      expandableTreeNode parent = (expandableTreeNode)parentElement.getUserData();
      parent.add(node);
      e.setUserData(node);
    }
  }

  class agendaListHandler extends ElementHandlerBase {
    public void startElement (ElementInfo e) throws SAXException  {
      ElementInfo parentElement = e.getParent();
      expandableTreeNode parent = (expandableTreeNode)parentElement.getUserData();
      e.setUserData (parent);
    }
  }
 
  class solutionHandler extends ElementHandlerBase {
    String packageName;
    String solutionType;
    String name;
    public void startElement (ElementInfo e) throws SAXException  {
      packageName = e.getAttribute("package");
      solutionType = e.getAttribute("solution-type");
      name = e.getAttribute("name");
    }
    public void characters(ElementInfo e, char ch[], int start, int length) throws SAXException {
      String description = removeExtraSpace(new String(ch,start,length));
      //System.out.println(solutionType+":"+description+"|");
      expandableTreeNode node = new expandableTreeNode();
      node.setUserObject("== " + description);
      node.setID(packageName+"::"+name);
      node.setType(solutionType);
      ElementInfo parentElement = e.getParent();
      expandableTreeNode parent = (expandableTreeNode)parentElement.getUserData();
      parent.add(node);
    }
  }
  class solutionListHandler extends ElementHandlerBase {
    public void startElement (ElementInfo e) throws SAXException  {
      ElementInfo parentElement = e.getParent();
      expandableTreeNode parent = (expandableTreeNode)parentElement.getUserData();
      e.setUserData (parent);
    }
  }
 
  
}
