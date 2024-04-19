// 
// Jihie Kim, 1999
// 

import com.sun.java.swing.*;
import java.awt.event.*;
import java.awt.*;
import java.util.*;
port Connection.ExpectServer;
port Connection.ExpectSocketAPI;

public class test extends JPanel {
  private Component selectedButton = null;
  JScrollPane ascrollpane;  
  JList listBox;
  public test () {

    Vector result = new Vector();
    result.addElement("ttt");
    listBox = new JList(result);
    ascrollpane = new JScrollPane(listBox);

  }

  public static void main(String[] args) {
    JFrame frame = new JFrame("Expect test");
    frame.addWindowListener(new WindowAdapter() {
      public void windowClosing(WindowEvent e) {
                  System.exit(0);
      }
      });
      
    frame.getContentPane().add("Center", new test());
    frame.setLocation(50,50);
    frame.setSize(300, 300); // demo mode
    frame.setVisible(true);
  }
 

}
