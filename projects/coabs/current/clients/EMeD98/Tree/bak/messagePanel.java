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

public class messagePanel extends JPanel {
  private ExpectServer es;
  expandableTree tree;
  expandableTreeNode root;
  expandableTreeModel treeModel;
  JPanel mainPanel;
  
  private JButton otherErrorsButton;
  private JButton refreshButton;
  private String expectMessages = "";
  private String otherMessages = "";
  private JPanel otherPanel;
  private JTextArea ta;

  public messagePanel(ExpectServer theServer) {
    es = theServer;
    mainPanel = new JPanel();
    //String xmlInput = es.getAllMessages("");
    String xmlInput = es.getExpectMessages();
    System.out.println("xml input:"+xmlInput);
    messageListRenderer mr = new messageListRenderer(xmlInput);
    
    expectMessages = mr.getMessagesAsString();
    ta = new JTextArea(expectMessages,20,50);
    JScrollPane scrollPane = new JScrollPane(ta);
    
    //mainPanel.add(tree);
    mainPanel.add(scrollPane);
    add(mainPanel,BorderLayout.CENTER);
    
    /*
    refreshButton = new JButton ("Rebuild PS-tree and get error messages");
    refreshButton.addActionListener(new refreshListener());
    add(refreshButton,BorderLayout.SOUTH);
    */
    //otherPanel = new JPanel();
    otherErrorsButton = new JButton ("Show Other Errors");
    otherErrorsButton.addActionListener(new otherErrorsListener());
    //otherPanel.add(allErrorsButton);
    //add(otherPanel,BorderLayout.SOUTH);
    add(otherErrorsButton,BorderLayout.SOUTH);
  }

  class otherErrorsListener implements ActionListener {
    public void actionPerformed (ActionEvent e) {
      showOtherErrors();
    }
  }

  private void showOtherErrors() {
    String xmlInput = es.getOtherMessages();
    messageListRenderer mr = new messageListRenderer(xmlInput);
    otherMessages = mr.getMessagesAsString();
    //ta.setText(otherMessages);
    JOptionPane.showMessageDialog(null, otherMessages);
  }

  class refreshListener implements ActionListener {
    public void actionPerformed (ActionEvent e) {
      refresh();
    }
  }
  private void refresh() {
    mainPanel.removeAll();
    String xmlInput = es.getExpectMessages();
    messageListRenderer mr = new messageListRenderer(xmlInput);
    root = mr.getMessagesAsTreeNode();
    treeModel = new expandableTreeModel(root);
    tree = new expandableTree(treeModel);
    tree.setCellRenderer(new messageListCellRenderer());
    System.out.println(" new messages:"+mr.getMessagesAsString());
    JTextArea ta = new JTextArea(mr.getMessagesAsString(),20,50);
    JScrollPane scrollPane = new JScrollPane(ta);
    mainPanel.add(scrollPane);
  }
  
  public static void main(String[] args) {
      JFrame frame = new JFrame("All messages");
      ExpectServer es = new ExpectServer();
      frame.addWindowListener(new WindowAdapter() {
        public void windowClosing(WindowEvent e) {
                  System.exit(0);
        }
      });
      
      frame.getContentPane().add("Center", new messagePanel(es));
      frame.setSize(800, 400);
      frame.setVisible(true);
    }
 
}
