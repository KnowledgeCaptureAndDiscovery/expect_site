package Connection;

import java.util.*;
import java.io.*;

public class LoomConcepts {
  public Vector items = new Vector();

  LoomConcepts() {
  }

  public LoomConcepts(LoomNames ns) {
    Enumeration e = ns.items.elements();
    while(e.hasMoreElements()) {
      LoomName i = (LoomName) e.nextElement();
      items.addElement(new LoomConcept(i));
    }
  }

  void print(PrintStream o) {
    Enumeration e = items.elements();
    while(e.hasMoreElements()) {
      LoomConcept i = (LoomConcept) e.nextElement();
      o.println(i.loomName.rawName);
    }
  }

  LoomConcept find(String n/*ameOfConceptWithoutPackage*/) {
    Enumeration e = items.elements();
    while(e.hasMoreElements()) {
      LoomConcept i = (LoomConcept) e.nextElement();
      if(i.loomName.rawName.equalsIgnoreCase(n)) {return i;}
    }
    return null;
  }

  LoomConcept find(LoomConcept c) {
    Enumeration e = items.elements();
    while(e.hasMoreElements()) {
      LoomConcept i = (LoomConcept) e.nextElement();
      if(i.loomName.rawName.equalsIgnoreCase(c.loomName.rawName)) {return i;}
    }
    return null;
  }
}
