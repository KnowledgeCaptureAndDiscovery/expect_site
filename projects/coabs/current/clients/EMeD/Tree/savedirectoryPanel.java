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

public class savedirectoryPanel extends JPanel {
  ExpectSocketAPI es;
  expandableTree tree;
  expandableTreeNode root;
  expandableTreeModel treeModel;
  JPanel mainPanel;
  
  JPanel buttons;
  private JButton MethodRelationErrorsButton;
  private JButton refreshButton;
  private JButton saveButton;
  private String expectMessages = "";
  private String MethodRelationMessages = "";
  private JPanel MethodRelationPanel;
  //private JTextArea ta;
  private JTabbedPane tabbedPane;
  boolean useNLEditor = false;
  CritiqueWizard wizard = null;  
  String source,content,lispfile;
  private savedirectoryPanel mp;
  String origString,saveString="";
  JTextArea ta = new JTextArea(1,10);
  
  public savedirectoryPanel(ExpectSocketAPI theServer,
		      CritiqueWizard w,
		      boolean useNL) {
    es = theServer;
    mp = this;
    useNLEditor = useNL;wizard = w;

    setLayout(new BorderLayout());
    //String xmlInput = es.getAllMessages();
    String xmlInput = es.getLoadSaveDir();
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
    JLabel saveLbl = new JLabel("File Name:"); 
    

    
    /*if(saveString.equals(""))
    {
    	saveString = saveString + ".expt";
    }
    else
    saveString = "";	*/
    
    saveButton = new JButton ("Save");
    
    buttons.add(saveLbl);
    buttons.add(ta);
    buttons.add(saveButton);
    saveButton.addActionListener(new saveListener());
    
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
       
       saveString = temp+"."+"expt";
       
       
       System.out.println("In dir");
      //if (!content.startsWith("== ")) return;
      //String id = (String) current.getID();
      //String type = (String) current.getType();
  	  int choice;
  	  //choice = JOptionPane.showConfirmDialog(null, "Do you want to make this the top level execution goal?");
  		// call function to set the top level goal */
      
    }
  }		
  
  class saveListener implements ActionListener{
  	
  	public void actionPerformed(ActionEvent e)
  	{
  	  
  	  String temp = ta.getText();
    //saveString = ta.getText();
      System.out.println("Save :"+temp);
  	  if(temp.equals(""))
  	  {
  	  System.out.println(saveString);
  	  es.saveUserMethods(saveString);	
      }
  
      else
      {
      	saveString = "/nfs/isd2/ntubman/secondpsm/load-and-save/"+temp+".expt";
      	System.out.println(saveString);
      	es.saveUserMethods(saveString);	
      }	
 
  	
  	
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
      JFrame frame = new JFrame("Save");
      ExpectSocketAPI es = new ExpectSocketAPI();
      frame.addWindowListener(new WindowAdapter() {
        public void windowClosing(WindowEvent e) {
                  System.exit(0);
        }
      });
      
      frame.getContentPane().add("Center", new savedirectoryPanel(es, null, false));
      frame.setSize(400, 400);
      frame.setVisible(true);
    }
 
}
