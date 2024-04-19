package Tree;

import java.io.*;
import java.util.*;
import com.icl.saxon.*;
import org.xml.sax.SAXException;
import org.xml.sax.AttributeList;
import org.xml.sax.InputSource;

public class goalListParser extends renderer {

  String xmlGoalList;
  Vector listOfGoals;

  public goalListParser() {
    this("");
  }

  public goalListParser(String goalList) {
    xmlGoalList = goalList;
  }

  public void setGoalList(String goalList) {
    xmlGoalList = goalList;
  }

  public Vector getGoals(String goalList) {

    setHandler("goal", new GoalHandler());
    
    listOfGoals = new Vector();

    if(goalList==null) {
      int result = runFromNamedParser(new InputSource(new StringReader(xmlGoalList)), "com.ibm.xml.parser.SAXDriver");
    } else {
      int result = runFromNamedParser(new InputSource(new StringReader(goalList)), "com.ibm.xml.parser.SAXDriver");
    }

    return(listOfGoals);
  }
  

  class GoalHandler extends ElementHandlerBase {
    public void characters(ElementInfo e, char ch[], int start, int length) throws SAXException {
      String contents = new String(ch,start,length);
      listOfGoals.addElement(contents);

    }
  }

}




