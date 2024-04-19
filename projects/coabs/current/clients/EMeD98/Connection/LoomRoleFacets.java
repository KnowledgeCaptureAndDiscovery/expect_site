package Connection;
 
import java.util.*;
import java.io.*;

public class LoomRoleFacets {
  public Vector items = new Vector();

  void print(PrintStream o) {
    Enumeration e = items.elements();
    while(e.hasMoreElements()) {
      LoomRoleFacet i = (LoomRoleFacet) e.nextElement();
      o.println(i);
    }
  }

  LoomRoleFacet find(String n/*ameOfRelationWithoutPackage*/) {
    Enumeration e = items.elements();
    while(e.hasMoreElements()) {
      LoomRoleFacet i = (LoomRoleFacet) e.nextElement();
      if(i.name.loomName.rawName.equalsIgnoreCase(n)) {return i;}
    }
    return null;
  }
}
