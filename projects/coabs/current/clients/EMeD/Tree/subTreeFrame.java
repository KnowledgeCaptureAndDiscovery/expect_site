//File: subTreeFramke.java
//
// Copyright (C) 1998 by Jihie Kim
// All Rights Reserved
//

package Tree;
import javax.swing.*;
import java.util.Enumeration;
import java.awt.event.*;
import java.awt.BorderLayout;
public class subTreeFrame extends JFrame {
  expandableTree tree;
  JButton okButton = new JButton("OK");
  public subTreeFrame (expandableTreeNode node) {
    super("Sub Tree");
    System.out.println("new tree:"+(String)node.getUserObject());
    getContentPane().setLayout(new BorderLayout());
    /*
    expandableTreeNode newNode = 
      new expandableTreeNode ((String)node.getUserObject());
    copySubTree(node, newNode);
    tree = new expandableTree(newNode); */
    tree = new expandableTree(node);
    tree.setCellRenderer(new expectTreeCellRenderer());
    getContentPane().add("Center",new expandableTreePanel(tree)); 
    okButton.addActionListener(new okListener());
    getContentPane().add("South",okButton);
    addWindowListener(new WindowAdapter() {
        public void windowClosing(WindowEvent e) {
	  setVisible(false);
	  dispose();
        }
    });
    setSize(500,300);
    setLocation(150,0);
    pack();
    setVisible(true);
  }
  class okListener implements ActionListener {
    public void actionPerformed (ActionEvent e) {
      setVisible(false);
      dispose();
    }
  }

  public void copySubTree (expandableTreeNode node,
			   expandableTreeNode newNode) {
    Enumeration children = node.children();
    while (children.hasMoreElements()) {
      expandableTreeNode child = (expandableTreeNode) children.nextElement();
      expandableTreeNode newChild = new expandableTreeNode ((String)child.getUserObject());
      newChild.setID (child.getID());
      newNode.add(newChild);
      copySubTree(child, newChild);
    }
  }
}
