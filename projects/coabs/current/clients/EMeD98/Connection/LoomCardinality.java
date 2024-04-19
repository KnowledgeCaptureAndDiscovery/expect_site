package Connection;

import java.util.*;
import java.io.*;

public class LoomCardinality {
  int positiveNumber;
  boolean isInfinity;

  LoomCardinality(String s) {
    if(s.equalsIgnoreCase("NIL")) {
      isInfinity=true;
    } else {
      isInfinity=false;
      positiveNumber=Integer.valueOf(s).intValue();
    }
  }

  public String toString() {
    if(isInfinity) {
      return "infinity";
    } else {
      return String.valueOf(positiveNumber);
    }
  }
}
