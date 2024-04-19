import java.io.*;
import HTML.conceptRenderer;

public class testR {

  public static void main(String argv[]) {
    String output = "";
    String input = "";
    int ch;

    String in = "";
    String out = "";
    //EXENodeRenderer r = new EXENodeRenderer();
    //methodRenderer("/home/valente/expect/renderer/inspect-acplan.xml");
    conceptRenderer r = new conceptRenderer();
    //in = r.readFileToString("./geographical-gap.xml");
    in = r.readFileToString("./bridge.xml");
    out = r.toHtml(in);
    //System.out.println("input:"+in);
    System.out.println(out);
    

  }

}
