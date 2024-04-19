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

public class searchFrame extends JFrame
implements WindowListener, KeyListener{

  JTextField inputField = new JTextField(30);
  JButton doneButton;
  JButton searchButton;
  JPanel buttons;
  JPanel searchInfo;
  expandableTree tree;
  JScrollPane scrollPane;
  ExpectServer es;
  private expandableTreeModel treeModel;
  methodListRenderer thisRenderer;

  public searchFrame(ExpectServer theServer, String input) {
    super("Search Result Frame");
    getContentPane().setLayout(new BorderLayout());
    es = theServer;
    if (input == null) {
      //scrollPane = new JScrollPane();
      thisRenderer = new methodListRenderer(es);
      tree = thisRenderer.getMethodsAsTree("");
      treeModel = (expandableTreeModel) tree.getModel();
      tree.setCellRenderer(new methodListCellRenderer());
      tree.expandPath(tree.findPath("Method List"));
      scrollPane = new JScrollPane(tree);
    }
    else {
      String xmlInput = es.getSearchedMethodNameList ("", input);
      thisRenderer = new methodListRenderer(es);
      tree = thisRenderer.getMethodsAsTree(xmlInput);
      treeModel = (expandableTreeModel) tree.getModel();
      tree.setCellRenderer(new methodListCellRenderer());
      tree.expandPath(tree.findPath("Method List"));
      scrollPane = new JScrollPane(tree);
    }
     getContentPane().add("Center",scrollPane);

    doneButton = new JButton("done");
    doneButton.addActionListener(new doneListener());
    buttons = new JPanel();
    buttons.add(doneButton);

    addWindowListener(this);
    getContentPane().add("South",buttons);
    setSize(500,300);
    setLocation(150,150);
    setVisible(true);
    
  }

  public void windowClosed(WindowEvent event){}
  public void windowDeiconified(WindowEvent event){}
  public void windowIconified(WindowEvent event){}
  public void windowActivated(WindowEvent event){}
  public void windowDeactivated(WindowEvent event){}
  public void windowOpened(WindowEvent event){}
  
  public void windowClosing(WindowEvent event)
  {  
    setVisible(false);
    dispose();
  }

  class doneListener implements ActionListener {
    public void actionPerformed(ActionEvent e) {   
      setVisible(false);
      dispose();
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
    JFrame frame = new searchFrame(es,"divide");
  }



}
