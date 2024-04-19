//File: messagePanel.java
//
// Copyright (C) 1998 by Jihie Kim
// All Rights Reserved
//

package Tree;
import Connection.*;
import javax.swing.*;
import java.awt.event.*;
import java.awt.*;
import javax.swing.event.TreeSelectionListener;
import javax.swing.event.TreeSelectionEvent;
import experiment.*;
import MethodEditor;
import CritiqueWizard;
import InstanceEditor;
import java.util.*;

public class directoryPanel extends JPanel {
  ExpectSocketAPI es;
  expandableTree tree;
  expandableTreeNode root;
  expandableTreeModel treeModel;
  JPanel mainPanel;
  
  JPanel buttons;
  private JButton MethodRelationErrorsButton;
  private JButton refreshButton;
  private JButton loadButton;
  private String expectMessages = "";
  private String MethodRelationMessages = "";
  private JPanel MethodRelationPanel;
  private JTextArea ta;
  private JTabbedPane tabbedPane;
  boolean useNLEditor = false;
  CritiqueWizard wizard = null;  
  String source,content,lispfile;
  private directoryPanel mp;
  String origString;
  public directoryPanel(ExpectSocketAPI theServer,
		      CritiqueWizard w,
		      boolean useNL) {
    es = theServer;
    mp = this;
    useNLEditor = useNL;wizard = w;

    setLayout(new BorderLayout());
    //String xmlInput = es.getAllMessages();
    String xmlInput = es.getSysDir();
    //System.out.println("xml message input:"+xmlInput+":");
    directoryListRenderer mr = new directoryListRenderer(xmlInput);
    root = mr.getMessagesAsTreeNode();
    treeModel = new expandableTreeModel(root);
    tree = new expandableTree(treeModel);
    //tree.setCellRenderer(new messageListCellRenderer());
    //expectMessages = mr.getMessagesAsString();
    //saveData.record("Agenda:"+expectMessages);
    
    JScrollPane scrollPane = new JScrollPane(tree);
    scrollPane.setPreferredSize(new Dimension(600,600));
    tree.expandTree();
    tree.addTreeSelectionListener(new dirNodeSelectListener());
    //scrollPane.addTab("Organize errors by source", new messagePanel(es, null,false));
    add("Center",scrollPane);
    
    
   
    buttons = new JPanel();
    loadButton = new JButton ("Load System");
    buttons.add(loadButton);
    loadButton.addActionListener(new loadListener());
    
    add("South",buttons);

  }

  
  class dirNodeSelectListener implements TreeSelectionListener 
  {
  	
  	public void valueChanged(TreeSelectionEvent e)
  	{
  		
  	   expandableTreeNode current = tree.getSelectedNode();
       origString = (String) current.getUserObject();
       
       StringTokenizer parseOrig = new StringTokenizer(origString,".");
       //System.out.println(content.nextToken());
       String temp = parseOrig.nextToken();
       String chkLisp = parseOrig.nextToken();
       if(chkLisp.equals("lisp"))
       {
       
       parseOrig = new StringTokenizer(origString,".");
       origString = parseOrig.nextToken();
       
       }
       
       
       System.out.println("In dir");
      //if (!content.startsWith("== ")) return;
      //String id = (String) current.getID();
      //String type = (String) current.getType();
  	  int choice;
  	  //choice = JOptionPane.showConfirmDialog(null, "Do you want to make this the top level execution goal?");
  		// call function to set the top level goal */
      
    }
  }		
  
  class loadListener implements ActionListener{
  	
  	public void actionPerformed(ActionEvent e)
  	{
  	  System.out.println(origString);
  	  es.loadSysDir(origString);	
  	  JFrame frame = new JFrame("");
      //ExpectSocketAPI es = new ExpectSocketAPI();
      frame.addWindowListener(new WindowAdapter() {
        public void windowClosing(WindowEvent e) {
                  System.exit(0);
        }
      });
      
      frame.getContentPane().add("Center", new domaindirectoryPanel(es, null, false));
      frame.setSize(400, 400);
      frame.setVisible(true);
   
 
  	
  	
  	}
  	
  }		 
  
  
  /*  to separate method-relation errors from others
  public messagePanel(ExpectSocketAPI theServer) {
    es = theServer;
    mainPanel = new JPanel();
    String xmlInput = es.getOtherMessages();
    messageListRenderer mr = new messageListRenderer(xmlInput);

    expectMessages = mr.getMessagesAsString();
    saveData.record("Agenda:"+expectMessages);
    ta = new JTextArea(expectMessages,20,50);
    JScrollPane scrollPane = new JScrollPane(ta);
    
    mainPanel.add(scrollPane);
    add(mainPanel,BorderLayout.CENTER);
    
    MethodRelationErrorsButton = new JButton ("Show MethodRelation Errors");
    MethodRelationErrorsButton.addActionListener(new MethodRelationErrorsListener());
    add(MethodRelationErrorsButton,BorderLayout.SOUTH);
  }
  */

  
  
  public static void main(String[] args) {
      JFrame frame = new JFrame("Acquisition Analyzer");
      ExpectSocketAPI es = new ExpectSocketAPI();
      frame.addWindowListener(new WindowAdapter() {
        public void windowClosing(WindowEvent e) {
                  System.exit(0);
        }
      });
      
      frame.getContentPane().add("Center", new directoryPanel(es, null, false));
      frame.setSize(400, 400);
      frame.setVisible(true);
    }
 
}
