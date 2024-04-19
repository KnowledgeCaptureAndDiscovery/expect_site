package Connection;

import java.util.*;
import java.io.*;

public class LoomName {
  static String separator = new String("::");
  static String alternativeSeparator = new String(":");

  String sep;
  public String loomPackage;
  public String rawName;

  public LoomName(String s) {
    int i = s.indexOf(separator);
    if(i!=-1) {
      sep=separator;
      loomPackage = s.substring(0,i);
      rawName = s.substring(i+separator.length(),s.length());
    } else {
      i = s.indexOf(alternativeSeparator);
      sep=alternativeSeparator;
      loomPackage = s.substring(0,i);
      rawName = s.substring(i+alternativeSeparator.length(),s.length());
    }
  }

  public String toString() {
    return loomPackage+sep+rawName;
  }
}
