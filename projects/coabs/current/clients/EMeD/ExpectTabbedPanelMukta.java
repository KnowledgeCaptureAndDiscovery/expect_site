//File: ExpectTabbedPanel.java
//
// Copyright (C) 1998 by Jihie Kim
// All Rights Reserved
//

// RHS Tabbes for EMeD

import javax.swing.*;
import java.awt.event.*;
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

public class ExpectTabbedPanel extends JPanel {  
  private JTabbedPane tabbedPane;
  private JButton reloadButton;
  public ExpectSocketAPI es;
  ExpectWindowPanel thePanel = null;
  undefinedGoalListPanel ugPanel;

  private int idxOfSavedCapabilityTab;
  static protected ImageIcon noteIcon = new ImageIcon("images/red.gif");
  static protected ImageIcon saveIcon = new ImageIcon("images/square_blue.gif");
  
  public ExpectTabbedPanel (ExpectSocketAPI server,
			    ExpectWindowPanel parent) {
    thePanel = parent;
    es = server;
    setLayout(new BorderLayout());
    tabbedPane = new JTabbedPane();
    PrintStream o = System.err;
    o.println("created main pane");

  tabbedPane.addTab("Method Relation in problem solving", 
		      new psTabbedPanel(es, thePanel,null,false));
    o.println("added MR tree in PS");

// commented by mukta

    if (thePanel.getSearchedMethods().size() == 0)
      tabbedPane.addTab("Saved Capability for Editing",parent.getSaveArea());
    else tabbedPane.addTab("Saved Capability for Editing", saveIcon, parent.getSaveArea());
    idxOfSavedCapabilityTab = tabbedPane.getTabCount()-1;

// end commented by mukta
    o.println("added capability saver"); 
    // added for YP
    tabbedPane.addTab("Ontology Browser",
		      new HtmlPanel(es,"file:/nfs/v2/expect/current/clients/EMeD/HTML/",
				    "TOP-DOMAIN-CONCEPT.concept"));
    o.println("added Ontology Browser");

    tabbedPane.addTab("Evaluation Result", new resultPanel(es));
    o.println("added Evaluation Result");
    //commented earlier

    /*tabbedPane.addTab("Problem Solving Details", null, new psDescribePanel(es));
    o.println("added Problem Solving Details"); for paper*/

    tabbedPane.addTab("Global Error Detector", 
		      new messagePanel(es,null,false));
    o.println("added Global Error Detector");

    tabbedPane.addTab("Method Seeker", new searchPanel(es,null,thePanel));
    o.println("added Method Seeker");

    tabbedPane.addTab("Capability Organizer",  
		      new treePanel("method-capability",es,thePanel));
    o.println("added Capability Organizer");
    ugPanel = 
      new undefinedGoalListPanel(es, thePanel); 
      //  new PSundefinedGoalsPanel(es, thePanel);
    if (ugPanel.empty())
      tabbedPane.addTab("Method Proposer", ugPanel);
    else 
      tabbedPane.addTab("Method Proposer", noteIcon, ugPanel);
    o.println("added Method Proposer");

    //commented by mukta
    tabbedPane.addTab("Method Sub-Method Analyzer", null,
		  new GRPanel("method-relation",es,null,thePanel),
		  "relationship among user defined methods, based on goals-subgoals");
    
    o.println("added MR tree");


    //tabbedPane.addTab("Set Top Goal", null, new setTopGoalPanel(es));
 
    //PSundefinedGoalsPanel ugPanel = new PSundefinedGoalsPanel(es, thePanel);
    //tabbedPane.addTab("Unmatched Goals in problem solving", null, ugPanel);
    //tabbedPane.addTab("Method Relation in problem solving", null, 
    //		      new PSTreePanel(es, ugPanel, thePanel));


    //tabbedPane.setTabPlacement(JTabbedPane.RIGHT);
    //tabbedPane.setSelectedIndex(7);

   tabbedPane.addChangeListener (new recordListener());
    //add(tabbedPane);
    add("Center",tabbedPane);

    //** for experiment
    //reloadButton = new JButton("reload views only");
    //reloadButton.addActionListener (new reloadListener());
    //add("South",reloadButton);
  }

