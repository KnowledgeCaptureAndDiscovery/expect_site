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
import javax.swing.JComponent;
import javax.swing.event.TreeSelectionListener;
import javax.swing.event.TreeSelectionEvent;
import java.awt.event.*;
import java.awt.*;

import javax.swing.JOptionPane;
import java.util.Stack;

import Connection.*;

import xml2jtml.methodDefRenderer;
import Tree.expandableTree;
import Tree.expandableTreeNode;
import Tree.undefinedGoalListPanel;
import ExpectWindowPanel;
public class GRPanel extends JPanel {
  JScrollPane sp;
  GRRenderer app;
  expandableTree tree;
  String xmlInput;

  JPanel buttons;
  private JButton selectButton;
  private JButton hideDetailsButton;
  private JButton showDetailsButton;
  private JButton nodeDetailsButton;
  private JButton partialMatchButton;
  private JButton editButton;

  JPanel testP;
  ExpectSocketAPI es;
  String type;
  PSundefinedGoalsPanel gPanel = null;

  psTabbedPanel thePSPanel= null;
  ExpectWindowPanel mainPanel;
  String methodName;
  public GRPanel(String Stype, ExpectSocketAPI theServer,
		 psTabbedPanel thePanel,
		 ExpectWindowPanel rootPanel) {
    if (null != thePanel) gPanel = thePanel.getUGPanel();
    thePSPanel = thePanel;
    mainPanel = rootPanel;
    es = theServer;
    type = Stype;

    initPanel();
  }

  String newRootName;
  public GRPanel(String Stype, String subRoot, ExpectSocketAPI theServer,
		 psTabbedPanel thePanel,
		 ExpectWindowPanel rootPanel) {
    newRootName = subRoot;
    if (null != thePanel) gPanel = thePanel.getUGPanel();
    thePSPanel = thePanel;
    mainPanel = rootPanel;
    es = theServer;
    type = Stype;

    initPanel();
  }
     
  private void initPanel () {
    
    setLayout(new BorderLayout());    
    buildTree();
    createButtons();

    testP = new JPanel();
    testP.setLayout(new BorderLayout());
    testP.add("Center",sp);
    testP.add("South",buttons);
    add ("Center",testP);
  }

  private void buildTree() {
    if (type.equals("method-relation")) {
      xmlInput = es.getMethodRelationTree(type);
    }
    else if (type.equals("allRfml")) {
      xmlInput = es.getPSMethodRelAll(type); 
    }
    else if (type.equals("subTree")) {
      xmlInput = es.getPSMethodRelSubTree(newRootName);
    }
    else if (type.equals("completedRfml")) {
      xmlInput = es.getPSMethodRelation(type);
    }
    else {
      System.out.println("invalid type:"+type);
    }

    System.out.println("type:"+type+"\n GR xml:"+xmlInput);
    
    app = new GRRenderer(xmlInput,es);
    //System.out.println("finished GR Renderer");
    tree = app.getTree();
    tree.setCellRenderer(new GRSmallCellRenderer());
    sp = new JScrollPane(tree);
    sp.setPreferredSize(new Dimension(600,600));
    tree.expandTree();
    tree.addTreeSelectionListener(new grNodeSelectListener());


  }

  private void createButtons() {
    buttons = new JPanel();
    buttons.setLayout(new GridLayout(1,0));

    if (null != thePSPanel) {
      editButton = new JButton("modify method definition");
      editButton.addActionListener (new editMethodListener());
      buttons.add(editButton);
      
      //partialMatchButton = new JButton("Show potential match for incomplete goals");
      //partialMatchButton.addActionListener (new partialMatchListener());
      //buttons.add(partialMatchButton);
    }
    selectButton = new JButton("Select for Editing");
    selectButton.addActionListener (new selectListener());
    hideDetailsButton = new JButton("Summary");
    hideDetailsButton.addActionListener (new hideDetailsListener());
    showDetailsButton = new JButton("Details");
    showDetailsButton.addActionListener (new showDetailsListener());
    nodeDetailsButton = new JButton("Node Details");
    nodeDetailsButton.addActionListener (new nodeDetailsListener());

    buttons.add(selectButton);
    buttons.add(nodeDetailsButton);

    buttons.add(hideDetailsButton);
    buttons.add(showDetailsButton);
    

    hideDetailsButton.setEnabled(false);
  }

  public void reload () {
    testP.removeAll();
    buildTree();
    createButtons();
    testP.add("Center",sp);
    testP.add("South",buttons);
  }

