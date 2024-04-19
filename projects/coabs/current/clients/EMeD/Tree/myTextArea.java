package Tree;
import javax.swing.JTextArea;

public class myTextArea extends JTextArea {
  String lines[] = new String[50];
  myTextArea() {
    super(5,70);

  }
  myTextArea(String text) {
    super(text,5,70);

  }

}
