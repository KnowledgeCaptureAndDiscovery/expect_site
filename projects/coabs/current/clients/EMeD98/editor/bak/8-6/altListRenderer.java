import java.io.*;
import java.util.*;
import com.icl.saxon.*;
import org.xml.sax.SAXException;
import org.xml.sax.AttributeList;
import org.xml.sax.InputSource;
import Tree.renderer;

public class altListRenderer extends renderer {
  String xmlAltList="";
  Vector listOfAltButtons = new Vector(); // list of set of button
  public altListRenderer () {
    this ("");
  }

  public altListRenderer (String altList) {
    xmlAltList = altList;
  }

  public Vector getAlts () {
    setHandler("alt", new altHandler());
    setHandler("item", new itemHandler());

    runFromNamedParser(new InputSource(new StringReader(xmlAltList)), 
		   "com.ibm.xml.parser.SAXDriver");
    return listOfAltButtons;
  }

  private class altHandler extends ElementHandlerBase {
    public void startElement (ElementInfo e) throws SAXException  {
      Vector buttons = new Vector();
      e.setUserData (buttons);
      listOfAltButtons.addElement(buttons);
    }
  }

  private class itemHandler extends ElementHandlerBase {
    public void startElement (ElementInfo e) throws SAXException  {
      Vector cButtons;
      eButton bt;
      ElementInfo parentElement = e.getParent();
      cButtons = (Vector) parentElement.getUserData();
      String code = e.getAttribute("code");
      if (code.equals("PAREN") || code.equals("EXPECT-NULL-ARG"))
        bt = new eButton (e.getAttribute("desc"),true,e.getAttribute("idx"));
      else bt = new eButton(e.getAttribute("desc"),e.getAttribute("idx"));
      bt.setName(code);
      cButtons.addElement(bt);
    }
  }

}
