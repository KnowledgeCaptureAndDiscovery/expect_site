//File: SmallTabbedPanel.java
//
// Copyright (C) 1998 by Jihie Kim
// All Rights Reserved
//
import javax.swing.JPanel;
import javax.swing.JFrame;
import javax.swing.JTextField;
import javax.swing.JLabel;
import javax.swing.JButton;
import javax.swing.JTabbedPane;
import javax.swing.JCheckBox;
import java.awt.event.WindowAdapter;
import java.awt.event.WindowEvent;
import java.awt.event.ActionListener;
import java.awt.event.ActionEvent;
import java.awt.BorderLayout;
import java.io.PrintStream;

import javax.swing.event.ChangeEvent;
import javax.swing.event.ChangeListener;

//import javax.swing.border.*;


import Tree.*;
import PSTree.*;
import HTML.*;
import Describe.*;
import experiment.*;
import Connection.*;

import javax.swing.Icon;
import javax.swing.ImageIcon;

public class SmallTabbedPanel extends JPanel {  
  private JTabbedPane tabbedPane;
  private JButton reloadButton;
  private ExpectSocketAPI es;
  ExpectWindowPanel thePanel = null;

  static protected ImageIcon noteIcon = new ImageIcon("images/red.gif");

  public SmallTabbedPanel (ExpectSocketAPI server,
		        ExpectWindowPanel parent) {
    thePanel = parent;
    es = server;
    setLayout(new BorderLayout());

    tabbedPane = new JTabbedPane();
    PrintStream o = System.err;
    o.println("created main pane");
 
    tabbedPane.addTab("Describe PS Tree", null, new psDescribePanel(es));
    o.println("added describe ps tree panel");
    tabbedPane.addTab("Error Messages", null, new messagePanel(es,null,false));
    o.println("added agenda panel");
    tabbedPane.addTab("Evaluation Result", null, new resultPanel(es));
    tabbedPane.setSelectedIndex(0);

    tabbedPane.addChangeListener (new recordListener());
    //add(tabbedPane);
    add("Center",tabbedPane);

  }

  public class recordListener implements ChangeListener {
    public void stateChanged (ChangeEvent e) {
      record();
    }
  }

  public void record () {
    int i = tabbedPane.getSelectedIndex();
    if (i == 0) saveData.record("check: Describe PS Tree");
    else if (i == 1) saveData.record ("check: Error Messages");
    else if (i == 2) saveData.record ("check: Evaluation result");
    else saveData.record ("check:"+i+"th tab");
    // the above is wrong
    // when i == 0: Describe PS Tree
    // when i == 1: error messages
  }


  class reloadListener implements ActionListener {
    public void actionPerformed (ActionEvent e) {
      reload();
    }
  }

  // need to be modified//
  public void reload () {
    PrintStream o = System.err;

    tabbedPane.removeAll();    
    o.println("remove all");

    tabbedPane.addTab("Describe PS Tree", null, new psDescribePanel(es));
    o.println("added describe ps tree panel");
    tabbedPane.addTab("Error Messages", null, new messagePanel(es,null,false));
    o.println("added agenda panel");
    tabbedPane.addTab("Evaluation Result", null, new resultPanel(es));
    tabbedPane.setSelectedIndex(0);

  }


  public static void main(String[] args) {
    ExpectSocketAPI es = new ExpectSocketAPI();
      JFrame frame = new JFrame("Expect Tabbed Panel");
 
      frame.addWindowListener(new WindowAdapter() {
        public void windowClosing(WindowEvent e) {
                  System.exit(0);
        }
      });
      
      frame.getContentPane().add("Center", new SmallTabbedPanel(es, null));
      frame.setSize(1100, 600);
      frame.setVisible(true);
    }


}
