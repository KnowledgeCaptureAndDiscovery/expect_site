//File: treePanel.java
//
// Copyright (C) 1998 by Jihie Kim
// All Rights Reserved
//

package Tree;

import java.io.PrintStream;
import com.sun.java.swing.tree.*;
import com.sun.java.swing.JFrame;
import com.sun.java.swing.JPanel;
import com.sun.java.swing.JScrollPane;
import com.sun.java.swing.JButton;
import com.sun.java.swing.JComponent;
import java.awt.event.MouseListener;
import java.awt.event.MouseEvent;
import java.awt.event.ActionListener;
import java.awt.event.ActionEvent;
import java.awt.event.WindowEvent;
import java.awt.event.WindowAdapter;
import java.awt.*;
import com.sun.java.swing.JOptionPane;
import java.util.Stack;

import Connection.ExpectServer;
import xml2jtml.methodDefRenderer;

import ExpectWindowPanel;

public class treePanel extends JPanel {
  private JScrollPane sp;
  private treeRenderer app;
  private expandableTree tree;
  private JComponent buttons;
  private JButton selectButton;
  private JButton showButton;
  private String xmlInput;
  private ExpectServer es;
  private String type;
  private JButton copyCapButton;
  ExpectWindowPanel thePanel;
	 
  public treePanel(String Stype, ExpectServer theServer,
		   ExpectWindowPanel rootPanel) {
    es = theServer;
    thePanel = rootPanel;
    type = Stype;
    if (type.equals("method-capability"))
      xmlInput = es.getMethodCapabilityTree(type); 
    else {
      System.out.println("invalid type:"+type);
    }
    app = new treeRenderer(xmlInput);
    tree = app.getTree();
    tree.setCellRenderer(new expectTreeCellRenderer());
    sp = new JScrollPane(tree);
    if (type.equals("method-capability"))
      tree.expandTree();

    setLayout(new BorderLayout());
    showButton = new JButton("Show method");
    showButton.addActionListener (new showListener());
    selectButton = new JButton("Select for editing");
    selectButton.addActionListener (new selectListener());
    copyCapButton = new JButton("Copy Capability");
    copyCapButton.addActionListener(new copyCapListener());

    buttons = new JPanel();
    buttons.setLayout(new FlowLayout(FlowLayout.LEFT));
    buttons.add(showButton);
    buttons.add(selectButton);
    buttons.add(copyCapButton);
    add("Center",sp);
    add("South",buttons);
  }

  class showListener implements ActionListener {
    public void actionPerformed (ActionEvent e) {
      showMethod();
    }
  }

  private void showMethod() {
    String name = tree.getSelectedName();
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

  class selectListener implements ActionListener {
    public void actionPerformed (ActionEvent e) {
      select();
    }
  }

  private void select() {
    String name = tree.getSelectedName();
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
    String name = tree.getSelectedName();

    if (!(null== name || name.equals(""))) {
      String simpleGoal = es.getSimplifiedGoal(name);
      System.out.println("goal desc:" + simpleGoal + "for :"+ name);
      thePanel.addCopiedGoal (simpleGoal);
      thePanel.addSearchedMethod(name);
    }
  }
  public static void main(String[] args) { 
    ExpectServer es = new ExpectServer();
    treePanel tpanel = new treePanel("method-relation",es,null);
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
