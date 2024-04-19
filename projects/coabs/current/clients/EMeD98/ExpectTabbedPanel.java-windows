import com.sun.java.swing.JPanel;
import com.sun.java.swing.JFrame;
import com.sun.java.swing.JTextField;
import com.sun.java.swing.JLabel;
import com.sun.java.swing.JButton;
import com.sun.java.swing.JTabbedPane;
import com.sun.java.swing.JCheckBox;
import java.awt.event.WindowAdapter;
import java.awt.event.WindowEvent;
import java.awt.event.ActionListener;
import java.awt.event.ActionEvent;
import java.awt.BorderLayout;
import java.io.PrintStream;

import com.sun.java.swing.event.ChangeEvent;
import com.sun.java.swing.event.ChangeListener;

//import com.sun.java.swing.border.*;

import Connection.ExpectServer;
import Tree.*;
import PSTree.*;
import HTML.*;
import Describe.*;
import experiment.*;

import com.sun.java.swing.Icon;
import com.sun.java.swing.ImageIcon;

public class ExpectTabbedPanel extends JPanel {  
  private JTabbedPane tabbedPane;
  private JButton reloadButton;
  private ExpectServer es;
  ExpectWindowPanel thePanel = null;
  static protected ImageIcon noteIcon = new ImageIcon("images/red.gif");
  static protected ImageIcon saveIcon = new ImageIcon("images/square_blue.gif");
  public ExpectTabbedPanel (ExpectServer server,
			    ExpectWindowPanel parent) {
    thePanel = parent;
    es = server;
    setLayout(new BorderLayout());
    tabbedPane = new JTabbedPane();
    PrintStream o = System.err;
    o.println("created main pane");

    if (thePanel.getSearchedMethods().size() == 0)
      tabbedPane.addTab("Saved Capability for Editing", null, parent.getSaveArea());
    else tabbedPane.addTab("Saved Capability for Editing", saveIcon, parent.getSaveArea());
    // added for YP
    tabbedPane.addTab("Browse Ontology", null, new HtmlPanel(es,"file:C:/bcbl-exp/client-source/","COMBAT-POWER.concept"));
    tabbedPane.addTab("Evaluation Result", null, new resultPanel(es));
    tabbedPane.addTab("Problem Solving Details", null, new psDescribePanel(es));
    tabbedPane.addTab("Error Messages", null, new messagePanel(es));
    tabbedPane.addTab("Search Methods", null, new searchPanel(es,null,thePanel));
    tabbedPane.addTab("Method Capability Hierarchy", null, 
		      new treePanel("method-capability",es,thePanel));
    undefinedGoalListPanel ugPanel = 
      new undefinedGoalListPanel(es, thePanel); 
      //  new PSundefinedGoalsPanel(es, thePanel);
    if (ugPanel.empty())
      tabbedPane.addTab("Undefined Capabilities", null, ugPanel);
    else 
      tabbedPane.addTab("Undefined Capabilities", noteIcon, ugPanel);
    tabbedPane.addTab("Method Sub-Method Relation", null, 
		  new GRPanel("method-relation",es,null,thePanel),
		  "relationship among user defined methods, based on goals-subgoals");
    o.println("added MR tree");


    //tabbedPane.addTab("Set Top Goal", null, new setTopGoalPanel(es));
    //tabbedPane.addTab("Method Relation in problem solving", null,
    //	  new psTabbedPanel(es, thePanel));
    //PSundefinedGoalsPanel ugPanel = new PSundefinedGoalsPanel(es, thePanel);
    //tabbedPane.addTab("Unmatched Goals in problem solving", null, ugPanel);
    //tabbedPane.addTab("Method Relation in problem solving", null, 
    //		      new PSTreePanel(es, ugPanel));





    //tabbedPane.setTabPlacement(JTabbedPane.RIGHT);
    tabbedPane.setSelectedIndex(7);

    tabbedPane.addChangeListener (new recordListener());
    //add(tabbedPane);
    add("Center",tabbedPane);

    //** for experiment
    //reloadButton = new JButton("reload views only");
    //reloadButton.addActionListener (new reloadListener());
    //add("South",reloadButton);
  }

