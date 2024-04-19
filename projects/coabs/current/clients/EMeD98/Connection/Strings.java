package Connection;

import java.util.*;
import java.io.*;

public class Strings {
  public Vector items = new Vector();

  void print(PrintStream o,String inbetween,String atend,String beforeeach) {
    boolean first=true;					
    boolean something=false;				
    Enumeration e = items.elements();
    while(e.hasMoreElements()) {
      String s = (String) e.nextElement();
      if(!first) {				
	o.print(inbetween);		
      } else {					
	first=false;					
      }						
      something=true;					
      o.print(beforeeach);
      o.print(s);
    }
    if(something){o.print(atend);}
  }

  public void print(PrintStream o) {
    print(o,"\n","\n","");
  }

  boolean contains(String x) {
    Enumeration e = items.elements();
    while(e.hasMoreElements()) {
      String s = (String) e.nextElement();
      if(s.equals(x)) {return true;}
    }
    return false;
  }

}
