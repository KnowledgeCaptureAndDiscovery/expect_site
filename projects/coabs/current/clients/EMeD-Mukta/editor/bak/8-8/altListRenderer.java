import java.io.*;
import java.util.*;
import java.awt.Color;
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
      String desc = e.getAttribute("desc");

      if (code.equals("paren") || code.equals("expect-null-arg"))
        bt = new eButton (desc,true,e.getAttribute("idx"));
      else if (code.startsWith("expect-")) {// non-terminal 
        bt = new eButton(desc,e.getAttribute("idx"));
        bt.setBackground(new Color(255,222,173));
      }
      else if (desc.equals(" ")) // blank element
        bt = new eButton(desc,e.getAttribute("idx"));
      else 
        bt = new eButton(code,e.getAttribute("idx"));
      bt.setName(code);
      cButtons.addElement(bt);
    }
  }

}
