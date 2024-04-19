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
import Connection.*;
import xml2jtml.methodDefRenderer;
import ExpectWindowPanel;
import Tree.*;
import MethodEditor;
import CritiqueWizard;

public class PSundefinedGoalsPanel extends JPanel {
  private expandableTree tree;
  ExpectSocketAPI es;

  private JComponent buttons;
  private JButton createMethodButton;
  ExpectWindowPanel thePanel = null;
  boolean useNLEditor = false;
  CritiqueWizard wizard = null;
  String methodName;
  psTabbedPanel tabbedPanel;
  public PSundefinedGoalsPanel(ExpectSocketAPI theServer,
			       ExpectWindowPanel rootPanel,
			       psTabbedPanel parent,
			       CritiqueWizard w,
			       boolean useNL) {
    thePanel = rootPanel;
    tabbedPanel = parent;
    useNLEditor = useNL;
    es = theServer;
    wizard = w;
    String xmlInput = theServer.getPSUndefinedGoalList("");
    //System.out.println("PS undefined goals:"+xmlInput);
    undefinedGoalListRenderer thisListParser = 
      new undefinedGoalListRenderer(xmlInput);
    //System.out.println("finished ug renderer");
    tree = thisListParser.getGoalsInTree();
    if (tree == null) System.out.println(" null tree");
    //tree.setCellRenderer(new PSundefinedGoalsCellRenderer());
    tree.setCellRenderer(new undefinedGoalListCellRenderer());

    tree.expandTree();
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
    else System.out.println("cannot find:"+id);
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

    idx = capDesc.indexOf("(capability");

    idx2 = capDesc.indexOf("\n");
    if (idx>=0) {
      capDesc = capDesc.substring(idx+11);
      int index2 = capDesc.lastIndexOf(")");
      capDesc = capDesc.substring(0,index2);
      //System.out.println(" capDesc in undefined goals:"+capDesc);
    }
    
    //methodDefRenderer defRenderer = new methodDefRenderer();
    //String capDescIndented = defRenderer.toHtml(capDesc);


    idx = contents.indexOf("Expected Result:");
    idx2 = contents.indexOf("\nCallers");
    if (idx2 <0) idx2 = contents.substring(idx).indexOf("\n") + idx; 

    String resultDesc = contents.substring(idx+16,idx2);
    if (resultDesc.equals("UNDEFINED"))
      resultDesc = "(inst-of thing)"; // for NL editor
    methodName = node.getID();
    String definition = "((name " + methodName + ")\r\n(capability "+capDesc+")\r\n";
    definition = definition +"(result-type " + resultDesc + ")\r\n";
    definition = definition + "(method ";

    if (useNLEditor) {
      String anInstance = es.createInstanceOfType (resultDesc);
      definition = definition + anInstance;
    } 
    else if (null != thePanel) definition = definition + thePanel.getCopiedGoal();
    definition = definition + "  )\r\n" + ")";
    System.out.println(" new definition:"+definition);
    if (useNLEditor) {
      String response = null;
      response = es.checkAndCreateMethod(definition);
      if (response.indexOf("<response") >= 0) {
	editResponseRenderer er = new editResponseRenderer (response);
	String messages = er.getMessages();
	methodName = er.getMethodName();
	if (er.processedP()) {
	  new MethodEditor(methodName, es) {
	    public void respondToDone() {
	      if (wizard != null) {
		 wizard.editedMethod(methodName);
	      }
	      dispose();
	      es.getUserMethodDef(methodName);
	      //es.postProcessNLEdit(methodName);
	      if (tabbedPanel != null)
		tabbedPanel.reloadPSTabs();
	    }
	  };
		 
	}
	else System.out.println("Edit response:"+messages);
      }
    } 
    else if (thePanel != null) {
      thePanel.listPanel.setOperation("addNew");
      thePanel.listPanel.setParent();
    
      editMethodFrame ed = new editMethodFrame("Create", methodName, 
					      capDesc, es, 
					       thePanel.listPanel, thePanel,
					       "normal", null, resultDesc); 
    }
    else {
      editMethodFrame ed = new editMethodFrame("Create", methodName,
					       capDesc, es, null, null,
					       "small", null, resultDesc);
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
				 new PSundefinedGoalsPanel(es, null,null, null,false));
      frame.setSize(600, 400);
      frame.setVisible(true);
    }

    
}
