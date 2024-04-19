package Connection;

import java.util.*;
import java.io.*;

public class LoomNames {
  public Vector items = new Vector();

  public void print(PrintStream o) {
    Enumeration e = items.elements();
    while(e.hasMoreElements()) {
      LoomName i = (LoomName) e.nextElement();
      o.println(i.rawName);
    }
  }

  LoomName find(String n) {
    Enumeration e = items.elements();
    while(e.hasMoreElements()) {
      LoomName i = (LoomName) e.nextElement();
      if(i.rawName.equalsIgnoreCase(n)) {return i;}
    }
    return null;
  }
}
