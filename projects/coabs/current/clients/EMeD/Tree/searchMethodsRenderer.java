package Tree;

import java.io.*;
import java.util.*;
import com.icl.saxon.*;
import org.xml.sax.SAXException;
import org.xml.sax.AttributeList;
import org.xml.sax.InputSource;

import xml2jtml.methodDefRenderer;
import Connection.ExpectSocketAPI;

public class searchMethodsRenderer extends renderer {
  private expandableTreeModel        treeModel;

  expandableTreeNode top = new expandableTreeNode("  Matched Capabilities"); 
  expandableTree tree;
  expandableTreeNode node;
  ExpectSocketAPI es;
  String inputRequest;
  Vector keywords = null;
  boolean potentialMatch = false;
  String topContent;

  public searchMethodsRenderer(ExpectSocketAPI server) {
    es = server;
    treeModel = new expandableTreeModel(top);
    tree = new expandableTree(treeModel);
    
  }

  public expandableTreeModel getTreeModel() {
    return treeModel;
  }

  public expandableTree getMethodsAsTree(String goalList) {

    setHandler ("name", new methodNameHandler());

    setHandler ("search-results", new initHandler());
    setHandler ("search-results-potential", new initPotentialHandler());
    setHandler ("keywords", new keywordsHandler());
    setHandler ("keyword", new keywordHandler());

    setHandler ("rfml", new rfmlHandler());
    setHandler ("rfml-result-item", new rfmlResultItemHandler());

    setHandler ("rfmls", new passiveHandler());
    setHandler ("rfml-results", new passiveHandler());
    if (goalList !=null)
      runFromNamedParser(new InputSource(new StringReader(goalList)), "com.ibm.xml.parser.SAXDriver");

    return tree;
  }

  public expandableTree getMethodsAsModifiedTree(String goalList, String input) {
    //System.out.println("xmlInput- getMethodsAsModifiedTree:"+goalList);
    inputRequest = input;
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
    //System.out.println(" Number of children 0?:"+ top.getChildCount());
    return tree;
  }

  class initHandler extends ElementHandlerBase {
    public void startElement (ElementInfo e) throws SAXException  {
     potentialMatch = false;
     keywords = null;
    }
   }
  class initPotentialHandler extends ElementHandlerBase {
    public void startElement (ElementInfo e) throws SAXException  {
     potentialMatch = true;
     keywords = null;
    }
   }

  class rfmlHandler extends ElementHandlerBase {
    public void startElement (ElementInfo e) throws SAXException  {
      keywords = new Vector();
      expandableTreeNode node= 
	new expandableTreeNode(inputRequest + " can be ");
      node.setID(inputRequest);
      expandableTreeNode top = (expandableTreeNode) (expandableTreeNode)treeModel.getRoot();
      treeModel.insertNodeInto(node, top, top.getChildCount());
    }
   }

  class rfmlResultItemHandler extends ElementHandlerBase {
    public void characters(ElementInfo e, char ch[], int start, int length) throws SAXException {
      String item = new String(ch,start,length);
      item = item.toLowerCase();
      expandableTreeNode node= 
	new expandableTreeNode("  "+item);
      keywords.addElement(item);
      node.setID(item);
      expandableTreeNode top = (expandableTreeNode) (expandableTreeNode)treeModel.getRoot();
      treeModel.insertNodeInto(node, top, top.getChildCount());
    }
   }

  class keywordsHandler extends ElementHandlerBase {
    public void startElement (ElementInfo e) throws SAXException  {
      keywords = new Vector();
      if (potentialMatch) topContent="There is no direct match, used keywords instead\n  keywords:";
      else topContent = "keywords:";
    }
    public void endElement(ElementInfo e) throws SAXException {
      expandableTreeNode node= new expandableTreeNode(topContent);
      expandableTreeNode top = (expandableTreeNode) (expandableTreeNode)treeModel.getRoot();
      treeModel.insertNodeInto(node, top, top.getChildCount());
    }
  }

  public Vector getKeywords() {
    return keywords;
  }

  class keywordHandler extends ElementHandlerBase {

    public void characters(ElementInfo e, char ch[], int start, int length) throws SAXException {
      String word = new String(ch,start,length);
      word = word.toLowerCase();
      keywords.addElement(word);
      topContent = topContent + " " + word;
    }
  }

  class methodNameHandler extends ElementHandlerBase {

    public void characters(ElementInfo e, char ch[], int start, int length) throws SAXException {

      String name = new String(ch,start,length);

      System.out.println("Method name:"+name+"|");

      methodDefRenderer defRenderer = new methodDefRenderer();
      //System.out.println("method def in XML:"+es.getMethodDef(name));

      String definition = defRenderer.toHtml(es.getMethodDef(name));
      //System.out.println("Definition:"+definition+"|");
      expandableTreeNode node;
      if (potentialMatch) 
	node= new expandableTreeNode("Potential match:\n"+definition);
      else 
	node= new expandableTreeNode(definition);
      node.setID(name);
      expandableTreeNode top = (expandableTreeNode) (expandableTreeNode)treeModel.getRoot();
      treeModel.insertNodeInto(node, top, top.getChildCount());
      //System.out.println(" number of children:"+ top.getChildCount());
    }
  }
  class passiveHandler extends ElementHandlerBase {
    public void startElement(ElementInfo e) throws SAXException {
    }
    public void endElement(ElementInfo e) throws SAXException {
    }
  }

}
