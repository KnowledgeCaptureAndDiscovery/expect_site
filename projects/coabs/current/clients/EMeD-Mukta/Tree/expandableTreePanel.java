//File: treePanel.java
//
// Copyright (C) 1998 by Jihie Kim
// All Rights Reserved
//

package Tree;

import java.io.PrintStream;
import javax.swing.tree.*;
import javax.swing.*;
import java.awt.event.*;
import java.awt.*;
import javax.swing.event.*;

public class expandableTreePanel extends JPanel
implements MouseListener {
  JScrollPane scrollpane;
  //JButton cut;
  boolean selectPopUp;
  JPopupMenu popup;
  public expandableTreePanel(expandableTree tree) {
    setLayout(new BorderLayout());
    addMouseListener(this);
    scrollpane = new JScrollPane(tree);
    //cut = new JButton("Get Sub-Tree");
    //cut.addActionListener(new getSubTreeListener(tree));
    add("Center",scrollpane);
    //add("North",cut);
    popup = new JPopupMenu();
    JMenuItem menuItem = popup.add("Get Sub-Tree");
    menuItem.addActionListener(new getSubTreeListener(tree));
    //scrollpane.add(popup);
    add("North",popup);
  }

  class getSubTreeListener implements ActionListener {
    expandableTree treeDisplayed=null;
    JFrame PopupFrame;
    getSubTreeListener (expandableTree tree) {
      treeDisplayed = tree;
    }
    public void actionPerformed (ActionEvent e) {
      if (treeDisplayed != null && treeDisplayed.getSelectedNode() != null) {
	//new subTreeFrame (treeDisplayed.getSelectedNode());
	PopupFrame = new JFrame("Sub Tree");
	expandableTree newTree =
	  new expandableTree(treeDisplayed.getSelectedNode());
	newTree.expandTree();
	newTree.setCellRenderer(new expectTreeCellRenderer());
	JButton okButton = new JButton("OK");
	okButton.addActionListener(new okListener());
	PopupFrame.getContentPane().add("Center",
					new expandableTreePanel(newTree));
	PopupFrame.getContentPane().add("South", okButton);
	PopupFrame.addWindowListener(new WindowAdapter() {    
	  public void windowClosing(WindowEvent e) {
	    PopupFrame.setVisible(false);
	    PopupFrame.dispose();
	  }
	});
	PopupFrame.setSize(500,300);
	PopupFrame.setLocation(150,0);
	PopupFrame.setVisible(true);
      }
    }
    class okListener implements ActionListener {
      public void actionPerformed (ActionEvent e) {
	PopupFrame.setVisible(false);
	PopupFrame.dispose();
      }
    }
  }
  public void mousePressed(MouseEvent e)  {}
  public void mouseClicked(MouseEvent e)
  { 
    if (selectPopUp == true) {
      selectPopUp = false;
    }
    else {
      int x = e.getX();
      int y = e.getY();
      JMenuItem item = (JMenuItem) e.getComponent();
      System.out.println(item.getText());
    }
  }
  public void mouseReleased(MouseEvent e)
  {
  }
  
  public void mouseEntered(MouseEvent e)
  {
  }
  
  public void mouseExited(MouseEvent e)
  {  } 

  public void processMouseEvent(MouseEvent e) {
    if (e.isPopupTrigger()) { 
      int x = e.getX();
      int y = e.getY();
      popup.show(e.getComponent(), x, y);
      selectPopUp = true;
    }
  }
    

}
