//File: methodListRenderer.java
//
// Copyright (C) 1998 by Jihie Kim
// All Rights Reserved

package Tree;

import java.io.*;
import java.util.*;
import com.icl.saxon.*;
import org.xml.sax.SAXException;
import org.xml.sax.AttributeList;
import org.xml.sax.InputSource;

import xml2jtml.methodDefRenderer;
import Connection.ExpectSocketAPI;
public class methodListRenderer extends renderer {
  private expandableTreeModel        treeModel;

  String xmlMethodList;  
  expandableTreeNode top;// = new expandableTreeNode("Method List"); 
  expandableTree tree;
  expandableTreeNode node;
  ExpectSocketAPI es;

  public methodListRenderer(ExpectSocketAPI server, String name) {
    es = server;

    top = new expandableTreeNode(name);
    treeModel = new expandableTreeModel(top);

    //treeModel = new expandableTreeModel(top);
    //tree = new expandableTree(treeModel);
    
  }
  
  public expandableTreeModel getTreeModel() {
    return treeModel;
  }
  
  public expandableTreeNode getRootOfMethodTree(String goalList) {

    setHandler ("name", new methodNameHandler());
    runFromNamedParser(new InputSource(new StringReader(goalList)), "com.ibm.xml.parser.SAXDriver");

    //System.out.println(" n of children:"+top.getChildCount());
    //expandableTreeNode n2 = (expandableTreeNode) top.getChildAt(0);
    //System.out.println(" *first child:"+(String) n2.getUserObject() +"|");
    return top;
  }


  class methodNameHandler extends ElementHandlerBase {
    public void startElement (ElementInfo e) throws SAXException  {
      expandableTreeNode currentNode = new expandableTreeNode();
      //top.add(currentNode);
      e.setUserData (currentNode);
    }

    public void characters(ElementInfo e, char ch[], int start, int length) throws SAXException {
      expandableTreeNode node= (expandableTreeNode) e.getUserData();
      String name = new String(ch,start,length);
      String messages = "";
      //System.out.println("get definitions for Method name:"+name+"|");

      methodDefRenderer defRenderer = new methodDefRenderer();
      String xmlDesc = es.getMethodDef(name);
      System.out.println("xml:"+xmlDesc+"|");
      String definition = "";
      if (null == xmlDesc) {
	System.out.println(" cannot find method :"+ name);
	node.setMessage("");
      }
      else {
        definition = defRenderer.toHtml(xmlDesc);
        //System.out.println ("definition:"+definition);
        xmlDesc = es.checkMethod(name);
        editResponseRenderer er = new editResponseRenderer (xmlDesc);
        messages = er.getMessages(true);
        node.setMessage(messages);
      }

      // added messages in user object to check if the node needs to be highlighted
      // in the cell renderer
      node.setUserObject(definition+"\nMESSAGES"+messages);
      node.setID(name);
      treeModel.insertNodeInto(node, top, 0);
    }
  }

}
