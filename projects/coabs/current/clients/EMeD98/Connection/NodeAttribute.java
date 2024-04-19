package Connection;

public class NodeAttribute extends SimpleNode {
  private String name, value;

  public NodeAttribute(String n, String v) {
  super(0);
  name = n;
  value = v;
  }

  static String removeQuotes(String s) {
    if(s.length()>=2 && s.startsWith("\"") && s.endsWith("\"")) {
      return s.substring(1,s.length()-1);
    } else {
      return s;
    }
  }

  String getName() {return name;}
  String getValue() {
      return removeQuotes(value);
  }

  public String toString() {
    return "attribute: " + name + "=" + value;
  }
}
