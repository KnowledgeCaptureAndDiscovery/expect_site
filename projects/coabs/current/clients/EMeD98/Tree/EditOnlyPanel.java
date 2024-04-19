//File: treePanel.java
//
// Copyright (C) 1998 by Jihie Kim
// All Rights Reserved
//

/*

   delete: if it is processed, delete in interface and in server
           if not, delete in interface
   add new:  add new method, and check errors,
             if it is rejected, it will be displayed only in the interface
   copy and create: add new method, and check errors,
             if it is rejected, it will be displayed only in the interface
             if it is rejected because the same name is used by others,
                it will be displayed only in the interface
   modify: modify  ==> not allowed
   Always make sure the names are different

   reload button will load all methods using, 
     add-or-change-method --> process-store-plan 
	   */

package Tree;

import java.util.*;
import java.io.*;
import com.sun.java.swing.*;
import com.sun.java.swing.text.*;
import com.sun.java.swing.tree.*;
import com.sun.java.swing.border.*;
import java.awt.*;
import java.awt.event.*;

import Connection.ExpectServer;
import xml2jtml.methodDefRenderer;
import ExpectPanel;
import TestWindowPanel;

public class EditOnlyPanel extends JPanel {
  private expandableTreeModel treeModel;
  private expandableTree tree;
  private JComponent buttons;

  private JPanel memoPanel;
  private JLabel memoLabel;
  private JTextArea memoArea;
  private JComponent memoAggregate;

  private JComponent editButtons;
  private JLabel  editLabel;
  private JButton addNewButton;
  private JButton copyAndCreateButton;
  private JButton deleteButton;
  private JButton modifyButton;
  private JButton reloadButton;


  private ExpectServer es;

  private expandableTreeNode root; // root of the tree
  private expandableTreeNode userMethodsRoot;
  private expandableTreeNode systemMethodsRoot;
  private expandableTreeNode nodeCut; // node cut beforehand

  // these are for postprocess editiong
  private expandableTreeNode currentNode = null; // node currently processed
  private int theIndex;
  private expandableTreeNode theParent;
  private String theOperation;

  JComponent  errorAggregate;
  JTextArea   errorMessageArea;
  JPanel expectMessagePanel;

  TestWindowPanel thePanel = null;

  public EditOnlyPanel(ExpectServer theServer, TestWindowPanel parent) {
    thePanel = parent;
    expandableTreeNode top = new expandableTreeNode("Method List");
    treeModel = new expandableTreeModel(top);
    tree = new expandableTree(treeModel);
    tree.setCellRenderer(new methodListCellRenderer());
    es = theServer;

    methodListRenderer thisRenderer = 
      new methodListRenderer(theServer,"User Defined Methods");
    String xmlInput = es.getUserDefinedMethodNameList("");

    userMethodsRoot = thisRenderer.getRootOfMethodTree(xmlInput);
    treeModel.insertNodeInto(userMethodsRoot, top, 0);

    thisRenderer = 
      new methodListRenderer(theServer,"System Defined Methods");
    xmlInput = es.getSystemDefinedMethodNameList("");
    systemMethodsRoot = thisRenderer.getRootOfMethodTree(xmlInput);
    treeModel.insertNodeInto(systemMethodsRoot, top, 0);

    tree.expandPath(tree.findPath("User Defined Methods"));
    root = (expandableTreeNode) treeModel.getRoot();
    JScrollPane scrollPane = new JScrollPane(tree);
    setLayout(new BorderLayout());


    buttons = new JPanel();
    buttons.setLayout(new GridLayout(0,1));
    editButtons = new JPanel();
    editButtons.setLayout(new GridLayout(0,1));
    editLabel = new JLabel("Edit or Reload Methods    :");
    editButtons.add(editLabel);
    

    addNewButton = new JButton("Add new method");
    addNewButton.addActionListener(new addNewListener());
    editButtons.add(addNewButton);

    copyAndCreateButton = new JButton("Copy and Create");
    copyAndCreateButton.addActionListener(new copyAndCreateListener());
    editButtons.add(copyAndCreateButton);

    modifyButton = new JButton("Modify method");
    modifyButton.addActionListener(new modifyListener());
    editButtons.add(modifyButton);

    deleteButton = new JButton ("Delete method");
    deleteButton.addActionListener(new deleteListener());
    editButtons.add(deleteButton);

    reloadButton = new JButton ("Load All Methods");
    reloadButton.addActionListener(new reloadListener());
    editButtons.add(reloadButton);


    buttons.add(editButtons);

    //JSplitPane splitPane = new JSplitPane(JSplitPane.HORIZONTAL_SPLIT, 
    //				  scrollPane, buttons);
    //splitPane.setContinuousLayout(true);
    //splitPane.setPreferredSize(new Dimension(400, 100));
    //add("Center", splitPane);
    add("Center",scrollPane);
    add("East",buttons);


    errorMessageArea = new JTextArea(" Please, Continue Editing .. ",5,80);
    errorMessageArea.setLineWrap(true);
    errorAggregate = new JScrollPane(errorMessageArea);
    errorAggregate.setBorder(new EtchedBorder()); 
    expectMessagePanel =new JPanel(); 
    expectMessagePanel.setBorder(BorderFactory.createTitledBorder(new 
			       TitledBorder(new LineBorder(Color.black, 1),
					    "EXPECT message",
					    TitledBorder.LEFT,
					    TitledBorder.TOP,
					    new Font("Courier", Font.BOLD, 16))));
    expectMessagePanel.setLayout(new BorderLayout());
    expectMessagePanel.add(errorAggregate, BorderLayout.CENTER);
    add("South",expectMessagePanel);

  }

