package Tree;

import java.io.*;
import java.util.*;
import com.icl.saxon.*;
import org.xml.sax.SAXException;
import org.xml.sax.AttributeList;
import org.xml.sax.InputSource;

public class FlightStatParser extends renderer {

  String xmlData;
  Vector listOfGoals;
  //String listOfGoals="";
  int i=0;
  public FlightStatParser() {
    this("");
  }

  public FlightStatParser(String goalList) {
    //xmlGoalList = goalList;
  }

  public void setGoalList(String goalList) {
    //xmlGoalList = goalList;
  }

  public Vector getGoals(String goalList) {

    setHandler("compute", new GoalHandler());
    setHandler ("goal",new GoalHandler());
    setHandler("action", new GoalHandler());
    setHandler("param", new GoalHandler());
    setHandler("name", new GoalHandler());
    setHandler("value", new GoalHandler());
  
  listOfGoals = new Vector();
    
    if(goalList==null) {
      int result = runFromNamedParser(new InputSource(new String()), "com.ibm.xml.parser.SAXDriver");
    } else {
      int result = runFromNamedParser(new InputSource("flightstatus.xml"), "com.ibm.xml.parser.SAXDriver");
      //System.out.println("result here"+result);
    }

    return(listOfGoals);
  }
  

  class GoalHandler extends ElementHandlerBase {
    public void characters(ElementInfo e, char ch[], int start, int length) throws SAXException {
      //System.out.println("in handler");
      String contents = new String(ch,start,length);
      contents.trim();
      System.out.println(contents);     
      listOfGoals.add(new String(contents.trim())); 
      i++;
      if(contents.equals(""))
      {
      System.out.println("space here");
      //listOfGoals.addElement(contents);
      //System.out.println("vector : "+listOfGoals);
      //listOfGoals = listOfGoals + contents;
      }
      //System.out.println("contents"+contents);
    }
  }

/*class GoalHandler extends ElementHandlerBase {
    String description;
    public void startElement (ElementInfo e) throws SAXException  {
      //description = removeExtraSpace(e.getAttribute ("text"));
      expandableTreeNode node = new expandableTreeNode();
      node.setUserObject("The result is: "+description);
      ElementInfo parentElement = e.getParent();
      expandableTreeNode parent = (expandableTreeNode)parentElement.getUserData();
      parent.add(node);
      e.setUserData(node);
      
    } */



 public static void main(String args[])
 {
 	
  String uri = args[0];
  System.out.println(uri);
  FlightStatParser myparser = new FlightStatParser();
  Vector mylist = myparser.getGoals(uri);
  //System.out.println(mylist); 
 }	


}




