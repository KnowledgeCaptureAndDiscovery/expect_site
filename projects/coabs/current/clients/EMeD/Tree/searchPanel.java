//File: searchPanel.java
//
// Copyright (C) 1998 by Jihie Kim
// All Rights Reserved
//
package Tree;

import java.awt.*;
import java.awt.event.*;
import javax.swing.*;
import javax.swing.tree.*;
import Connection.ExpectSocketAPI;
import xml2jtml.methodDefRenderer;
import ExpectWindowPanel;

public class searchPanel extends JPanel 
implements KeyListener{

  //JTextField inputField = new JTextField(20);
  JTextArea inputArea = new JTextArea(2,15);
  JButton searchOnStringButton;
  JButton searchOnRFMLButton;
  JButton searchOnSubsumersButton;
  JButton searchOnSubsumeesButton;

  JButton selectButton;
  JButton copyCapButton;
  JLabel inputLabel;
  JPanel buttons;
  JPanel searchInfo;
  JPanel inputPanel;
  expandableTree tree;
  JScrollPane scrollPane;
  ExpectSocketAPI es;
  private expandableTreeModel treeModel;
  searchMethodsRenderer thisRenderer;
  ExpectWindowPanel thePanel;
  
  static final Color searchButtonColor = new Color (200,200,255);
  public searchPanel(ExpectSocketAPI theServer, String input, 
		     ExpectWindowPanel rootPanel) { 
    thePanel = rootPanel;
    setLayout(new BorderLayout());
    es = theServer;
    thisRenderer = new searchMethodsRenderer(es);
    tree = thisRenderer.getMethodsAsTree(null);
    tree.setEditable(true);
    treeModel = (expandableTreeModel) tree.getModel();
    tree.setCellRenderer(new methodListCellRenderer(thisRenderer));
    tree.expandPath(tree.findPath("  Search Results"));
    scrollPane = new JScrollPane(tree);
    
    selectButton = new JButton("Select for editing");
    selectButton.addActionListener(new selectListener());
    copyCapButton = new JButton("Copy Capability for editing");
    copyCapButton.addActionListener(new copyCapListener());
    JPanel editButtons = new JPanel();
    editButtons.setLayout(new GridLayout(0,1));
    editButtons.add(selectButton);
    editButtons.add(copyCapButton);

    add("Center",scrollPane);
    inputPanel = new JPanel();
    inputLabel = new JLabel ("Words:");
    inputArea.setFont (new Font ("Dialog", Font.BOLD, 12));
    inputArea.setText("");
    inputArea.setBackground (new Color (255, 255, 200));
    inputArea.addKeyListener(this);
    inputPanel.setLayout(new GridLayout(0,1));
    inputPanel.add(inputLabel);
    inputPanel.add(new JScrollPane(inputArea));
    inputPanel.add(editButtons);
    /*
    inputPanel.add(inputLabel,BorderLayout.NORTH);
    inputPanel.add(new JScrollPane(inputArea),BorderLayout.CENTER);
    inputPanel.add(editButtons,BorderLayout.SOUTH);
    */

    searchInfo = new JPanel();
    searchInfo.add(inputPanel,BorderLayout.WEST);
    
    buttons = new JPanel();
    buttons.setLayout(new GridLayout(0,1));

    searchOnSubsumersButton = new JButton("more General (1 word)");
    searchOnSubsumersButton.addActionListener(new searchOnSubsumersListener());
    searchOnSubsumersButton.setBackground(searchButtonColor);
    searchOnSubsumeesButton = new JButton("more Specific (1 word)");
    searchOnSubsumeesButton.addActionListener(new searchOnSubsumeesListener());
    searchOnSubsumeesButton.setBackground(searchButtonColor);

    searchOnStringButton = new JButton("Match with sub-string");
    searchOnStringButton.addActionListener(new searchListener());
    searchOnStringButton.setBackground(searchButtonColor);

    searchOnRFMLButton = new JButton("Match with Breakdown (1 word)");
    searchOnRFMLButton.addActionListener(new searchOnRFMLListener());
    searchOnRFMLButton.setBackground(searchButtonColor);
    
    buttons.add (searchOnStringButton);
    buttons.add (searchOnRFMLButton);
    buttons.add (searchOnSubsumersButton);
    buttons.add (searchOnSubsumeesButton);
    searchInfo.add(buttons,BorderLayout.EAST);
    
    add("South",searchInfo);
    
  }


  class searchListener implements ActionListener {
    public void actionPerformed(ActionEvent e) {   
      search();
    }
  }
  
  private void search() {

    String input = inputArea.getText();
    if (input.equals("")) {
      JOptionPane.showMessageDialog(null, "Please type words first");
      return;
    }
    String xmlInput = es.getSearchedMethodNameList ("", input);

    thisRenderer.destroyChildren();
    thisRenderer.getMethodsAsModifiedTree(xmlInput,input);
    tree.expandPath(tree.findPath("Matched Capabilities"));
  }

  class searchOnRFMLListener implements ActionListener {
    public void actionPerformed(ActionEvent e) {   
      searchOnRFML();
    }
  }

  private void searchOnRFML() {
    String input = inputArea.getText();
    if (input.equals("")) {
      JOptionPane.showMessageDialog(null, "Please type a word first");
      return;
    }
    String xmlInput = es.getSearchedOnRMFLMethodNameList ("", input);

    thisRenderer.destroyChildren();
    thisRenderer.getMethodsAsModifiedTree(xmlInput,input);
    tree.expandPath(tree.findPath("Matched Capabilities"));
  }

  class searchOnSubsumersListener implements ActionListener {
    public void actionPerformed(ActionEvent e) {   
      searchOnSubsumers();
    }
  }
  
  private void searchOnSubsumers() {

    String input = inputArea.getText();
    if (input.equals("")) {
      JOptionPane.showMessageDialog(null, "Please type a word first");
      return;
    }
    String xmlInput = es.getMethodsWithSubsumers ("", input);

    thisRenderer.destroyChildren();
    thisRenderer.getMethodsAsModifiedTree(xmlInput,input);
    tree.expandPath(tree.findPath("Matched Capabilities"));
  }

  class searchOnSubsumeesListener implements ActionListener {
    public void actionPerformed(ActionEvent e) {   
      searchOnSubsumees();
    }
  }
  
  private void searchOnSubsumees() {

    String input = inputArea.getText();
    if (input.equals("")) {
      JOptionPane.showMessageDialog(null, "Please type a word first");
      return;
    }

    String xmlInput = es.getMethodsWithSubsumees ("", input);

    thisRenderer.destroyChildren();
    thisRenderer.getMethodsAsModifiedTree(xmlInput,input);
    tree.expandPath(tree.findPath("Matched Capabilities"));
  }

  class selectListener implements ActionListener {
    public void actionPerformed(ActionEvent e) {   
      selectForEditing();
    }
  }

  private void selectForEditing() {
    expandableTreeNode    node = tree.getSelectedNode();
    if (null== node) return;
    String name =  node.getID();
    //commented by mukta
    /*if (thePanel != null)
      thePanel.listPanel.setSelectedNode(name);*/
      //metlistPanel.setSelectedNode(name);
  }
  
  class copyCapListener implements ActionListener {
    public void actionPerformed(ActionEvent e) {   
      copyCapability();
    }
  }
  
  private void copyCapability() {
    expandableTreeNode    node = tree.getSelectedNode();
    if (null== node) {
      thePanel.setCopiedGoal ("");
    }
    else {
      String simpleGoal = es.getSimplifiedGoal(node.getID());
      System.out.println("goal desc:" + simpleGoal + "for :"+ node.getID());
      thePanel.addCopiedGoal (simpleGoal);
      thePanel.addSearchedMethod(node.getID());
    }
  }

  public void keyTyped(KeyEvent e)
  {
  }

  public void keyPressed(KeyEvent e)
  {
  }

  public void keyReleased(KeyEvent e)
  {
  }

  public static void main(String[] args) { 
    ExpectSocketAPI es = new ExpectSocketAPI();
    searchPanel spanel = new searchPanel(es, null, null);
    JFrame frame = new JFrame("Search Methods");
     frame.addWindowListener(new WindowAdapter() {
        public void windowClosing(WindowEvent e) {
                  System.exit(0);
        }
      });
     frame.getContentPane().add(spanel);
     frame.setSize(700, 500);
     frame.setVisible(true);

  }



}
