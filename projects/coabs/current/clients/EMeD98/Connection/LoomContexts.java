package Connection;

import java.util.*;
import java.io.*;

public class LoomContexts {
  public Vector items = new Vector();

  void print(PrintStream o) {
    Enumeration e = items.elements();
    while(e.hasMoreElements()) {
      LoomContext i = (LoomContext) e.nextElement();
      o.println(i.item);
    }
  }

  boolean contains(String s) {
    Enumeration e = items.elements();
    while(e.hasMoreElements()) {
      LoomContext i = (LoomContext) e.nextElement();
      if(i.item.equalsIgnoreCase(s)) {return true;}
    }
    return false;
  }
}
