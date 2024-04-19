package Tree;

import java.io.*;
import java.util.*;
import com.icl.saxon.*;
import org.xml.sax.SAXException;
import org.xml.sax.AttributeList;
import org.xml.sax.InputSource;

public class EXPECTParser extends renderer {

  String xmlData;
  //Vector listOfGoals;
  String listOfGoals="";
  
  public EXPECTParser() {
    this("");
  }

  public EXPECTParser(String goalList) {
    //xmlGoalList = goalList;
  }

  public void setGoalList(String goalList) {
    //xmlGoalList = goalList;
  }

  public String getGoals(String goalList) {

    setHandler("goal", new GoalHandler());
    
  //  listOfGoals = new Vector();
    
    if(goalList==null) {
      int result = runFromNamedParser(new InputSource(new String()), "com.ibm.xml.parser.SAXDriver");
    } else {
      int result = runFromNamedParser(new InputSource(new String(goalList)), "com.ibm.xml.parser.SAXDriver");
    }

    return(listOfGoals);
  }
  

  class GoalHandler extends ElementHandlerBase {
    public void characters(ElementInfo e, char ch[], int start, int length) throws SAXException {
      String contents = new String(ch,start,length);
      //listOfGoals.addElement(contents);
      listOfGoals = listOfGoals + contents;
    }
  }

 public static void main(String args[])
 {
 	
  /*String uri = args[0];
  
  EXPECTParser myparser = new EXPECTParser();
  String mylist = myparser.getGoals(uri);	*/
   
 }	


}




