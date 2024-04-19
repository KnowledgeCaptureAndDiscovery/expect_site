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
   modify: modify
             if it has the same name as the old one, it will be modified.
                 if the modification fails in the server,
                    delete the existing method in the server,
                    and create dummy in client?
                    but currently, client reject it.
             if the new definition has different name, it will be rejected
                because the server cannot find the method.
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
//import ExpectPanel;
import ExpectWindowPanel;
import experiment.*;
public class methodListPanel extends JPanel {
  Dimension   origin = new Dimension(0, 0); 

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
  private JButton showErrorButton;
  private JButton reloadButton;


  private JComponent changeLookButtons;
  private JLabel  changeLookLabel;
  private JButton createLabelButton;
  private JButton cutButton;
  private JButton pasteButton;
  private JButton embraceIntoButton;

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
  JScrollPane scrollPane;
  TitledBorder tborder;

  ExpectWindowPanel thePanel = null;
  String interfaceType;
  public methodListPanel(ExpectServer theServer, 
			 ExpectWindowPanel parent,
			 String itype) {
    thePanel = parent;
    interfaceType = itype;
    expandableTreeNode top = new expandableTreeNode("Method List");
    treeModel = new expandableTreeModel(top);
    tree = new expandableTree(treeModel);
    // uncomment to make the tree editable::  tree.setEditable(true);
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
    scrollPane = new JScrollPane(tree);
    setLayout(new BorderLayout());


    buttons = new JPanel();
    buttons.setLayout(new GridLayout(0,1));
    editButtons = new JPanel();
    editButtons.setLayout(new GridLayout(0,1));
    editLabel = new JLabel("Edit Methods    :");
    editButtons.add(editLabel);
    changeLookButtons = new JPanel();
    changeLookButtons.setLayout(new GridLayout(0,1));
    changeLookLabel = new JLabel("Move or Reorganize Methods:");
    changeLookButtons.add(changeLookLabel);

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

    showErrorButton = new JButton ("Show Errors");
    showErrorButton.addActionListener(new showErrorListener());
    editButtons.add(showErrorButton);

    //reloadButton = new JButton ("Reload method");
    //reloadButton.addActionListener(new reloadListener());
    //editButtons.add(reloadButton);

    // for buttons to change look and feel
    createLabelButton = new JButton("Create Label");
    createLabelButton.addActionListener(new createLabelListener());
    changeLookButtons.add(createLabelButton);

    cutButton = new JButton ("Cut to move");
    cutButton.addActionListener(new cutListener());
    changeLookButtons.add(cutButton);

    pasteButton = new JButton("Paste After");
    pasteButton.addActionListener(new pasteListener());
    changeLookButtons.add(pasteButton);

    embraceIntoButton = new JButton("Paste Into");
    embraceIntoButton.addActionListener(new embraceIntoListener());
    changeLookButtons.add(embraceIntoButton);

    memoPanel = new JPanel();
    memoPanel.setLayout(new BorderLayout());
    memoLabel = new JLabel("User memo:");
    memoArea = new JTextArea("Check List.. \n - define methods as general as possible");
    memoArea.setLineWrap(true);
    memoAggregate = new JScrollPane(memoArea);
    memoPanel.add("North",memoLabel);
    memoPanel.add("Center",memoAggregate);
    buttons.add(memoPanel);

    //buttons.add(changeLookButtons);
    buttons.add(editButtons);

    setDoubleBuffered(true);
    JPanel tempPane = new JPanel();
    tempPane.add(scrollPane);
    JPanel tempPane2 = new JPanel();
    scrollPane.setMinimumSize(new Dimension(300,300));
    buttons.setMinimumSize(new Dimension(100,300));
    //System.out.println("Minimum size for buttons:"+buttons.getMinimumSize());

    // uncommnet for split panel:: JSplitPane splitPane = new JSplitPane(JSplitPane.HORIZONTAL_SPLIT, 
    //			  scrollPane, buttons);

    // uncommnet for split panel:: splitPane.setContinuousLayout(true);

    //splitPane.setPreferredSize(new Dimension(400, 100));
    //splitPane.getAccessibleContext().setAccessibleName("Split pane example");

    // uncommnet for split panel:: add(splitPane,BorderLayout.CENTER);

    

    add("Center",scrollPane);
    add("East",buttons);
    if (!interfaceType.equals("small")) {
    errorMessageArea = new JTextArea(" Please, Continue Editing .. ",5,80);
    //errorMessageArea.setDisabledTextColor (Color.red);
    errorMessageArea.setLineWrap(true);
    errorAggregate = new JScrollPane(errorMessageArea);
    errorAggregate.setBorder(new EtchedBorder()); 
    expectMessagePanel =new JPanel(); 
    tborder = new TitledBorder(new LineBorder(Color.black, 1),
					    "Individual Method Error",
					    TitledBorder.LEFT,
					    TitledBorder.TOP,
					    new Font("Courier", Font.BOLD, 16));
    expectMessagePanel.setBorder(BorderFactory.createTitledBorder(tborder));
    expectMessagePanel.setLayout(new BorderLayout());
    expectMessagePanel.add(errorAggregate, BorderLayout.CENTER);
    add("South",expectMessagePanel);
    }
    //add(expectMessagePanel);
  }

