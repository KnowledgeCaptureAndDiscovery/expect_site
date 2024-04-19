package Connection;

public class NodePCDATA extends SimpleNode {
  private String pcdata;

  public NodePCDATA(String data) {
    super(0);
    pcdata = data;
  }

  public String toString() {
    return "PCDATA: " + pcdata;
  }
}
