// 
// Jihie Kim, 1999
// 
package editor;

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

  /* If the code starts with expect- or the description is blank,
     use the description, otherwise use the code for display */
  private class itemHandler extends ElementHandlerBase {
    public void startElement (ElementInfo e) throws SAXException  {
      Vector cButtons;
      eButton bt;
      ElementInfo parentElement = e.getParent();
      cButtons = (Vector) parentElement.getUserData();
      String code = e.getAttribute("code");
      String desc = e.getAttribute("desc");

      // avoid system-defined concepts
      if (cButtons == null) return;

      /* exclude system created concepts
         %% this is a hack, needs to be handled in server */
      if (desc.startsWith("concept_")) { 
        parentElement.setUserData(null);
        return; 
      }
      if (code.equals("paren") || code.equals("expect-null-arg"))
        bt = new eButton (desc,true,e.getAttribute("idx"));
      else if (code.startsWith("expect-")) {// non-terminal 
        bt = new eButton(desc.toUpperCase(),e.getAttribute("idx"));
        bt.setBackground(new Color(255,222,173));
      }
      else if (desc.equals(" ")|| code.equals("nil")) // blank element
        bt = new eButton(desc,e.getAttribute("idx"));
      else
        bt = new eButton(code,e.getAttribute("idx"));
      //System.out.println("desc:"+desc+":"+"\ncode:"+code);
      bt.setName(code);
      cButtons.addElement(bt);
    }
  }

}
