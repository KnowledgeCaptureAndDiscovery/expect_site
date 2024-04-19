//
// The LayedData class is a tree-structured class of data that is layed
// out in a document. (Probably it could be the document but I'm not
// that sophisticated with java yet.) The main elements of the class are
// a vector of children, a string, an offset and a length.
//

// I just put it in this package because it's used by LispSocketAPI and
// I didn't know how to refer back to the default package.
package Connection;

import java.util.*;

import javax.swing.text.*;

public class LayedData {
    // can't use 1.2 lists on the Mac or older linux, so using 1.1.x vectors.
    public Vector children = null;
    public int start = -1, length = 0;
    public String text = null, name = null;
    public int index = -1;   // This is really for talking to lisp.
    public boolean active = true;
    public Style normalStyle = null;

    public LayedData() {
    }

    public LayedData(String t) {
        text = t;
    }

    public LayedData(int offset) {
        start = offset;
    }

    public LayedData addChild(String data) {
        if (children == null)
	  children = new Vector();
        LayedData res = new LayedData(data);
        children.addElement(res);
        return res;
    }

    public LayedData addChild(LayedData data) {
        if (children == null)
	  children = new Vector();
        children.addElement(data);
        return data;
    }

  // sets the active field for this object and all its descendants to
  // the given value.
  public void setActive(boolean val) {
    active = val;
    if (children != null) {
      for (int i = 0; i < children.size(); i++) {
        ((LayedData)children.elementAt(i)).setActive(val);
      }
    }
  }

    public void actionPerformed() {
    }

    // This is used to get all the text of an element, even if it isn't
    // a leaf.
    public String deepText() {
        String res = text;
        if (children != null) {
	  for (int i = 0; i < children.size(); i++) {
	      res = res + " " + ((LayedData)children.elementAt(i)).deepText();
	  }
        }
        return res;
    }

    // This is used as a printing routine for debugging.
    public String toString() {
        String res;
        res = "{ " + text + " (" + start + "+" + length + ")";
        if (children != null) {
	  for (int i = 0; i < children.size(); i++) {
	      if (i == 0) {
		res = res + "[";
	      } else {
		res = res + ", ";
	      }
	      res = res + ((LayedData)children.elementAt(i)).toString();
	      if (i == children.size() -1) {
		res = res + "]";
	      }
	  }
        }
        res = res + "}";
        return res;
    }

}
        