  protected expandableTreeNode getSelectedNode() {
    TreePath   selPath = tree.getSelectionPath();

    if(selPath != null)
      return (expandableTreeNode)selPath.getLastPathComponent();
    return null;
  }

  public void setSelectedNode (String id) {
    System.out.println("find?:"+id+":");
    TreePath selPath = tree.findPath(id);
    if (selPath != null) {
      tree.setSelectionPath(selPath);
      System.out.println("found");
      //tree.expandPath(selPath);
      //expandableTreeNode node = selPath.getLastPathComponent();
    }
  }

  protected expandableTreeNode createNewNode(String name) {
    return new expandableTreeNode(name);
  }

  
  // create a label for a group of methods
  class createLabelListener implements ActionListener {
    public void actionPerformed (ActionEvent e) {
      int               newIndex;
      expandableTreeNode          lastItem = getSelectedNode();
      expandableTreeNode          parent;
      
      saveData.record("select: creat label button");
      /* Determine where to create the new node. */
      if ((lastItem == null) || (lastItem == root)) {
	parent = userMethodsRoot;
	newIndex = 0;//treeModel.getChildCount(parent);
      }
      else {
	parent = (expandableTreeNode)lastItem.getParent();
	newIndex = parent.getIndex(lastItem) +1;
      }
      /* Let the treemodel know. */
      String userInput =  JOptionPane.showInputDialog(null, "Label:");
      if (null != userInput) {
	userInput = userInput.trim();
	treeModel.insertNodeInto(createNewNode(userInput), parent, newIndex);
	saveData.record("created label:"+userInput);
      }
			       
    }
  }

  // cut the selected node to move to a new location
  class cutListener implements ActionListener {
    public void actionPerformed (ActionEvent e) {
      saveData.record("select: cut button");
      expandableTreeNode          lastItem = getSelectedNode();

      if(lastItem != null && lastItem != (expandableTreeNode)treeModel.getRoot()
	 && lastItem != userMethodsRoot && lastItem != systemMethodsRoot) {
	nodeCut = lastItem;
	treeModel.removeNodeFromParent(lastItem);
	saveData.record("cut to move method:"+ (String)lastItem.getUserObject());
      }
    }
  }

  // paste the cut node after the selected node
  class pasteListener implements ActionListener {
    public void actionPerformed (ActionEvent e) {
      saveData.record("select: paste button");
      int               newIndex;
      expandableTreeNode          lastItem = getSelectedNode();
      expandableTreeNode          parent;

      /* Determine where to create the new node. */
      if (null == nodeCut) return;

      if ((lastItem == null) || (lastItem == root)) {
	parent = root;
	newIndex = 0;//treeModel.getChildCount(parent);
      }
      else {
	parent = (expandableTreeNode)lastItem.getParent();
	newIndex = parent.getIndex(lastItem) +1;
      }
      /* Let the treemodel know. */
      treeModel.insertNodeInto(nodeCut, parent, newIndex);
      nodeCut = null;
    }
  }

