//File: showNodeFrame.java
//
// Copyright (C) 1998 by Jihie Kim
// All Rights Reserved
//
package PSTree;

import java.awt.BorderLayout;
import java.awt.TextArea;
import java.awt.event.ActionListener;
import java.awt.event.ActionEvent;
import java.awt.event.KeyListener;
import java.awt.event.KeyEvent;
import java.awt.event.WindowListener;
import java.awt.event.WindowEvent;
import java.awt.GridLayout;
import java.awt.BorderLayout;
import javax.swing.JFrame;
import javax.swing.JPanel;
import javax.swing.JButton;
import Connection.*;

import javax.swing.JOptionPane;
import javax.swing.JScrollPane;
import Tree.expandableTreeNode;
import Tree.expandableTree;

public class showNodeFrame extends JFrame 
implements WindowListener, KeyListener{

  JButton okButton;
  JPanel buttons;
  String type;
  String[]      confirm = {"OK"};
  String defName;
  expandableTree tree;
  expandableTreeNode node;
  JScrollPane sp;
  public static void main(String[] args) {
    //ExpectSocketAPI server = new ExpectSocketAPI();
    //JFrame frame = new ViewFrame("Concept", "jjj", "(Defconcept jjj)");
  }


  public showNodeFrame(expandableTreeNode theNode) {
    super("Node Details");
    node = new expandableTreeNode();
    node.setID (theNode.getID());
    node.setUserObject(theNode.getUserObject());
    tree = new expandableTree(node);
    tree.setCellRenderer(new GRCellRenderer());
    sp = new JScrollPane(tree);
    okButton = new JButton("ok");
    
    okButton.addActionListener(new okListener());
    buttons = new JPanel();//new GridLayout(1,0));
    buttons.add(okButton);
    getContentPane().setLayout(new BorderLayout());
    getContentPane().add("Center",sp);
    getContentPane().add("South",buttons);
    addWindowListener(this);
    setSize(700,250);
    setLocation(150,150);
    setVisible(true);
    
  }
  
  class okListener implements ActionListener {
    public void actionPerformed(ActionEvent e) {   
      setVisible(false);
      dispose();
    }
  }
  
  public void windowClosed(WindowEvent event){}
  public void windowDeiconified(WindowEvent event){}
  public void windowIconified(WindowEvent event){}
  public void windowActivated(WindowEvent event){}
  public void windowDeactivated(WindowEvent event){}
  public void windowOpened(WindowEvent event){}
  
  public void windowClosing(WindowEvent event)
  {  
    setVisible(false);
    dispose();
  }

  public void keyTyped(KeyEvent e)
  {
  }

  public void keyPressed(KeyEvent e)
  {
  }

  public void keyReleased(KeyEvent e)
  {
  }
}
