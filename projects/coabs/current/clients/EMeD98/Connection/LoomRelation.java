package Connection;

import java.util.*;
import java.io.*;

public class LoomRelation {
  LoomName loomName;

  LoomRelation(String s) {
    loomName=new LoomName(s);
  }

  LoomRelation(LoomName n) {
    loomName=n;
  }

  public String toString() {
    return loomName.toString();
  }
}