  class recordListener implements ChangeListener {
    public void stateChanged (ChangeEvent e) {
      record();
    }
  }

  /*
  public void record () {
    int i = tabbedPane.getSelectedIndex();
    if (i == 0) saveData.record("check: Method Sub-Method Relation");
    else if (i == 1) saveData.record ("check: Method Capability Hierarchy");
    else if (i == 2) saveData.record ("check: Undefined Capabilities");
    else if (i == 3) saveData.record ("check: Search Methods");
    else if (i == 4) saveData.record ("check: Describe PS Tree");
    else if (i == 5) saveData.record ("check: All Agenda");
    else if (i == 6) saveData.record ("check: Evaluation Result");
    else saveData.record ("check tab:"+i);
  }
     */
  public void record () {
    int i = tabbedPane.getSelectedIndex();
    if (i == 7) saveData.record(i+"check: Method Sub-Method Relation");
    else if (i == 6) saveData.record (i+"check: Method Capability Hierarchy");
    else if (i == 5) saveData.record (i+"check: Undefined Capabilities");
    else if (i == 4) saveData.record (i+"check: Search Methods");
    else if (i == 3) saveData.record (i+"check: Describe PS Tree");
    else if (i == 2) saveData.record (i+"check: All Agenda");
    else if (i == 1) saveData.record (i+"check: Evaluation Result");
    else saveData.record ("check tab:"+i);
  }

  class reloadListener implements ActionListener {
    public void actionPerformed (ActionEvent e) {
      reload();
    }
  }

  // need to be modified//
  public void reload () {
    PrintStream o = System.err;

    tabbedPane.removeAll();    
    //tabbedPane.addTab("Method List", null, new methodListPanel(es));
    o.println("remove all");    
    if (thePanel.getSearchedMethods().size() == 0)
      tabbedPane.addTab("Saved Capability", null, thePanel.getSaveArea());
    else tabbedPane.addTab("Saved Capability", saveIcon, thePanel.getSaveArea());
    // added for YP
    tabbedPane.addTab("Browse Ontology", null, new HtmlPanel(es,"file:C:/bcbl-exp/client-source/","COMBAT-POWER.concept"));
    tabbedPane.addTab("Evaluation Result", null, new resultPanel(es));
    tabbedPane.addTab("Error Messages", null, new messagePanel(es));
    tabbedPane.addTab("Problem Solving Details", null, new psDescribePanel(es));
    tabbedPane.addTab("Search Methods", null, new searchPanel(es,null,thePanel));
    tabbedPane.addTab("Method Capability Hierarchy", null, 
		      new treePanel("method-capability",es,thePanel));
    undefinedGoalListPanel ugPanel = 
      new undefinedGoalListPanel(es, thePanel);
    if (ugPanel.empty())
      tabbedPane.addTab("Undefined Capabilities", null, ugPanel);
    else 
      tabbedPane.addTab("Undefined Capabilities", noteIcon, ugPanel);

    tabbedPane.addTab("Method Sub-Method Relation", null, 
		      new GRPanel("method-relation",es,null,thePanel));

    //tabbedPane.addTab("Set Top Goal", null, new setTopGoalPanel(es));
    //tabbedPane.addTab("Method Relation in problem solving", null,
    //	  new psTabbedPanel(es,thePanel));
    //tabbedPane.addTab("Browse Ontology", null, new HtmlPanel(es,"file:d:\\BCBL-demo\\client\\","COA.concept"));


    tabbedPane.setSelectedIndex(7);

  }

  public void addSaveIcon() {
    tabbedPane.setIconAt(0,saveIcon);
    tabbedPane.updateUI();
    updateUI();repaint();
  }

  public static void main(String[] args) {
    ExpectServer es = new ExpectServer();
      JFrame frame = new JFrame("Expect Tabbed Panel");
 
      frame.addWindowListener(new WindowAdapter() {
        public void windowClosing(WindowEvent e) {
                  System.exit(0);
        }
      });
      
      frame.getContentPane().add("Center", new ExpectTabbedPanel(es, null));
      frame.setSize(1100, 600);
      frame.setVisible(true);
    }


}
