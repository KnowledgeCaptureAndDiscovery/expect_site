/*  
 * PSundefinedGoals.java  4/22/99
 */

/*
 * Main program: use Ontology, Adpative Form, and meta info in DB
 *               and generate DB table name and initial attribute constraints
 *               The table name and the constraints are stored in "af_temp_file"
 * @author Jihie Kim
 */
 
package PSTree;
import java.util.*;
import java.io.*;
import javax.swing.*;
import javax.swing.text.*;
import javax.swing.tree.*;
import java.awt.*;
import java.awt.event.*;
import javax.swing.JTextArea;
import Connection.ExpectServer;
import Connection.ExpectSocketAPI;
import xml2jtml.methodDefRenderer;
import ExpectWindowPanel;
import Tree.undefinedGoalListRenderer;
import Tree.expandableTree;
import Tree.expandableTreeNode;
import Tree.editMethodFrame;

public class PSundefinedGoalsPanel extends JPanel {
  private expandableTree tree;
  private ExpectSocketAPI es;

  private JComponent buttons;
  private JButton createMethodButton;
  ExpectWindowPanel thePanel = null;
  public PSundefinedGoalsPanel(ExpectSocketAPI theServer,
			 ExpectWindowPanel rootPanel) {
    thePanel = rootPanel;
    es = theServer;
    undefinedGoalListRenderer thisListParser = 
      new undefinedGoalListRenderer(theServer.getPSUndefinedGoalList(""));
    //System.out.println("input:"+theServer.getPSUndefinedGoalList(""));
    tree = thisListParser.getGoalsInTree(null);
    if (tree == null) System.out.println(" null tree");
    tree.setCellRenderer(new PSundefinedGoalsCellRenderer());
    tree.expandPath(tree.findPath("Unmatched Goals"));
    JScrollPane scrollPane = new JScrollPane(tree);
    setLayout(new BorderLayout());
    add("Center",scrollPane);

    createMethodButton = new JButton("Create Method for Goal");
    createMethodButton.addActionListener(new createMethodListener());
    buttons = new JPanel();
    buttons.add(createMethodButton);
    add("South", buttons);
     

  }

  protected expandableTreeNode getSelectedNode() {
    TreePath   selPath = tree.getSelectionPath();

    if(selPath != null)
      return (expandableTreeNode)selPath.getLastPathComponent();
    return null;
  }

  class createMethodListener implements ActionListener
  {
    public void actionPerformed(ActionEvent e) {
      createMethod();
    }
  } 

  public void setSelectedNode (String id) {
    TreePath selPath = tree.findPath(id);
    if (selPath != null) {
      tree.setSelectionPath(selPath);
    }
  }


  public void createMethod() {
    int               idx;
    int idx2;
    String contents;
    String capDesc;

    expandableTreeNode          node = getSelectedNode();

    if (node == null || node.getParent() == null) { /** root **/
       JOptionPane.showMessageDialog(null, "Please, select a Goal");
       return;
    }

    contents = (String) node.getUserObject();
      /* Determine where to create the new node. */
    idx = contents.indexOf("Capability:");
    capDesc = contents.substring(idx+11);
    idx2 = capDesc.indexOf("\n");
    if (idx2 >=0)
      capDesc = capDesc.substring (0,idx2);
    //methodDefRenderer defRenderer = new methodDefRenderer();
    //String capDescIndented = defRenderer.toHtml(capDesc);


    idx = contents.indexOf("Expected Result:");
    idx2 = contents.indexOf("\nGoal Callers");
    String resultDesc = contents.substring(idx+16,idx2);
    if (resultDesc.equals("UNDEFINED"))
      resultDesc = "";

    String definition = "((name " + node.getID() + ")\r\n"+capDesc+"\r\n";
    definition = definition +"(result-type " + resultDesc + ")\r\n";
    definition = definition + "(method ";
    if (null != thePanel) definition = definition + thePanel.getCopiedGoal();
    definition = definition + "  )\r\n" + ")";
    if (thePanel != null) {
      thePanel.listPanel.setOperation("addNew");
      thePanel.listPanel.setParent();
    
      editMethodFrame ed = new editMethodFrame("Create", "method-name", 
					       definition, es, 
					       thePanel.listPanel, thePanel,
					       null, null, null); //?
    }
    else {
      editMethodFrame ed = new editMethodFrame("Create", "method-name",
					       definition, es, null, null,
					       null, null, null);//??
    }

  }

  public boolean empty () {
    if (null == tree || null == tree.getRoot()) return true;
    else if (tree.getRoot().getChildCount() == 0) return true;
    else return false;
  }


  public static void main(String[] args)  {
      JFrame frame = new JFrame("undefined goal list Frame");
      ExpectSocketAPI es = new ExpectSocketAPI();
      frame.addWindowListener(new WindowAdapter() {
        public void windowClosing(WindowEvent e) {
                  System.exit(0);
        }
      });
      
      frame.getContentPane().add("Center", 
				 new PSundefinedGoalsPanel(es, null));
      frame.setSize(600, 400);
      frame.setVisible(true);
    }

    
}
