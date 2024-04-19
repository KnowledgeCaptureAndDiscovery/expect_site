package Tree;

import java.awt.event.*;

import javax.swing.JTextArea;
import javax.swing.JPanel;
import javax.swing.JFrame;
import javax.swing.JScrollPane;
public class testTextArea extends JPanel {
  JTextArea area;
  public testTextArea() {
    area = new JTextArea();
    area.setText("[GOAL:         (estimate (obj (?t is (spec-of time))) (for (?s is (inst-of emplace-avlb))))   \n  RESULT:       null\n  EDT-NOW: null\n  BODY:         (find (obj (spec-of time-for-emplacement)) (for (bridge-of ?s)))  \n]");
    System.out.println(" getColumns():"+area.getColumns());
    area.setColumns(30);
    System.out.println(" later getColumns():"+area.getColumns());
    JScrollPane sp = new JScrollPane(area);
    add (sp);

  }
  public static void main(String[] args) {
      JFrame frame = new JFrame("test JTextArea");
 
      frame.addWindowListener(new WindowAdapter() {
        public void windowClosing(WindowEvent e) {
                  System.exit(0);
        }
      });
      
      frame.getContentPane().add("Center", new testTextArea());
      frame.setSize(400, 500);
      frame.setVisible(true);
  }
}

