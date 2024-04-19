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


public class methodPanel extends JPanel {
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
  private JTabbedPane subtabbedPane;
  
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
  
  public Tree.methodListPanelEnglish englishPanel;
  public Tree.methodListPanel actualPanel;
  
  public methodPanel(ExpectSocketAPI theServer, 
		     ExpectWindowPanel parent,
		     String itype) {
    thePanel = parent;
    interfaceType = itype;
    
    es = theServer;
    englishPanel = new Tree.methodListPanelEnglish(es,thePanel,itype);
    actualPanel = new Tree.methodListPanel(es,thePanel,itype);
    setLayout(new BorderLayout());
    JScrollPane scrollPane = new JScrollPane();
    scrollPane.setPreferredSize(new Dimension(700,700));
    add("Center",scrollPane);
    
    subtabbedPane = new JTabbedPane();
    subtabbedPane.addTab("English",englishPanel);
    //subtabbedPane.addTab("Formal",actualPanel);
    add("North",subtabbedPane);
    
    }
    //add(expectMessagePanel);
  }

  
  
  


