package Connection;

import java.util.*;
import java.io.*;

public class LoomRoles {
  public Vector items = new Vector();

  void print(PrintStream o) {
    Enumeration e = items.elements();
    while(e.hasMoreElements()) {
      LoomRole i = (LoomRole) e.nextElement();
      o.println(i);
    }
  }

  LoomRole find(String n/*ameOfConceptWithoutPackage*/) {
    Enumeration e = items.elements();
    while(e.hasMoreElements()) {
      LoomRole i = (LoomRole) e.nextElement();
      if(i.attribute.loomName.rawName.equalsIgnoreCase(n)) {return i;}
    }
    return null;
  }
}