  // paste the cut node as a child of the selected node
  class embraceIntoListener implements ActionListener
  {
    public void actionPerformed(ActionEvent e) {
      saveData.record("select: embrace into button");
      int               newIndex;
      expandableTreeNode          lastItem = getSelectedNode();
      expandableTreeNode          parent;

      /* Determine where to create the new node. */
      if (null == nodeCut) return;

      if ((lastItem == null) || (lastItem == root)) 
	parent = root;
      else parent = lastItem;

      newIndex = treeModel.getChildCount(parent);

      /* Let the treemodel know. */
      treeModel.insertNodeInto(nodeCut, parent, newIndex);
      nodeCut = null;
    }
  } 


  class addNewListener implements ActionListener
  {
    public void actionPerformed(ActionEvent e) {
      saveData.record("select: add new button");
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
      editMethodFrame ed = new editMethodFrame("Create", "method-name", 
					       definition, es, this,
					       interfaceType);
  }
  public void setOperation(String operation) {
    theOperation = operation;
  }
  public void setParent() {
    theParent = userMethodsRoot;
    theIndex = treeModel.getChildCount(theParent);
  }
  public void editPostProcess (String defName, String def, 
			       boolean processed, String messages) {
    
    if (defName == null || def == null) return;
    expandableTreeNode   lastItem = getSelectedNode();
    if (interfaceType.equals("small")) {
      TreePath selPath = tree.findPath(defName);
      if (selPath != null) {/* modify*/
	currentNode = (expandableTreeNode) selPath.getLastPathComponent();
	currentNode.setUserObject(def);
	currentNode.setID(defName);
	currentNode.setMessage(messages);
	currentNode.setProcessed(processed);
	treeModel.nodeChanged(currentNode);
	currentNode = null;
	saveData.record("modified method:"+ def);
      }
      else {/*new*/     
	expandableTreeNode node = createNewNode(def);
      node.setID(defName);
      node.setMessage(messages);
      node.setProcessed(processed);
      if (null== theParent) theParent = userMethodsRoot;
      treeModel.insertNodeInto(node, theParent, theIndex);
      saveData.record("added New method:"+ def);
      }
    }
    else if (theOperation.equals("addNew")) {// create new node
      expandableTreeNode node = createNewNode(def);
      node.setID(defName);
      node.setMessage(messages);
      node.setProcessed(processed);
      if (null== theParent) theParent = userMethodsRoot;
      treeModel.insertNodeInto(node, theParent, theIndex);
      saveData.record("added New method:"+ def);
    } 
    else if (theOperation.equals("modify")) {// modify existing node
      if (processed) {
	currentNode.setUserObject(def);
	currentNode.setID(defName);
	currentNode.setMessage(messages);
	currentNode.setProcessed(processed);
	treeModel.nodeChanged(currentNode);
	currentNode = null;
	saveData.record("modified method:"+ def);
      }
    }
    else { // modify and create a new node after the selected node
      expandableTreeNode node = createNewNode(def);
      node.setID(defName);
      node.setMessage(messages);
      node.setProcessed(processed);
      expandableTreeNode parent =  (expandableTreeNode)currentNode.getParent();
      treeModel.insertNodeInto(node, parent, parent.getIndex(currentNode)+1);
      saveData.record("built new method:"+ def);
    }
    showMessage(messages);

    if (thePanel != null) thePanel.reloadTabs(); // reload view panels 
  }

  class copyAndCreateListener implements ActionListener
  {
    public void actionPerformed(ActionEvent e) {
      saveData.record("select: copy and create button");
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
    editMethodFrame ed = new editMethodFrame("CopyAndCreate", name, 
					     definition, es, this, 
					     interfaceType);
  }