  class hideDetailsListener implements ActionListener {
    public void actionPerformed (ActionEvent e) {
      hideDetails();
    }
  }

  private void hideDetails() {
    showDetailsButton.setEnabled(true);
    hideDetailsButton.setEnabled(false);
    tree.setCellRenderer(new GRSmallCellRenderer());
    //sp = new JScrollPane(tree);
    updateUI();
    repaint();
  }

  class editMethodListener implements ActionListener {
    public void actionPerformed (ActionEvent e) {
      expandableTreeNode current = tree.getSelectedNode();
      String content = ((GRObject) current.getUserObject()).getContent();
      methodName = current.getID();
      if (methodName.equals("") || methodName == null || 
	  content.startsWith("[UNDEFINED") ||
	  content.startsWith("{An alternative")) {
	JOptionPane.showMessageDialog(null, "well, there is no method defined for this node");
	return;
      }
      thePSPanel.EditMethod (methodName);
      
    }
  }

  class showDetailsListener implements ActionListener {
    public void actionPerformed (ActionEvent e) {
      showDetails();
    }
  }

  private void showDetails() {
    showDetailsButton.setEnabled(false);
    hideDetailsButton.setEnabled(true);
    tree.setCellRenderer(new GRCellRenderer());
    updateUI();
    repaint();
  }

  class nodeDetailsListener implements ActionListener {
    public void actionPerformed (ActionEvent e) {
      nodeDetails();
    }
  }

  private void nodeDetails() {
    
    expandableTreeNode current = tree.getSelectedNode();
    if (current == null) {
      JOptionPane.showMessageDialog(null, "Please select a node first");
    }
    else {
      String name = tree.getSelectedName();
      String content = ((GRObject) current.getUserObject()).getContent();
      //String content = (String) current.getUserObject();
     showNodeFrame ed = new showNodeFrame(current);
    }
  }

  class selectListener implements ActionListener {
    public void actionPerformed (ActionEvent e) {
      select();
    }
  }

  private void select() {
    expandableTreeNode current = tree.getSelectedNode();
    if (null == current) {
      JOptionPane.showMessageDialog(null, "Please select a node first");
      return;
    }

    String content = ((GRObject) current.getUserObject()).getContent();
    //String content = (String) current.getUserObject();
    if (content.startsWith("[UNDEFINED")) {
      JOptionPane.showMessageDialog(null, "method is not defined yet");
      return;
    }
    if (content.startsWith("{Goal")) {
      JOptionPane.showMessageDialog(null, "No method built for this goal");
      return;
    }    
    String name = tree.getSelectedName();
    if (name!= null) name = name.trim();
    if (name == null||name.equals("NIL"))
      JOptionPane.showMessageDialog(null, "No method built for this goal");
    else {
      
      if (mainPanel != null)
      mainPanel.listPanel.setSelectedNode(name);
    }
  }

  class partialMatchListener implements ActionListener {
    public void actionPerformed (ActionEvent e) {
      partialMatch();
    }
  }

  public void partialMatch() {
    partialMatchFrame gf = new partialMatchFrame(es, thePSPanel);
  }

  class grNodeSelectListener implements TreeSelectionListener {
    public void valueChanged(TreeSelectionEvent e) {
      expandableTreeNode current = tree.getSelectedNode();
      String content = ((GRObject) current.getUserObject()).getContent();
      //String content = (String) current.getUserObject();
      if (content.startsWith("[UNDEFINED")) {
        int result = JOptionPane.showConfirmDialog(null, "Do you want to define the method?");
      
        if (result == JOptionPane.YES_OPTION && gPanel != null) {
	  System.out.println(" selected node:"+current.getID());
	  gPanel.setSelectedNode (current.getID());
	  gPanel.createMethod();
        }
        else if(result == JOptionPane.NO_OPTION)
	JOptionPane.showMessageDialog(null, "well, you may want to modify/add other methods then.");
      }
      /*else {
	methodName = current.getID();
	if (methodName.equals("") || methodName == null) {
	  JOptionPane.showMessageDialog(null, "well, there is no method defined for this node");
	  return;
	}
	int result = JOptionPane.showConfirmDialog(null, "Do you want to modify the method?");
      
        if (result == JOptionPane.YES_OPTION && thePSPanel != null) {
	  thePSPanel.EditMethod (methodName);
	  
	}
      }*/
    }
  }

  public static void main(String[] args) { 
    ExpectSocketAPI es = new ExpectSocketAPI();
    //GRPanel tpanel = new GRPanel("allRfml",es, null, null);
    GRPanel tpanel = new GRPanel("method-relation",es, null, null);
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
