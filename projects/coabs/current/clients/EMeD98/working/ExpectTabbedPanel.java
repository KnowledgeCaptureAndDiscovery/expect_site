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

import Connection.ExpectServer;
import Tree.*;
import PSTree.*;
import HTML.*;

import com.sun.java.swing.Icon;
import com.sun.java.swing.ImageIcon;

public class ExpectTabbedPanel extends JPanel {  
  private JTabbedPane tabbedPane;
  private JButton reloadButton;
  private ExpectServer es;
  ExpectWindowPanel thePanel = null;

  static protected ImageIcon noteIcon = new ImageIcon("images/red.gif");

  public ExpectTabbedPanel (ExpectServer server,
		        ExpectWindowPanel parent) {
    thePanel = parent;
    es = server;
    setLayout(new BorderLayout());

    tabbedPane = new JTabbedPane();
    
    //tabbedPane.addTab("Method List", null, new methodListPanel(es));
    tabbedPane.addTab("Method Sub-Method Relation", null, 
		      new GRPanel("method-relation",es,null));
    tabbedPane.addTab("Method Capability Hierarchy", null, 
		      new treePanel("method-capability",es));
    undefinedGoalListPanel ugPanel = 
      new undefinedGoalListPanel(es, thePanel);
    if (ugPanel.empty())
      tabbedPane.addTab("Unmatched Capabilities", null, ugPanel);
    else 
      tabbedPane.addTab("Unmatched Capabilities", noteIcon, ugPanel);

    tabbedPane.addTab("Search Methods", null,
		      new searchPanel(es,null,thePanel));
    tabbedPane.addTab("All Agenda", null, new messagePanel(es));
    tabbedPane.addTab("Evaluation Result", null, new resultPanel(es));
    tabbedPane.addTab("Set Top Goal", null, new setTopGoalPanel(es));
    tabbedPane.addTab("Method Relation in problem solving", null,
		  new psTabbedPanel(es, thePanel));
    //PSundefinedGoalsPanel ugPanel = new PSundefinedGoalsPanel(es, thePanel);
    //tabbedPane.addTab("Unmatched Goals in problem solving", null, ugPanel);
    //tabbedPane.addTab("Method Relation in problem solving", null, 
    //		      new PSTreePanel(es, ugPanel));


    tabbedPane.addTab("Browse Ontology", null, new HtmlPanel(es,"file:nfs/v2/jihie/expect/EMeD/Client/","COA.concept"));



    //tabbedPane.setTabPlacement(JTabbedPane.RIGHT);
    tabbedPane.setSelectedIndex(0);
    //add(tabbedPane);
    add("Center",tabbedPane);
    reloadButton = new JButton("reload views only");
    reloadButton.addActionListener (new reloadListener());
    add("South",reloadButton);
  }

  class reloadListener implements ActionListener {
    public void actionPerformed (ActionEvent e) {
      reload();
    }
  }

  // need to be modified//
  public void reload () {
    tabbedPane.removeAll();    
    //tabbedPane.addTab("Method List", null, new methodListPanel(es));
    
    tabbedPane.addTab("Method Sub-Method Relation", null, new GRPanel("method-relation",es,null));
    tabbedPane.addTab("Method Capability Hierarchy", null, new treePanel("method-capability",es));

    undefinedGoalListPanel ugPanel = 
      new undefinedGoalListPanel(es, thePanel);
    if (ugPanel.empty())
      tabbedPane.addTab("Unmatched Capabilities", null, ugPanel);
    else 
      tabbedPane.addTab("Unmatched Capabilities", noteIcon, ugPanel);

    tabbedPane.addTab("Search Methods", null, new searchPanel(es,null,thePanel));
    tabbedPane.addTab("All Agenda", null, new messagePanel(es));
    tabbedPane.addTab("Evaluation Result", null, new resultPanel(es));
    tabbedPane.addTab("Set Top Goal", null, new setTopGoalPanel(es));
    tabbedPane.addTab("Method Relation in problem solving", null,
		  new psTabbedPanel(es,thePanel));
    //tabbedPane.addTab("Browse Ontology", null, new HtmlPanel(es,"file:d:\\BCBL-demo\\client\\","COA.concept"));
    tabbedPane.addTab("Browse Ontology", null, new HtmlPanel(es,"file:/nfs/v2/jihie/expect/EMeD/Client/","COA.concept"));
    tabbedPane.setSelectedIndex(0);

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
