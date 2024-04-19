package Tree;

import java.io.*;
import java.util.*;
import com.icl.saxon.*;
import org.xml.sax.SAXException;
import org.xml.sax.AttributeList;
import org.xml.sax.InputSource;

public class editResponseRenderer extends renderer {

  private String messages;
  private String methodName;
  private String methodDefinition;
  private boolean processedP = false;

  public editResponseRenderer(String response) {
    messages = "";
    setHandler("response", new responseHandler());
    setHandler("definition", new definitionHandler());
    setHandler("error", new errorHandler());
    int result = runFromNamedParser(new InputSource(new StringReader(response)), 
				    "com.ibm.xml.parser.SAXDriver");

    //System.out.println("methodName:"+methodName);
    // System.out.println("processedP:"+processedP);
      //System.out.println("messages:"+messages);
  }

  public String getMessages(boolean messageOnly) {
    if (messageOnly)
      return messages;
    else if (processedP)
      return messages +" ***** Editing Processed *****";
    else 
      return messages +" ***** Editing Rejected *****";
  }

  public String getMessages() {
    if (processedP)
      return messages +" ***** Editing Processed *****";
    else 
      return messages +" ***** Editing Rejected *****";
  }

  public String getMethodName() {
    return methodName;
  }
  public String getMethodDefinition() {
    return methodDefinition;
  }

  public boolean processedP () {
    return processedP;
  }


  class responseHandler extends ElementHandlerBase {
    public void startElement (ElementInfo e) throws SAXException  {
      methodName = e.getAttribute("plan-name");
      String checkIfProcessed = e.getAttribute("processed");
      if (checkIfProcessed.equals("T")) processedP = true;
    }
  }

  class definitionHandler extends ElementHandlerBase {
    public void startElement (ElementInfo e) throws SAXException  {
      methodDefinition = e.getAttribute("content");
    }
  }

  class errorHandler extends ElementHandlerBase {
    public void characters(ElementInfo e, char ch[], int start, int length) throws SAXException {
      String contents = new String(ch,start,length);
      messages = messages + contents + "\n";
    }
 
  }
}
