//File: capabilityOrganizer.java
//
// Copyright (C) 2000 by Jihie Kim
// All Rights Reserved
//

package Tree;

import java.io.PrintStream;
import javax.swing.tree.*;
import javax.swing.*;
import java.awt.event.*;
import java.awt.*;
import javax.swing.JOptionPane;

import Connection.*;
import xml2jtml.methodDefRenderer;

import ExpectWindowPanel;
import CritiqueWizard;
import MethodEditor;
public class capabilityOrganizer extends JPanel {
  private expandableTreePanel ep;
  private capOrgRenderer app;
  private expandableTree tree;
  private JComponent buttons;
  private JButton selectButton;
  private JButton showButton;
  private JButton editButton;
  private String xmlInput;
  ExpectSocketAPI es;
  private JButton copyCapButton;
  ExpectWindowPanel thePanel;
  boolean useNLEditor = false;
  CritiqueWizard wizard = null;

  String name;

  public capabilityOrganizer(ExpectSocketAPI theServer,
			     ExpectWindowPanel rootPanel,
			     CritiqueWizard w,
			     boolean useNL) {
    es = theServer;
    thePanel = rootPanel;

    xmlInput = es.getMethodCapabilityTree("");
    app = new capOrgRenderer(xmlInput);
    //System.out.println("capability tree in XML:"+xmlInput);
    tree = app.getTree();
    tree.setCellRenderer(new expectTreeCellRenderer());
    ep = new expandableTreePanel(tree);

    tree.expandTree();

    setLayout(new BorderLayout());
    showButton = new JButton("Show definition");
    showButton.addActionListener (new showListener());
    editButton = new JButton("Edit definition");
    editButton.addActionListener (new editListener());

    //selectButton = new JButton("Select definition");
    //selectButton.addActionListener (new selectListener());
    //copyCapButton = new JButton("Copy Capability");
    //copyCapButton.addActionListener(new copyCapListener());

    buttons = new JPanel();
    buttons.setLayout(new FlowLayout(FlowLayout.LEFT));
    buttons.add(showButton);
    buttons.add(editButton);
    //buttons.add(copyCapButton);
    add("Center",ep);
    add("South",buttons);
    
  }

  class showListener implements ActionListener {
    public void actionPerformed (ActionEvent e) {
      showMethod();
    }
  }

  private void showMethod() {
    name = tree.getSelectedName();
    System.out.println("selected name:"+name);
    if (name.equals("SYSTEM")) {
      JOptionPane.showMessageDialog(null, "Goal description built by the System");
      return;
    }
    if (name!= null) name = name.trim();
   
    if ((name == null)||(name.equals("NIL")))
      JOptionPane.showMessageDialog(null, "Please select a goal first");
    else if (name.equals("SYSTEM")) 
      JOptionPane.showMessageDialog(null, "Goal description built by the System");
    else {
      methodDefRenderer defRenderer = new methodDefRenderer();
      String definition = defRenderer.toHtml(es.getMethodDef(name));
    
      ViewFrame ed = new ViewFrame("Method", name, definition);
    }
  }

  class editListener implements ActionListener {
    public void actionPerformed (ActionEvent e) {
      name = tree.getSelectedName();
      if ((name == null)||(name.equals("NIL")))
	JOptionPane.showMessageDialog(null, "Please select a goal first");
      else if (name.equals("SYSTEM"))
	JOptionPane.showMessageDialog(null, "Goal description built by the System");
      else {
	new MethodEditor(name, es) {
	  public void respondToDone() {
	    if (wizard != null) {
	      wizard.editedMethod(name);
	    }
	    dispose();
	    es.postProcessNLEdit(name);
	  }
	};
	
	      
      }
    }
  }
  class selectListener implements ActionListener {
    public void actionPerformed (ActionEvent e) {
      select();
    }
  }

  private void select() {
    name = tree.getSelectedName();
    if (name!= null) name = name.trim();
   
    if ((name == null)||(name.equals("NIL")))
      JOptionPane.showMessageDialog(null, "Please select a goal first");
    else if (name.equals("SYSTEM")) 
      JOptionPane.showMessageDialog(null, "Goal description built by the System");
    else {
      if (thePanel != null)
      thePanel.listPanel.setSelectedNode(name);
    }
  }

  class copyCapListener implements ActionListener {
    public void actionPerformed(ActionEvent e) {   
      copyCapability();
    }
  }
  
  private void copyCapability() {
    name = tree.getSelectedName();

    if (!(null== name || name.equals(""))) {
      String simpleGoal = es.getSimplifiedGoal(name);
      System.out.println("goal desc:" + simpleGoal + "for :"+ name);
      thePanel.addCopiedGoal (simpleGoal);
      thePanel.addSearchedMethod(name);
    }
  }

  public static void main(String[] args) { 
    ExpectSocketAPI es = new ExpectSocketAPI();
    capabilityOrganizer tpanel = new capabilityOrganizer(es,null,null,false);
    JFrame frame = new JFrame("Capability Organizer");
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
