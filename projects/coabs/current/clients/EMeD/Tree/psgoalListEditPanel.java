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
import javax.swing.event.TreeSelectionListener;
import javax.swing.event.TreeSelectionEvent;
import Connection.*;
import MethodApplier; 

public class psgoalListEditPanel extends JPanel {
  private ExpectSocketAPI es;
  expandableTree tree;
  expandableTreeNode root;
  expandableTreeModel treeModel;
  LispSocketAPI lc;
  private JButton refreshButton;
  
  public psgoalListEditPanel(ExpectSocketAPI theServer) {
    es = theServer;
    lc = (LispSocketAPI)es;
    setLayout(new BorderLayout());
    String xmlInput = es.getPSTopGoals();
    goalRenderer gr = new goalRenderer(xmlInput);
    root = gr.getMessagesAsTreeNode();
    treeModel = new expandableTreeModel(root);
    tree = new expandableTree(treeModel);
    //tree.setCellRenderer(new messageListCellRenderer());
    //expectMessages = mr.getMessagesAsString();
    //saveData.record("Agenda:"+expectMessages);
    
    JScrollPane scrollPane = new JScrollPane(tree);
    //scrollPane.setPreferredSize(new Dimension(600,600));
    tree.expandTree();
    tree.addTreeSelectionListener(new changeGoalListener());
    //scrollPane.addTab("Organize errors by source", new messagePanel(es, null,false));
    add("Center",scrollPane);
    
    
    
    /*JTextArea ta = new JTextArea(gr.getMessagesAsString(),20,50);
    ta.setFont(new Font("Dialog", Font.BOLD, 12));
    JScrollPane scrollPane = new JScrollPane(ta);
    
    add("Center",scrollPane);*/
  }

 


  class changeGoalListener implements TreeSelectionListener 
  {
  	
  	public void valueChanged(TreeSelectionEvent e)
  	{
  		
  	   expandableTreeNode current = tree.getSelectedNode();
      String content = (String) current.getUserObject();
      System.out.println("In change goal");
      //if (!content.startsWith("== ")) return;
      //String id = (String) current.getID();
      //String type = (String) current.getType();
  	  int choice;
  	  choice = JOptionPane.showConfirmDialog(null, "Do you want to apply this goal?");
  		// call function to set the top level goal 
      //JOptionPane.setVisible(false);
       MethodApplier app = new MethodApplier(content, lc);
       //MethodApplier app = new MethodApplier(content, lc,true);
      //es.setEXETopGoal(content);
    }
  }		
  
  
  public static void main(String[] args) {
      JFrame frame = new JFrame("Top Level Execution Goal");
      ExpectSocketAPI es = new ExpectSocketAPI();
      frame.addWindowListener(new WindowAdapter() {
        public void windowClosing(WindowEvent e) {
                  System.exit(0);
        }
      });
      
      frame.getContentPane().add("Center", new psgoalListEditPanel(es));
      frame.setSize(800, 400);
      frame.setVisible(true);
    }
 
}
