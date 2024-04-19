// 
// Jihie Kim, 1999
// 

import com.sun.java.swing.*;
import java.awt.*;
import java.util.*;
import java.awt.event.*;
import Connection.ExpectServer;
import com.sun.java.swing.border.*;

public class test extends JPanel {
  public test () {
    JButton b1 = new JButton("a test 1 b");
    JButton b2 = new JButton("a test 2 b");
    JButton b3 = new JButton("a test 3 b");
    JButton b4 = new JButton("a test 4 b");
    JButton b5 = new JButton("a test 4 5");
    setLayout(new FlowLayout(FlowLayout.LEFT));
    add(b1);
    add(b2);
    add(b3);
    add(b4);
    add(b5);
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
