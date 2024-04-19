/*  
 * undefinedGoalListPanel.java  4/22/98
 */

/*
 * Main program: use Ontology, Adpative Form, and meta info in DB
 *               and generate DB table name and initial attribute constraints
 *               The table name and the constraints are stored in "af_temp_file"
 * @author Jihie Kim
 */
 
package Tree;
import java.util.*;
import java.io.*;
import javax.swing.*;
import javax.swing.text.*;
import javax.swing.tree.*;
import java.awt.*;
import java.awt.event.*;
import javax.swing.JTextArea;
import Connection.*;
import ExpectWindowPanel;
import experiment.*;

public class undefinedGoalListPanel extends JPanel {
  private expandableTree tree;
  private ExpectSocketAPI es;

  private JComponent buttons;
  private JButton createMethodButton;
  ExpectWindowPanel thePanel = null;
  public undefinedGoalListPanel(ExpectSocketAPI theServer,
				ExpectWindowPanel rootPanel) {
    thePanel = rootPanel;
    es = theServer;
    undefinedGoalListRenderer thisListParser = 
      new undefinedGoalListRenderer(theServer.getUndefinedGoalList(""));
    //System.out.println("undefined goals (xml):\n"+theServer.getUndefinedGoalList(""));
    tree = thisListParser.getGoalsInTree();
    if (tree == null) System.out.println(" null tree");
    tree.setCellRenderer(new undefinedGoalListCellRenderer());
    //tree.expandPath(tree.findPath("Unachieved Subgoals"));
    
    JScrollPane scrollPane = new JScrollPane(tree);
    setLayout(new BorderLayout());
    add("Center",scrollPane);
    tree.expandTree();
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
      saveData.record ("create method for goal from unachieved subgoals");
      createMethod();
    }
  } 

  private void createMethod() {
    int               idx;
    expandableTreeNode          node = getSelectedNode();
    if (node == null || node.getParent() == null) { /** root **/
       JOptionPane.showMessageDialog(null, "Please, select a Goal");
       return;
    }

    String contents = (String) node.getUserObject();
    saveData.record("undefined goal:\n"+contents);
      /* Determine where to create the new node. */
    idx = contents.indexOf("Capability:");
    String capDesc = contents.substring(idx+11);

    // for new editor
    idx = capDesc.indexOf("(capability");
    System.out.println(" capDesc1 in undefined goals:"+capDesc);
    if (idx>=0) {
      capDesc = capDesc.substring(idx+11);
      int index2 = capDesc.lastIndexOf(")");
      capDesc = capDesc.substring(0,index2);
      System.out.println(" capDesc in undefined goals:"+capDesc);
    }

    //methodDefRenderer defRenderer = new methodDefRenderer();
    //String capDescIndented = defRenderer.toHtml(capDesc);


    idx = contents.indexOf("Expected Result:");
    int idx2 = contents.indexOf("\nCallers");
    if (idx2 <0) idx2 = contents.substring(idx).indexOf("\n") + idx; 
    
    String resultDesc;
    resultDesc = contents.substring(idx+16,idx2);
    //else resultDesc = contents.substring(idx+16);

    if (resultDesc.equals("UNDEFINED"))
      resultDesc = "";

    String definition = "((name " + node.getID() + ")\r\n"+capDesc+"\r\n";
    definition = definition +"(result-type " + resultDesc + ")\r\n";
    definition = definition + "(method ";
    if (null != thePanel) definition = definition + thePanel.getCopiedGoal();
    definition = definition + "  )\r\n" + ")";
    //definition = definition + "(method   )\r\n" + ")";
    if (thePanel != null) {
      thePanel.listPanel.setOperation("addNew");
      thePanel.listPanel.setParent();
      editMethodFrame ed = 
        new editMethodFrame("Create", node.getID(),
			    capDesc, es, thePanel.listPanel,
			    thePanel,
			    "normal",null,resultDesc);
    }
    else {
      editMethodFrame ed = 
        new editMethodFrame("Create", node.getID(),
			    capDesc, es, null,
			    thePanel,
			    "normal",null,resultDesc);
    }
  }

  public boolean empty () {
    if (null == tree || null == tree.getRoot()) return true;
    else if (tree.getRoot().getChildCount() == 0) return true;
    else return false;
  }

  public static void main(String[] args) {
      JFrame frame = new JFrame("undefined goal list Frame");
      ExpectSocketAPI es = new ExpectSocketAPI();
      frame.addWindowListener(new WindowAdapter() {
        public void windowClosing(WindowEvent e) {
                  System.exit(0);
        }
      });
      
      frame.getContentPane().add("Center", 
				 new undefinedGoalListPanel(es, null));
      frame.setSize(600, 400);
      frame.setVisible(true);
    }

    
}