  protected expandableTreeNode getSelectedNode() {
    TreePath   selPath = tree.getSelectionPath();

    if(selPath != null)
      return (expandableTreeNode)selPath.getLastPathComponent();
    return null;
  }

  protected expandableTreeNode createNewNode(String name) {
    return new expandableTreeNode(name);
  }



  class addNewListener implements ActionListener
  {
    public void actionPerformed(ActionEvent e) {
      addNew();
    }
  } 

  private void addNew() {
    int               newIndex;
    expandableTreeNode          lastItem = getSelectedNode();
    expandableTreeNode          parent;

      /* Determine where to create the new node. */
      if ((lastItem == null) || (lastItem == root) || 
	  (lastItem == userMethodsRoot) || (lastItem == systemMethodsRoot)) {
	parent = userMethodsRoot;
	newIndex = treeModel.getChildCount(parent);
      }
      else {
	parent = (expandableTreeNode)lastItem.getParent();
	newIndex = parent.getIndex(lastItem) +1;
      }
      String definition = "((name method-name)\r\n"+"(capability )\r\n"+"(result-type )\r\n";
      definition = definition + "(method )\r\n" +")";
      // definition = definition + "(result-refiner )\r\n" + "(primitivep ))";
      theParent = parent;
      theIndex = newIndex;
      theOperation = "addNew";
      EditOnlyFrame ed = new EditOnlyFrame("Create", "method-name", 
					   definition, es, this);
  }

  public void editPostProcess (String defName, String def) {
    
    if ( def == null) return;
    if (theOperation.equals("addNew")) {// create new node
      expandableTreeNode node = createNewNode(def);
      node.setID(defName);
      if (null== theParent) theParent = userMethodsRoot;
      treeModel.insertNodeInto(node, theParent, theIndex);
    } 
    else if (theOperation.equals("modify")) {// modify existing node

	currentNode.setUserObject(def);
	currentNode.setID(defName);
	treeModel.nodeChanged(currentNode);
	currentNode = null;
    }
    else { // modify and create a new node after the selected node
      expandableTreeNode node = createNewNode(def);
      node.setID(defName);
      expandableTreeNode parent =  (expandableTreeNode)currentNode.getParent();
      treeModel.insertNodeInto(node, parent, parent.getIndex(currentNode)+1);
    }

  }

  class copyAndCreateListener implements ActionListener
  {
    public void actionPerformed(ActionEvent e) {
      copyAndCreate();
    }
  }

  private void copyAndCreate () {      
    expandableTreeNode          lastItem = getSelectedNode();

    if (null == lastItem) return;
    String name = lastItem.getID();
      
    String definition = (String) lastItem.getUserObject();
    currentNode = lastItem;
    theParent = (expandableTreeNode)lastItem.getParent();
    theIndex = theParent.getIndex(lastItem) +1;
    theOperation = "copyAndCreate";
    EditOnlyFrame ed = new EditOnlyFrame("CopyAndCreate", name, 
					 definition, es, this);
  }

  class modifyListener implements ActionListener
  {
    public void actionPerformed(ActionEvent e) {
      modify();
    }
  }

  private void modify() {      
    expandableTreeNode          lastItem = getSelectedNode();

    if (null == lastItem) return;
    String name = lastItem.getID();
      
    String definition = (String) lastItem.getUserObject();
    currentNode = lastItem;
    theParent = (expandableTreeNode)lastItem.getParent();
    theIndex = theParent.getIndex(lastItem) +1;
    theOperation = "modify";
    EditOnlyFrame ed = new EditOnlyFrame("Modify", name, 
					 definition, es, this);
  }

  
  class deleteListener implements ActionListener
  {
    public void actionPerformed(ActionEvent e) {
      delete();
    }
  }

  private void delete() {
    expandableTreeNode          lastItem = getSelectedNode();

    if (null == lastItem) return;

    treeModel.removeNodeFromParent(lastItem);
    
   
  }

  class reloadListener implements ActionListener
  {
    public void actionPerformed(ActionEvent e) {
      loadAll();
    }
  }

  public void showMessage(String messages) {     

  }

  private void loadAll () {
    //es.deleteAllMethods("");
    loadMethods (userMethodsRoot);
  }

  public void loadMethods(expandableTreeNode node) {
    String content = (String) node.getUserObject();
    if (content.indexOf("capability")>=0) {// check if method: should be changed
      es.editMethod(content);
    }
    int NofChild = node.getChildCount();
    for (int i = 0; i < NofChild; i++) {
      loadMethods ((expandableTreeNode) node.getChildAt(i));
    }
  }


  public static void main(String[] args) {
      JFrame frame = new JFrame("method list Frame");
      ExpectServer es = new ExpectServer();
      frame.addWindowListener(new WindowAdapter() {
        public void windowClosing(WindowEvent e) {
                  System.exit(0);
        }
      });
      
      frame.getContentPane().add("Center", new EditOnlyPanel(es,null));
      frame.setSize(600, 500);
      frame.setVisible(true);
    }
 
    
}
