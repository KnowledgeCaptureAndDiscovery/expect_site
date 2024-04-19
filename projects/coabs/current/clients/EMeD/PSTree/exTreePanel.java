//File: treePanel.java
//
// Copyright (C) 1998 by Jihie Kim
// All Rights Reserved
//

package PSTree;

import java.io.PrintStream;
import javax.swing.tree.*;
import javax.swing.JFrame;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.JButton;
import javax.swing.JTabbedPane;
import java.awt.event.WindowEvent;
import java.awt.event.WindowAdapter;
import java.awt.BorderLayout;
import javax.swing.JOptionPane;

import ExpectWindowPanel;
import Connection.*;
//import Tree.PStreeCellRenderer;
public class exTreePanel extends JPanel {
  JPanel mp;
  JPanel mpAll;

  ExpectSocketAPI es;
  private JTabbedPane mpTabbedPane;
  public exTreePanel(ExpectSocketAPI theServer, 
		     exTabbedPanel thePanel, 
		     ExpectWindowPanel rootPanel) {

    es = theServer;
    setLayout(new BorderLayout());
    add ("Center",new ExecPanel("allRfml",es, thePanel, rootPanel));

    /*  for complete/incomplete trees, we can use tab
    //mp = new MRPanel("completedRfml", es);
    //mpAll = new MRPanel("allRfml", es);
    
    mpTabbedPane = new JTabbedPane();
    
    mpTabbedPane.addTab("Include incomplete RFML in tree", null, 
    		new GRPanel("allRfml",es, thePanel, rootPanel));
			
    // THIS SHOULD BE UNCOMMENTED
    //mpTabbedPane.addTab("Collect complete subtrees ", null, 
    //		new GRPanel("completedRfml",es, thePanel, rootPanel));
    mpTabbedPane.setTabPlacement(JTabbedPane.BOTTOM);
    add("Center",mpTabbedPane);
    */
  }
    
  public exTreePanel(ExpectSocketAPI theServer, 
		     exTabbedPanel thePanel, 
		     ExpectWindowPanel rootPanel,
		     String subRoot) {

    es = theServer;
    setLayout(new BorderLayout());
    //mp = new MRPanel("completedRfml", es);
    //mpAll = new MRPanel("allRfml", es);
    
    mpTabbedPane = new JTabbedPane();
    
    mpTabbedPane.addTab("Include incomplete RFML in tree", null, 
    		new ExecPanel("subTree",subRoot,es, thePanel, rootPanel));
			
    mpTabbedPane.setTabPlacement(JTabbedPane.BOTTOM);
    add("Center",mpTabbedPane);
    
  }
    

  public static void main(String[] args) {
    ExpectSocketAPI es = new ExpectSocketAPI();
    exTreePanel tpanel = new exTreePanel(es, null, null);
    //PSTreePanel tpanel = new PSTreePanel(es, null, null,"ps-an10");
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
