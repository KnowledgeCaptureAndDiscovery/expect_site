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
import editor.MEditor;

public class browseMethodList extends JPanel {
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

  
  public browseMethodList(ExpectSocketAPI theServer, 
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
    System.out.println("user defined methods"+xmlInput);
    //System.exit(0);
    userMethodsRoot = thisRenderer.getRootOfMethodTree(xmlInput);
    treeModel.insertNodeInto(userMethodsRoot, top, 0);

    methodListRenderer thisRenderer1 = 
      new methodListRenderer(theServer,"System Defined Methods");
    String xmlInput1= es.getSystemDefinedMethodNameList("");
    System.out.println("xml(system defined methods):"+xmlInput1);
    //System.exit(0);
    systemMethodsRoot = thisRenderer1.getRootOfMethodTree(xmlInput1);
    treeModel.insertNodeInto(systemMethodsRoot, top, 0);

    if (null == tree.findPath("User Defined Methods")) {
      System.out.println(" cannot find User Defined Methods");
    }
    else tree.expandPath(tree.findPath("User Defined Methods"));
    root = (expandableTreeNode) treeModel.getRoot();
    
    if (null == tree.findPath("System Defined Methods")) {
      System.out.println(" cannot find System Defined Methods");
      //System.exit(0);
    }
    else tree.expandPath(tree.findPath("System Defined Methods"));
    root = (expandableTreeNode) treeModel.getRoot();
    
    
    scrollPane = new JScrollPane(tree);
    setLayout(new BorderLayout());
    JPanel tempPane = new JPanel();
    tempPane.add(scrollPane);
    scrollPane.setMinimumSize(new Dimension(300,300));
    add("Center",scrollPane);
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
      //commented by Mukta
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
	//commented by Mukta
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
      //commented by mukta
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
      
      frame.getContentPane().add("Center", new browseMethodList(es,null,"normal"));
      frame.setSize(500, 800);
      frame.setVisible(true);
    }

}