  class modifyListener implements ActionListener
  {
    public void actionPerformed(ActionEvent e) {
      saveData.record("select: modify button");
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
    if (!lastItem.processed()) {
      editMethodFrame ed = new editMethodFrame("Create", name, 
					       definition, es, this,
					       interfaceType);
    }
    else {
      editMethodFrame ed = new editMethodFrame("Modify", name, 
					       definition, es, this,
					       interfaceType);
    }
  }

  
  class deleteListener implements ActionListener
  {
    public void actionPerformed(ActionEvent e) {
      saveData.record("select: delete button");
      delete();
    }
  }

  private void delete() {
    expandableTreeNode          lastItem = getSelectedNode();

    if (null == lastItem) return;
    String name = lastItem.getID();
    String response;
    if (interfaceType.equals("small")) {
      response = es.removeMethod(name);
      System.out.println("removed:"+name+":");
      System.out.println("delete response:"+response);
      treeModel.removeNodeFromParent(lastItem);
    }
    else {
      if (!lastItem.processed()) {
	treeModel.removeNodeFromParent(lastItem);
      }
      else {
	response = es.deleteMethod(name);
      
	if (response.indexOf("<response") >= 0) {
	  editResponseRenderer er = new editResponseRenderer (response);
	  if (er.processedP()) {
	    treeModel.removeNodeFromParent(lastItem);

	    // reload view panels 
	    if (thePanel != null) thePanel.reloadTabs();
	  }
	  showMessage(er.getMessages());
	  saveData.record("deleted method:"+ (String)lastItem.getUserObject());
	}
	else {
	  showMessage(response);
	}
      }
    }
   
  }

  class reloadListener implements ActionListener
  {
    public void actionPerformed(ActionEvent e) {
      saveData.record("select: reload button");
      expandableTreeNode          lastItem = getSelectedNode();

      if (lastItem == null) return;
      
      if (!lastItem.processed()) return;
      String name = lastItem.getID();
      methodDefRenderer defRenderer = new methodDefRenderer();
      System.out.println("\nInput::"+es.getMethodDef(name));
      String definition = defRenderer.toHtml(es.getMethodDef(name));
      System.out.println("Definition::"+definition+"|");
      lastItem.setUserObject(definition);
      treeModel.nodeChanged(lastItem);
      saveData.record("reloaded method:"+ (String)lastItem.getUserObject());
    }
  }

  class showErrorListener implements ActionListener
  {
    public void actionPerformed(ActionEvent e) {
      saveData.record("select: show error button");
      expandableTreeNode          lastItem = getSelectedNode();

      if (lastItem == null) return;

      String info = lastItem.getMessage();
      showMessage(info);
      saveData.record("checked error:"+ (String)lastItem.getUserObject());
    }
  }

  public void reload() {
    removeAll();
    scrollPane = new JScrollPane(tree);
    buttons = new JPanel();
    buttons.add(memoPanel);
    buttons.setLayout(new GridLayout(0,1));
    buttons.add(changeLookButtons);
    buttons.add(editButtons);
    add("Center",scrollPane);
    add("East",buttons);
    if (!interfaceType.equals("small")) add("South",expectMessagePanel);
    repaint();
    System.out.println("Refreshed?");
  }


  public void showMessage(String messages) {   
    if (interfaceType.equals("small"))  return;
    System.out.print("\n***** messages *****\n" + messages+"\n***************\n ");
    errorMessageArea.cut();
    if (messages == null || messages.equals("") ||
	 messages.equals(" ***** Editing Processed *****")) {
      tborder.setTitleColor(Color.black);
      //tborder.setTitle("Individual Method Error");
      errorMessageArea.setText("Cool! No Error.");
      expectMessagePanel.repaint();
    }
    else {
      tborder.setTitleColor(Color.red);
      errorMessageArea.setText(messages);
      //tborder.setTitle("ERROR !!!");
      expectMessagePanel.repaint();
       //errorMessageArea.setBackground(new Color(250, 230, 230));
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
      
      frame.getContentPane().add("Center", new methodListPanel(es,null,"normal"));
      frame.setSize(800, 600);
      frame.setVisible(true);
    }

}
