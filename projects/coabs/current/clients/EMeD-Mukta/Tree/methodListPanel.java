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
import javax.swing.*;
import javax.swing.text.*;
import javax.swing.tree.*;
import javax.swing.border.*;
import java.awt.*;
import java.awt.event.*;

import Connection.*;

import xml2jtml.methodDefRenderer;
//import ExpectPanel;
import ExpectWindowPanel;
import MethodEditor;
import experiment.*;
import editor.*;

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
  private JButton addNew1Button;
  private JButton copyAndCreateButton;
  private JButton deleteButton;
  private JButton modifyButton;
  private JButton showErrorButton;
  private JButton showNLButton;
  private JButton reloadButton;
  private JButton NLEditorButton;
  private JButton modifyInNLButton;


  private JComponent changeLookButtons;
  private JLabel  changeLookLabel;
  private JButton createLabelButton;
  private JButton cutButton;
  private JButton pasteButton;
  private JButton pastebButton;
  private JButton embraceIntoButton;

  ExpectSocketAPI es;

  private expandableTreeNode root; // root of the tree
  private expandableTreeNode userMethodsRoot;
  private expandableTreeNode systemMethodsRoot;
  private expandableTreeNode nodeCut; // node cut beforehand

  // these are for postprocess editiong
  private expandableTreeNode currentNode = null; // node currently processed
  private int theIndex;
  private expandableTreeNode theParent;
  private String theOperation="";

  JComponent  errorAggregate;
  JTextArea   errorMessageArea;
  JPanel expectMessagePanel;
  JScrollPane scrollPane;
  TitledBorder tborder;

  ExpectWindowPanel thePanel = null;
  String interfaceType;
  String currentName;

  public methodListPanel(ExpectSocketAPI theServer, 
		     ExpectWindowPanel parent,
		     String itype) {
    thePanel = parent;
    interfaceType = itype;
    expandableTreeNode top = new expandableTreeNode("Method List");
    treeModel = new expandableTreeModel(top);
    tree = new expandableTree(treeModel);
    // uncomment to make the tree editable::  tree.setEditable(true);
    tree.setCellRenderer(new highlightedMethodListCellRenderer());
    es = theServer;

    methodListRenderer thisRenderer = 
      new methodListRenderer(theServer,"User Defined Methods");
    String xmlInput = es.getUserDefinedMethodNameList("");
    //System.out.println("xml(user defined methods):"+xmlInput);
    userMethodsRoot = thisRenderer.getRootOfMethodTree(xmlInput);
    treeModel.insertNodeInto(userMethodsRoot, top, 0);

    thisRenderer = 
      new methodListRenderer(theServer,"System Defined Methods");
    xmlInput = es.getSystemDefinedMethodNameList("");
    //System.out.println("xml(system defined methods):"+xmlInput);
    systemMethodsRoot = thisRenderer.getRootOfMethodTree(xmlInput);
    treeModel.insertNodeInto(systemMethodsRoot, top, 0);

    if (null == tree.findPath("User Defined Methods")) {
      System.out.println(" cannot find User Defined Methods");
    }
    else tree.expandPath(tree.findPath("User Defined Methods"));
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
    changeLookLabel = new JLabel("Method Organizer");
    changeLookButtons.add(changeLookLabel);

    addNewButton = new JButton("Add new");
    addNewButton.setMargin(new Insets(0,0,0,0));
    addNewButton.addActionListener(new addNewListener());
    editButtons.add(addNewButton);

    addNew1Button = new JButton("New (in Text)");
    addNew1Button.setMargin(new Insets(0,0,0,0));
    addNew1Button.addActionListener(new addNew1Listener());
    editButtons.add(addNew1Button);// for paper

    copyAndCreateButton = new JButton("Copy/Add");
    copyAndCreateButton.setMargin(new Insets(0,0,0,0));
    copyAndCreateButton.addActionListener(new copyAndCreateListener());
    editButtons.add(copyAndCreateButton);

    modifyButton = new JButton("Modify");
    modifyButton.setMargin(new Insets(0,0,0,0));
    modifyButton.addActionListener(new modifyListener());
    editButtons.add(modifyButton);

    deleteButton = new JButton ("Delete");
    deleteButton.setMargin(new Insets(0,0,0,0));
    deleteButton.addActionListener(new deleteListener());
    editButtons.add(deleteButton);

    showErrorButton = new JButton ("Errors");
    showErrorButton.setMargin(new Insets(0,0,0,0));
    showErrorButton.addActionListener(new showErrorListener());
    editButtons.add(showErrorButton);

    showNLButton = new JButton ("In English");
    showNLButton.setMargin(new Insets(0,0,0,0));
    showNLButton.addActionListener(new showNLListener());
    editButtons.add(showNLButton);

    NLEditorButton = new JButton ("NL editor");
    NLEditorButton.setMargin(new Insets(0,0,0,0));
    NLEditorButton.addActionListener(new NLEditorListener());
    //editButtons.add(NLEditorButton);

    modifyInNLButton = new JButton ("Modify in NL");
    modifyInNLButton.setMargin(new Insets(0,0,0,0));
    modifyInNLButton.addActionListener(new modifyInNLListener());
    editButtons.add(modifyInNLButton);

    //reloadButton = new JButton ("Reload");
    //reloadButton.addActionListener(new reloadListener());
    //editButtons.add(reloadButton);

    // for buttons to change look and feel
    createLabelButton = new JButton("New Folder");
    createLabelButton.setMargin(new Insets(0,0,0,0));
    createLabelButton.addActionListener(new createLabelListener());
    changeLookButtons.add(createLabelButton);

    cutButton = new JButton ("Cut to move");
    cutButton.setMargin(new Insets(0,0,0,0));
    cutButton.addActionListener(new cutListener());
    changeLookButtons.add(cutButton);

    pasteButton = new JButton("Paste After");
    pasteButton.setMargin(new Insets(0,0,0,0));
    pasteButton.addActionListener(new pasteListener());
    changeLookButtons.add(pasteButton);

    pastebButton = new JButton("Paste Before");
    pastebButton.setMargin(new Insets(0,0,0,0));
    pastebButton.addActionListener(new pasteBeforeListener());
    changeLookButtons.add(pastebButton);


    embraceIntoButton = new JButton("Paste Into");
    embraceIntoButton.setMargin(new Insets(0,0,0,0));
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

    buttons.add(changeLookButtons); // deleted for experiment 6/99
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

    // "Individual Method Error"
    tborder = new TitledBorder(new LineBorder(Color.black, 1),
					    "Local Error Detector",
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

  // paste the cut node before the selected node
  class pasteBeforeListener implements ActionListener {
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
	newIndex = parent.getIndex(lastItem);
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
      definition = null;// added for new editor
      editMethodFrame ed = 
        new editMethodFrame("Create", newMethodName(), 
		        definition, es, this, thePanel,
		        interfaceType, null,"");
  }

  class addNew1Listener implements ActionListener
  {
    public void actionPerformed(ActionEvent e) {
      saveData.record("select: add new button");
      addNew1();
    }
  } 

  private void addNew1() {
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
      definition = null;// added for new editor
      textEditMethodFrame ed = 
        new textEditMethodFrame("Create", newMethodName(), 
		        definition, es, this, interfaceType);
  }
  public void setOperation(String operation) {
    theOperation = operation;
  }
  public void setParent() {
    theParent = userMethodsRoot;
    theIndex = treeModel.getChildCount(theParent);
  }
  public void editPostProcess (String defName, String def, 
			       boolean processed, 
			       String messages,
			       Container editorUsed) {
    String definition = def;
    if (defName == null || def == null) return;
    expandableTreeNode   lastItem = getSelectedNode();

    if (processed) { // get pretty description
      String xmlDesc = es.getMethodDef(defName);
      if (xmlDesc != null) {
        methodDefRenderer defRenderer = new methodDefRenderer();
        definition = defRenderer.toHtml(xmlDesc);
      }
    }
    //System.out.println(" post process for:"+defName);
    //System.out.println("the operation:"+theOperation+":");
    if (theOperation.equals("addNew")) {// create new node
      expandableTreeNode node = createNewNode(definition);
      node.setID(defName);
      node.setMessage(messages);
      node.setProcessed(processed);
      node.setEditorUsed(editorUsed);
      if (null== theParent) theParent = userMethodsRoot;
      treeModel.insertNodeInto(node, theParent, theIndex);
      if (treeModel.getChildCount(theParent) <=1)
        tree.expandPath(tree.findPath(node));
      saveData.record("added New method:"+ definition);
    } 
    else if (theOperation.equals("modify")) {// modify existing node
      if (processed || interfaceType.equals("small")) {

        // added messages in user object to check if the node needs to be highlighted
        // in the cell renderer
        currentNode.setUserObject(definition+"\nMESSAGES"+messages);
        currentNode.setID(defName);
        currentNode.setMessage(messages);
        currentNode.setProcessed(processed);
	currentNode.setEditorUsed(editorUsed);
        treeModel.nodeChanged(currentNode);
        currentNode = null;
        saveData.record("modified method:"+ definition);
      }
    }
    else { // modify and create a new node after the selected node
      expandableTreeNode node = createNewNode(definition);
      node.setID(defName);
      node.setMessage(messages);
      node.setProcessed(processed);
      node.setEditorUsed(editorUsed);
      expandableTreeNode parent =  (expandableTreeNode)currentNode.getParent();
      treeModel.insertNodeInto(node, parent, parent.getIndex(currentNode)+1);
      saveData.record("built new method:"+ definition);
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
    int mi = definition.indexOf("\nMESSAGES");
    if (mi >0) definition = definition.substring (0, mi);
    currentNode = lastItem;
    theParent = (expandableTreeNode)lastItem.getParent();
    theIndex = theParent.getIndex(lastItem) +1;
    theOperation = "copyAndCreate";
    definition = null; //added for new editor 
    editMethodFrame ed = 
      new editMethodFrame("CopyAndCreate", name, 
		      definition, es, this, thePanel,
		      interfaceType,null,"");
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
    int mi = definition.indexOf("\nMESSAGES");
    if (mi >0) definition = definition.substring (0, mi);
    currentNode = lastItem;
    theParent = (expandableTreeNode)lastItem.getParent();
    theIndex = theParent.getIndex(lastItem) +1;
    theOperation = "modify";
    definition = null; // added for new editor
    if (!lastItem.processed()) {
      editMethodFrame ed = 
        new editMethodFrame("Modify and Create", name, 
		        definition, es, this, thePanel,
		        interfaceType, 
		        (MEditor)lastItem.getEditorUsed(),"");
    }
    else {
      editMethodFrame ed = 
        new editMethodFrame("Modify", name, 
		        definition, es, this, thePanel,
		        interfaceType, null,"");
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
    theOperation = "delete";
    if (null == lastItem) return;
    String name = lastItem.getID();
    String response;
    if (interfaceType.equals("small")) {
      System.out.println("remove:"+name+":");
      response = es.removeMethod(name);
      System.out.println("delete response:"+response);
      treeModel.removeNodeFromParent(lastItem);
      if (thePanel != null) thePanel.reloadTabs(); // reload view panels 
      // needs to be changed for efficiency

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
	  if (thePanel != null) thePanel.reloadTabs(); // reload view panels 
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
      //System.out.println("\nInput::"+es.getMethodDef(name));
      String definition = defRenderer.toHtml(es.getMethodDef(name));
      //System.out.println("Definition::"+definition+"|");
      editResponseRenderer er = new editResponseRenderer (es.checkMethod(name));
      lastItem.setMessage(er.getMessages(true));

      // added messages in user object to check if the node needs to be highlighted
      // in the cell renderer
      lastItem.setUserObject(definition+"\nMESSAGES"+er.getMessages(true));
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
      //System.out.println("info:"+info);
      showMessage(info);
      saveData.record("checked error:"+ (String)lastItem.getUserObject());
    }
  }
  class showNLListener implements ActionListener
  {
    public void actionPerformed(ActionEvent e) {
      saveData.record("select: show in English button");
      expandableTreeNode          lastItem = getSelectedNode();

      if (lastItem == null) return;

      String name = (String)lastItem.getID();
      String desc = es.getNLOfMethod(name);
      int i = desc.indexOf("To do that");
      if (i>0) {
	String description = desc.substring(0,i-1) + "\n" + desc.substring(i);
	desc = description;
      }
      ViewFrame ed = new ViewFrame("Method in English", name, desc);
      saveData.record("shown in English:"+ name);
    }
  }
  class modifyInNLListener implements ActionListener
  {
   public void actionPerformed(ActionEvent e) {
     modifyInNL();
   }
  }


  private void modifyInNL() {      
    expandableTreeNode          lastItem = getSelectedNode();

    if (null == lastItem) return;
    currentName = lastItem.getID();
      
    currentNode = lastItem;
    theParent = (expandableTreeNode)lastItem.getParent();
    theIndex = theParent.getIndex(lastItem) +1;
    theOperation = "modify";
    
   
    new MethodEditor(currentName, es) {
      public void respondToDone() {
	//wizard.editedMethod(currentName);
	dispose();
	es.postProcessNLEdit(currentName);
	NLEditPostProcess(this);

      }
    };
    
	
  }

  public void NLEditPostProcess (MethodEditor NLeditorUsed) {

    
    String xmlInput = es.postProcessNLEdit(currentName);
    System.out.println("def in xml:"+xmlInput);
    if (xmlInput.equals("") || xmlInput == null) {
      System.out.println(" cannot find the definition of "+currentName);
      return;
    }
    editResponseRenderer defr = new editResponseRenderer (xmlInput);
    String newDefinition = defr.getMethodDefinition();
    //System.out.println("definition:"+newDefinition);
    String response = null;
    if (interfaceType.equals("small")) {
	response = es.editMethod(newDefinition);
      }
    else if (theOperation.equals("Create") || 
	     theOperation.equals("Modify and Create"))
      response = es.checkAndCreateMethod(newDefinition);
    else if (theOperation.equals("CopyAndCreate")) 
      response = es.checkAndCreateMethod(newDefinition);
    else if (theOperation.equals("Modify")) 
      response = es.checkAndModifyMethod(newDefinition);
    System.out.println(theOperation+"|response:"+response);
    if (interfaceType.equals("small")) {
      if (response.startsWith("OK")) {
	String mname = response.substring(3).trim();
	System.out.println(" method name:"+mname);
	editPostProcess(mname, newDefinition,
			true, "", null);
      }
    }
    else if (response.indexOf("<response") >= 0) {
      editResponseRenderer er = new editResponseRenderer (response);
      String methodName = er.getMethodName();
      String messages = er.getMessages();
      Container editorUsed = null;
      if (!er.processedP()) editorUsed = NLeditorUsed;
      editPostProcess(methodName, newDefinition, 
		      er.processedP(),
		      messages, editorUsed);
	
    }
    else showMessage(response);

  }

  class NLEditorListener implements ActionListener
  {
   public void actionPerformed(ActionEvent e) {
     MethodEditor nlEditor = new MethodEditor("",es);
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
      if (theOperation.equals("delete"))
	errorMessageArea.setText("OK.");
      else errorMessageArea.setText("No Error.");
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
  public String newMethodName() {
    Calendar rightNow = Calendar.getInstance();
    return ("_method"+rightNow.get(Calendar.HOUR)+
	  rightNow.get(Calendar.MINUTE)+
	  rightNow.get(Calendar.SECOND));

  }
  public static void main(String[] args) {
      JFrame frame = new JFrame("method list Frame");
      ExpectSocketAPI es = new ExpectSocketAPI();
      frame.addWindowListener(new WindowAdapter() {
        public void windowClosing(WindowEvent e) {
                  System.exit(0);
        }
      });
      
      frame.getContentPane().add("Center", new methodListPanel(es,null,"normal"));
      frame.setSize(500, 800);
      frame.setVisible(true);
    }

}
