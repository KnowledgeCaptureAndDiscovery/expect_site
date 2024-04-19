package Tree;

import java.io.*;
import java.util.*;
import com.icl.saxon.*;
import org.xml.sax.SAXException;
import org.xml.sax.AttributeList;
import org.xml.sax.InputSource;

import xml2jtml.methodDefRenderer;
import Connection.ExpectServer;

public class searchMethodsRenderer extends renderer {
  private expandableTreeModel        treeModel;

  expandableTreeNode top = new expandableTreeNode("Method List"); 
  expandableTree tree;
  expandableTreeNode node;
  ExpectServer es;

  public searchMethodsRenderer(ExpectServer server) {
    es = server;
    treeModel = new expandableTreeModel(top);
    tree = new expandableTree(treeModel);
    
  }

  public expandableTreeModel getTreeModel() {
    return treeModel;
  }

  public expandableTree getMethodsAsTree(String goalList) {

    setHandler ("name", new methodNameHandler());

    if (goalList !=null)
      runFromNamedParser(new InputSource(new StringReader(goalList)), "com.ibm.xml.parser.SAXDriver");

    /*
    node = new expandableTreeNode();
    methodDefRenderer defRenderer = new methodDefRenderer();
    String definition = defRenderer.toHtml(es.getMethodDef("narrow-gap"));
    node.setUserObject(definition);
    node.setID("narrow-gap");
    top.add(node);

    node = new expandableTreeNode();
    defRenderer = new methodDefRenderer();
    definition = defRenderer.toHtml(es.getMethodDef("get-dirt-volume"));
    node.setUserObject(definition);
    node.setID("get-dirt-volume");
    top.add(node);

    node = new expandableTreeNode();
    defRenderer = new methodDefRenderer();
    definition = defRenderer.toHtml(es.getMethodDef("emplace-AVLB-step"));
    node.setUserObject(definition);
    node.setID("emplace-AVLB-step");
    top.add(node);
    */

    return tree;
  }

  public expandableTree getMethodsAsModifiedTree(String goalList) {
    System.out.println("xmlInput:"+goalList);
    runFromNamedParser(new InputSource(new StringReader(goalList)), "com.ibm.xml.parser.SAXDriver");
    return tree;
  }

  public expandableTree destroyChildren() {
    //top.removeAllChildren();
    int NofChild = top.getChildCount();
    for (int i = 0; i < NofChild; i++) {
      expandableTreeNode node = (expandableTreeNode) top.getFirstChild();
      treeModel.removeNodeFromParent(node);
    }
    treeModel.nodeChanged(top);
    System.out.println(" Number of children 0?:"+ top.getChildCount());
    return tree;
  }

  class methodNameHandler extends ElementHandlerBase {

    public void characters(ElementInfo e, char ch[], int start, int length) throws SAXException {

      String name = new String(ch,start,length);

      //System.out.println("Method name:"+name+"|");

      methodDefRenderer defRenderer = new methodDefRenderer();
      String definition = defRenderer.toHtml(es.getMethodDef(name));
      //System.out.println("Definition:"+definition+"|");
      expandableTreeNode node= new expandableTreeNode(definition);
      node.setID(name);
      expandableTreeNode top = (expandableTreeNode) (expandableTreeNode)treeModel.getRoot();
      treeModel.insertNodeInto(node, top, 0);
      System.out.println(" number of children:"+ top.getChildCount());
    }
  }

}