  class recordListener implements ChangeListener {
    public void stateChanged (ChangeEvent e) {
      record();
    }
  }

  /*
  public void record () {
    int i = tabbedPane.getSelectedIndex();
    if (i == 0) saveData.record("check: Method Sub-Method Analyzer");
    else if (i == 1) saveData.record ("check: Capability Organizer");
    else if (i == 2) saveData.record ("check: Method Proposer");
    else if (i == 3) saveData.record ("check: Method Seeker");
    else if (i == 4) saveData.record ("check: Describe PS Tree");
    else if (i == 5) saveData.record ("check: All Agenda");
    else if (i == 6) saveData.record ("check: Evaluation Result");
    else saveData.record ("check tab:"+i);
  }
     */
  public void record () {
    int i = tabbedPane.getSelectedIndex();
    if (i == 7) saveData.record(i+"check: Method Sub-Method Analyzer");
    else if (i == 6) saveData.record (i+"check: Capability Organizer");
    else if (i == 5) saveData.record (i+"check: Method Proposer");
    else if (i == 4) saveData.record (i+"check: Method Seeker");
    else if (i == 3) saveData.record (i+"check: Describe PS Tree");
    else if (i == 2) saveData.record (i+"check: All Agenda");
    else if (i == 1) saveData.record (i+"check: Evaluation Result");
    else saveData.record ("check tab:"+i);
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
    //tabbedPane.addTab("Method List", null, new methodListPanel(es));
    o.println("remove all");    

    tabbedPane.addTab("Method Relation in problem solving", null,
    	  new psTabbedPanel(es,thePanel,null,false));
    if (thePanel.getSearchedMethods().size() == 0)
      tabbedPane.addTab("Saved Capability", null, thePanel.getSaveArea());
    else tabbedPane.addTab("Saved Capability", saveIcon, thePanel.getSaveArea());
    // added for YP
    tabbedPane.addTab("Ontology Browser", null, 
		      new HtmlPanel(es,"file:/nfs/v2/expect/current/clients/EMeD/HTML/","COMBAT-POWER.concept"));
    tabbedPane.addTab("Evaluation Result", null, new resultPanel(es));
    tabbedPane.addTab("Global Error Detector", null, 
		      new messagePanel(es, null, false));
    //tabbedPane.addTab("Problem Solving Details", null, new psDescribePanel(es));
    tabbedPane.addTab("Method Seeker", null, new searchPanel(es,null,thePanel));
    tabbedPane.addTab("Capability Organizer", null, 
		      new treePanel("method-capability",es,thePanel));
    ugPanel = 
      new undefinedGoalListPanel(es, thePanel);
    if (ugPanel.empty())
      tabbedPane.addTab("Method Proposer", null, ugPanel);
    else 
      tabbedPane.addTab("Method Proposer", noteIcon, ugPanel);

    tabbedPane.addTab("Method Sub-Method Analyzer", null, 
		      new GRPanel("method-relation",es,null,thePanel));

    //tabbedPane.addTab("Set Top Goal", null, new setTopGoalPanel(es));

    //tabbedPane.addTab("Browse Ontology", null, new HtmlPanel(es,"file:d:\\BCBL-demo\\client\\","COA.concept"));


    //tabbedPane.setSelectedIndex(7);

  }

  public void addSaveIcon() {
    tabbedPane.setIconAt(idxOfSavedCapabilityTab,saveIcon);
    tabbedPane.updateUI();
    updateUI();repaint();
  }
  public undefinedGoalListPanel getUndefinedGoalListPanel() {
    return ugPanel;
  }

  public static void main(String[] args) {
    ExpectSocketAPI es = new ExpectSocketAPI();
      JFrame frame = new JFrame("Expect Tabbed Panel");
 
      frame.addWindowListener(new WindowAdapter() {
        public void windowClosing(WindowEvent e) {
                  System.exit(0);
        }
      });
      
      frame.getContentPane().add("Center", new ExpectTabbedPanel(es, null));
      frame.setSize(1100, 600);
      frame.setVisible(true);
    }


}
