//File: treePanel.java
//
// Copyright (C) 1998 by Jihie Kim
// All Rights Reserved
//

package PSTree;

import java.io.PrintStream;
import com.sun.java.swing.tree.*;
import com.sun.java.swing.JFrame;
import com.sun.java.swing.JPanel;
import com.sun.java.swing.JScrollPane;
import com.sun.java.swing.JButton;
import com.sun.java.swing.JTabbedPane;
import java.awt.event.WindowEvent;
import java.awt.event.WindowAdapter;
import java.awt.BorderLayout;
import com.sun.java.swing.JOptionPane;


import Connection.ExpectServer;

//import Tree.PStreeCellRenderer;
public class PSTreePanel extends JPanel {
  JPanel mp;
  JPanel mpAll;

  ExpectServer es;
  private JTabbedPane mpTabbedPane;
  public PSTreePanel(ExpectServer theServer, psTabbedPanel thePanel) {

    es = theServer;
    setLayout(new BorderLayout());
    //mp = new MRPanel("completedRfml", es);
    //mpAll = new MRPanel("allRfml", es);
    mpTabbedPane = new JTabbedPane();
    mpTabbedPane.addTab("Include incomplete RFML in tree", null, 
			new GRPanel("allRfml",es, thePanel));
    // THIS SHOULD BE UNCOMMENTED
    mpTabbedPane.addTab("Collect complete subtrees ", null, 
			new GRPanel("completedRfml",es, thePanel));
    mpTabbedPane.setTabPlacement(JTabbedPane.BOTTOM);
    add("Center",mpTabbedPane);
    
  }
    

  public static void main(String[] args) { 
    ExpectServer es = new ExpectServer();
    PSTreePanel tpanel = new PSTreePanel(es, null);
    JFrame frame = new JFrame("Method Tree");
     frame.addWindowListener(new WindowAdapter() {
        public void windowClosing(WindowEvent e) {
                  System.exit(0);
        }
      });
     frame.getContentPane().add(tpanel);
     frame.setSize(700, 500);
     frame.setVisible(true);

  }

}
