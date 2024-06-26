package Tree;

import java.awt.BorderLayout;
import java.awt.TextArea;
import java.awt.event.*;
import java.awt.GridLayout;
import java.awt.BorderLayout;
import com.sun.java.swing.*;
import com.sun.java.swing.tree.*;
import Connection.ExpectServer;
import xml2jtml.methodDefRenderer;
import ExpectWindowPanel;

public class searchPanel extends JPanel 
implements KeyListener{

  JTextField inputField = new JTextField(20);
  JButton searchOnStringButton;
  JButton searchOnSubsumersButton;
  JButton searchOnSubsumeesButton;

  JButton selectButton;
  JButton copyCapButton;
  JLabel inputLabel;
  JPanel buttons;
  JPanel searchInfo;
  JPanel inputPanel;
  JPanel leftPanel;
  expandableTree tree;
  JScrollPane scrollPane;
  ExpectServer es;
  private expandableTreeModel treeModel;
  searchMethodsRenderer thisRenderer;
  ExpectWindowPanel thePanel;

  public searchPanel(ExpectServer theServer, String input, 
		     ExpectWindowPanel rootPanel) { 
    thePanel = rootPanel;
    setLayout(new BorderLayout());
    es = theServer;
    thisRenderer = new searchMethodsRenderer(es);
    tree = thisRenderer.getMethodsAsTree(null);
    tree.setEditable(true);
    treeModel = (expandableTreeModel) tree.getModel();
    tree.setCellRenderer(new methodListCellRenderer());
    tree.expandPath(tree.findPath("Method List"));
    scrollPane = new JScrollPane(tree);
    
    selectButton = new JButton("Select for editing");
    selectButton.addActionListener(new selectListener());
    copyCapButton = new JButton("Copy Capability for editing");
    copyCapButton.addActionListener(new copyCapListener());

    add("Center",scrollPane);
    inputPanel = new JPanel();
    inputLabel = new JLabel ("input:");
    inputField.setText(input);
    inputField.addKeyListener(this);
    inputPanel.add(inputLabel,BorderLayout.WEST);
    inputPanel.add(new JScrollPane(inputField),BorderLayout.EAST);
    leftPanel = new JPanel();
    leftPanel.setLayout(new GridLayout(0,1));
    leftPanel.add(selectButton);
    leftPanel.add(copyCapButton);
    leftPanel.add(inputPanel);
    
    searchInfo = new JPanel();
    searchInfo.add(leftPanel,BorderLayout.WEST);
    
    
    buttons = new JPanel();
    buttons.setLayout(new GridLayout(0,1));

    searchOnSubsumersButton = new JButton("more General");
    searchOnSubsumersButton.addActionListener(new searchOnSubsumersListener());
    searchOnSubsumeesButton = new JButton("more Specific");
    searchOnSubsumeesButton.addActionListener(new searchOnSubsumeesListener());

    searchOnStringButton = new JButton("Search on String Match");
    searchOnStringButton.addActionListener(new searchListener());
    buttons.add (searchOnStringButton);
    buttons.add (searchOnSubsumersButton);
    buttons.add (searchOnSubsumeesButton);
    searchInfo.add(buttons,BorderLayout.EAST);
    //searchInfo.add(selectButton,BorderLayout.SOUTH);
    add("South",searchInfo);
    
  }


  class searchListener implements ActionListener {
    public void actionPerformed(ActionEvent e) {   
      search();
    }
  }
  
  private void search() {

    String input = inputField.getText();
    String xmlInput = es.getSearchedMethodNameList ("", input);

    thisRenderer.destroyChildren();
    thisRenderer.getMethodsAsModifiedTree(xmlInput);
    tree.expandPath(tree.findPath("Method List"));
  }

  class searchOnSubsumersListener implements ActionListener {
    public void actionPerformed(ActionEvent e) {   
      searchOnSubsumers();
    }
  }
  
  private void searchOnSubsumers() {

    String input = inputField.getText();
    String xmlInput = es.getMethodsWithSubsumers ("", input);

    thisRenderer.destroyChildren();
    thisRenderer.getMethodsAsModifiedTree(xmlInput);
    tree.expandPath(tree.findPath("Method List"));
  }

  class searchOnSubsumeesListener implements ActionListener {
    public void actionPerformed(ActionEvent e) {   
      searchOnSubsumees();
    }
  }
  
  private void searchOnSubsumees() {

    String input = inputField.getText();
    String xmlInput = es.getMethodsWithSubsumees ("", input);

    thisRenderer.destroyChildren();
    thisRenderer.getMethodsAsModifiedTree(xmlInput);
    tree.expandPath(tree.findPath("Method List"));
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
    if (thePanel != null)
      thePanel.listPanel.setSelectedNode(name);
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
    ExpectServer es = new ExpectServer();
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
