package Connection;

import java.util.*;
import java.io.*;

public class LoomRoleFacet {
  static String separator = new String(" ");
  LoomRelation name;
  String value;

  LoomRoleFacet(String s) {
    int a = s.indexOf(separator,0);

    name=new LoomRelation(s.substring(0,a));
    value=s.substring(a+separator.length(),s.length());
  }

  public String toString() {
    return name+separator+value;
  }
}
