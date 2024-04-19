package Connection;

import java.util.*;
import java.io.*;

public class LoomRelations {
  public Vector items = new Vector();

  void print(PrintStream o) {
    Enumeration e = items.elements();
    while(e.hasMoreElements()) {
      LoomRelation i = (LoomRelation) e.nextElement();
      o.println(i);
    }
  }

//   LoomRelation find(String n/*ameOfConceptWithoutPackage*/) {
//     Enumeration e = items.elements();
//     while(e.hasMoreElements()) {
//       LoomRelation i = (LoomRelation) e.nextElement();
//       if(i.attribute.loomName.rawName.equalsIgnoreCase(n)) {return i;}
//     }
//     return null;
//   }
}
