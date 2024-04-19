/*  
 * Search.java  4/22/98
 */

/*
 * Main program: use Ontology, Adpative Form, and meta info in DB
 *               and generate DB table name and initial attribute constraints
 *               The table name and the constraints are stored in "af_temp_file"
 * @author Jihie Kim
 */
 
package Tree;
import java.util.*;
import java.io.*;
import com.sun.java.swing.*;
import com.sun.java.swing.text.*;
import com.sun.java.swing.plaf.basic.BasicListCellRenderer;
import java.awt.*;
import java.awt.event.*;

import Connection.ExpectServer;

public class testPanel extends JPanel {
  private JButton reloadButton;

  public testPanel(ExpectServer theServer) {
    JPanel tabbedPane = new JPanel();
    reloadButton = new JButton("reload");
    reloadButton.addActionListener (new reloadListener());
    add("Center",tabbedPane);
    add("South",reloadButton);
  }
 class reloadListener implements ActionListener {
    public void actionPerformed (ActionEvent e) {
      reload();
    }
  }

  private void reload () {}

  public static void main(String[] args) {
      JFrame frame = new JFrame("test Frame");
      ExpectServer es = new ExpectServer();
      frame.addWindowListener(new WindowAdapter() {
        public void windowClosing(WindowEvent e) {
                  System.exit(0);
        }
      });
      
      frame.getContentPane().add("Center", new testPanel(es));
      frame.setSize(400, 500);
      frame.setVisible(true);
    }

    
}
