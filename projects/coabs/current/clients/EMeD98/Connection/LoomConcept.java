package Connection;

import java.util.*;
import java.io.*;

public class LoomConcept {
  public LoomName loomName;

  public LoomConcept(String s) {
    loomName=new LoomName(s);
  }

  public LoomConcept(LoomName n) {
    loomName=n;
  }

  public String toString() {
    return loomName.toString();
  }
}
