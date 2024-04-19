//File: treePanel.java
//
// Copyright (C) 1998 by Jihie Kim
// All Rights Reserved
//

package Tree;
import Connection.ExpectServer;
import com.sun.java.swing.*;
import java.awt.event.*;
import java.awt.BorderLayout;

public class resultPanel extends JPanel {
  private ExpectServer es;
  expandableTree tree;
  expandableTreeNode root;
  expandableTreeModel treeModel;
  JPanel mainPanel;

  private JButton refreshButton;
  public resultPanel(ExpectServer theServer) {
    es = theServer;
    mainPanel = new JPanel();
    String xmlInput = es.getTopResult("");
    messageListRenderer mr = new messageListRenderer(xmlInput);
    root = mr.getMessagesAsTreeNode();
    treeModel = new expandableTreeModel(root);
    tree = new expandableTree(treeModel);
    tree.setCellRenderer(new messageListCellRenderer());

    JTextArea ta = new JTextArea(mr.getMessagesAsString(),20,50);
    JScrollPane scrollPane = new JScrollPane(ta);
    
    //mainPanel.add(tree);
    mainPanel.add(scrollPane);
    add(mainPanel);
  }

  public static void main(String[] args) {
      JFrame frame = new JFrame("All messages");
      ExpectServer es = new ExpectServer();
      frame.addWindowListener(new WindowAdapter() {
        public void windowClosing(WindowEvent e) {
                  System.exit(0);
        }
      });
      
      frame.getContentPane().add("Center", new resultPanel(es));
      frame.setSize(800, 400);
      frame.setVisible(true);
    }
 
}
