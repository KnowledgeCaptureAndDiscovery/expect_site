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

public class SmallTabbedPanel extends JPanel {  
  private JTabbedPane tabbedPane;
  private JButton reloadButton;
  private ExpectServer es;
  ExpectWindowPanel thePanel = null;

  static protected ImageIcon noteIcon = new ImageIcon("images/red.gif");

  public SmallTabbedPanel (ExpectServer server,
		        ExpectWindowPanel parent) {
    thePanel = parent;
    es = server;
    setLayout(new BorderLayout());

    tabbedPane = new JTabbedPane();
    PrintStream o = System.err;
    o.println("created main pane");
 
    tabbedPane.addTab("Describe PS Tree", null, new psDescribePanel(es));
    o.println("added describe ps tree panel");
    tabbedPane.addTab("Error Messages", null, new messagePanel(es));
    o.println("added agenda panel");
    tabbedPane.addTab("Evaluation Result", null, new resultPanel(es));
    tabbedPane.setSelectedIndex(0);

    tabbedPane.addChangeListener (new recordListener());
    //add(tabbedPane);
    add("Center",tabbedPane);

  }

  class recordListener implements ChangeListener {
    public void stateChanged (ChangeEvent e) {
      record();
    }
  }

  public void record () {
    int i = tabbedPane.getSelectedIndex();
    if (i == 0) saveData.record("check: Describe PS Tree");
    else if (i == 1) saveData.record ("check: Error Messages");
    else if (i == 2) saveData.record ("check: Evaluation result");
    else saveData.record ("check:"+i+"th tab");
    // the above is wrong
    // when i == 0: Describe PS Tree
    // when i == 1: error messages
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
    o.println("remove all");

    tabbedPane.addTab("Describe PS Tree", null, new psDescribePanel(es));
    o.println("added describe ps tree panel");
    tabbedPane.addTab("Error Messages", null, new messagePanel(es));
    o.println("added agenda panel");
    tabbedPane.addTab("Evaluation Result", null, new resultPanel(es));
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
      
      frame.getContentPane().add("Center", new SmallTabbedPanel(es, null));
      frame.setSize(1100, 600);
      frame.setVisible(true);
    }


}
