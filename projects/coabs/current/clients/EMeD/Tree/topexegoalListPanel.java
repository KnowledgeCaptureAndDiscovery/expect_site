//File: resultPanel.java
//
// Copyright (C) 1998 by Jihie Kim
// All Rights Reserved
//

package Tree;
import Connection.ExpectSocketAPI;
import javax.swing.*;
import java.awt.event.*;
import java.awt.BorderLayout;
import java.awt.Font;
public class topexegoalListPanel extends JPanel {
  private ExpectSocketAPI es;
  expandableTree tree;
  expandableTreeNode root;
  expandableTreeModel treeModel;

  private JButton refreshButton;
  public topexegoalListPanel(ExpectSocketAPI theServer) {
    es = theServer;
    setLayout(new BorderLayout());
    String xmlInput = es.getEXETopGoals();
    goalRenderer gr = new goalRenderer(xmlInput);
    JTextArea ta = new JTextArea(gr.getMessagesAsString(),20,50);
    ta.setFont(new Font("Dialog", Font.BOLD, 12));
    JScrollPane scrollPane = new JScrollPane(ta);
    
    add("Center",scrollPane);
  }

  
  
  
  public static void main(String[] args) {
      JFrame frame = new JFrame("Top Level Execution Goal");
      ExpectSocketAPI es = new ExpectSocketAPI();
      frame.addWindowListener(new WindowAdapter() {
        public void windowClosing(WindowEvent e) {
                  System.exit(0);
        }
      });
      
      frame.getContentPane().add("Center", new topexegoalPanel(es));
      frame.setSize(800, 400);
      frame.setVisible(true);
    }
 
}
