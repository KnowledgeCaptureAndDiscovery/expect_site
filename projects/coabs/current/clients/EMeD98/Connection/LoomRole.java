package Connection;

import java.util.*;
import java.io.*;

public class LoomRole {
  static String separator = new String(" ");
  LoomRelation attribute;
  LoomCardinality min;
  LoomCardinality max;
  LoomConcept type;

  public LoomRole(String s) {
    int a = s.indexOf(separator,0);
    int b = s.indexOf(separator,a+1);
    int c = s.indexOf(separator,b+1);

    attribute=new LoomRelation(s.substring(0,a));
    min=new LoomCardinality(s.substring(a+separator.length(),b));
    max=new LoomCardinality(s.substring(b+separator.length(),c));
    type=new LoomConcept(s.substring(c+separator.length(),s.length()));
  }

  public String toString() {
    return attribute+separator+min+separator+max+separator+type;
  }
}
