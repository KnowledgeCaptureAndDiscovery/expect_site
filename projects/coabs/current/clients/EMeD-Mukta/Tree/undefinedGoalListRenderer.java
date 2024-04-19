package Tree;

import java.io.*;
import java.util.*;
import com.icl.saxon.*;
import org.xml.sax.SAXException;
import org.xml.sax.AttributeList;
import org.xml.sax.InputSource;

public class undefinedGoalListRenderer extends renderer {

  String xmlGoalList;
  String callers = null;
  String expectedResult = null;
  String capabilityDesc = null;

  expandableTreeNode top = new expandableTreeNode("Unachieved Subgoals"); 
  expandableTreeNode currentParent;
  expandableTree tree;

  public undefinedGoalListRenderer() {
    this("");
  }

  public undefinedGoalListRenderer(String goalList) {
    //System.out.println("xml und goal list:"+goalList);
    xmlGoalList = goalList;
    tree = new expandableTree(top);
    //tree.setRootVisible (false);
  }

  public void setGoalList(String goalList) {
    xmlGoalList = goalList;
  }

  public expandableTree getGoalsInTree() {

    setHandler("goal", new GoalHandler());
    setHandler("undefined-goals", new passiveHandler());
    //setHandler("rfmls-for-method", new rfmlsHandler());
    
    int result = runFromNamedParser(new InputSource(new StringReader(xmlGoalList)), "com.ibm.xml.parser.SAXDriver");
    
    return tree;
  }
  
  //int count = 0;
  class GoalHandler extends ElementHandlerBase {
    public void startElement (ElementInfo e) throws SAXException  {
      expandableTreeNode currentNode = new expandableTreeNode();
      //top.add(currentNode);
      e.setUserData (currentNode);
      callers = removeExtraSpace(e.getAttribute("callers"));
      expectedResult = removeExtraSpace(e.getAttribute("expected-result"));
      capabilityDesc = removeExtraSpace(e.getAttribute("capability-desc").replace('\n',' '));
      currentNode.setID(removeExtraSpace(e.getAttribute("id")));
      //System.out.println("ug id:"+removeExtraSpace(e.getAttribute("id")));
      //currentNode.setID(Integer.toString(count));
      //count++;
    }
    public void characters(ElementInfo e, char ch[], int start, int length) throws SAXException {
      expandableTreeNode node= (expandableTreeNode) e.getUserData();
      String contents = new String(ch,start,length);
      contents = removeExtraSpace(contents.replace('\n',' ')) + "\nExpected Result:"+expectedResult;
      if (callers.startsWith ("covering")||callers.startsWith ("set")) {
	contents = "More Special:\n" + contents;
	currentParent.add(node);
      }
      else {
	contents = contents + "\nCallers:"+callers;
	top.add(node);
	currentParent = node;
      }
      //System.out.println("Callers:"+callers+"|");
      contents = contents + "\nCapability:"+ capabilityDesc; // this is not displayed
      node.setUserObject(contents);

      callers = null;
      expectedResult = null;
      //System.out.println(" set user data for node:"+node.getID() +":" + contents);
    }
  }

  private class rfmlsHandler extends ElementHandlerBase {
    public void characters (ElementInfo e, char ch[], int start, int length) throws SAXException {
      String contents = new String(ch,start,length);
      ElementInfo parentElement = e.getParent();
      expandableTreeNode node;

      node = (expandableTreeNode)parentElement.getUserData();
      String goalInfo = (String)node.getUserObject();
      String rfmlsInfo = removeExtraSpace(contents);
      node.setUserObject(goalInfo +"\n       rfmls:           "+contents);
      o.println(" set user data for node:" + goalInfo +"\n    rfmls:  "+contents);
    }
  }
 
 
 
}




