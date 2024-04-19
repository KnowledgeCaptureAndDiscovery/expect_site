package Describe;

import com.sun.java.swing.JPanel;
import com.sun.java.swing.JFrame;
import com.sun.java.swing.JTabbedPane;
import com.sun.java.swing.JButton;
import com.sun.java.swing.JTextPane;
import com.sun.java.swing.JScrollPane;
import com.sun.java.swing.JButton;

import java.awt.event.ActionListener;
import java.awt.event.ActionEvent;
import java.awt.BorderLayout;
import java.awt.event.WindowAdapter;
import java.awt.event.WindowEvent;
import java.awt.GridLayout;

import Connection.ExpectServer;
import ExpectWindowPanel;
import experiment.*;
public class psDescribePanel extends JPanel {  
  private JTabbedPane tabbedPane;
  private JButton reloadButton;
  private ExpectServer es;
  String treeAll="";
  String treeSuccess="";
  String treeShort="";
  String treeGoals="";
  String treePretty="";
  String treePrettyNL="";
  String treeDetail="";
  String exeGoals="";
  String exePretty="";

  private JButton treeAllButton;
  private JButton treeSuccessButton;
  private JButton treeShortButton;
  private JButton treeGoalsButton;
  private JButton treePrettyButton;
  private JButton treePrettyNLButton;
  private JButton treeDetailButton;

  private JButton exeGoalsButton;
  private JButton exePrettyButton;

  private JPanel buttons;

  private JTextPane psPane;
  private JScrollPane mainPane;

  public psDescribePanel (ExpectServer server) {
    es = server;
    setLayout(new BorderLayout());

    createButtons();

    add("South", buttons);

    psPane = new JTextPane();
    mainPane = new JScrollPane(psPane);
    add("Center",mainPane);
    //reloadButton = new JButton("reload");
    //reloadButton.addActionListener (new reloadListener());
    //add("South",reloadButton);
  }

  private void createButtons() {
    treeAllButton = new JButton("All");
    treeAllButton.addActionListener(new AllListener());
    treeSuccessButton = new JButton("Success");
    treeSuccessButton.addActionListener(new SuccessListener());
    //treeShortButton = new JButton("Short");
    //treeShortButton.addActionListener(new ShortListener());
    treeGoalsButton = new JButton("Goals");
    treeGoalsButton.addActionListener(new GoalsListener());
    treePrettyButton = new JButton("Pretty");
    treePrettyButton.addActionListener(new PrettyListener());
    //treePrettyNLButton = new JButton("Pretty (NL)");
    //treePrettyNLButton.addActionListener(new PrettyNLListener());
    //treeDetailButton = new JButton("Very Detail");
    //treeDetailButton.addActionListener(new DetailListener());

    exeGoalsButton = new JButton("Problem Goals");
    exeGoalsButton.addActionListener(new EXEGoalsListener());
    exePrettyButton = new JButton("Problem Goals(Pretty)");
    exePrettyButton.addActionListener(new EXEPrettyListener());

    buttons = new JPanel();
    buttons.setLayout (new GridLayout (2,0));
    buttons.add(treeAllButton);
    buttons.add(treeSuccessButton);
    //buttons.add(treeShortButton);
    buttons.add(treeGoalsButton);
    buttons.add(treePrettyButton);
    //buttons.add(treePrettyNLButton);
    //buttons.add(treeDetailButton);
    buttons.add(exeGoalsButton);
    buttons.add(exePrettyButton);
  }

  class AllListener implements ActionListener {
    public void actionPerformed (ActionEvent e) {
      saveData.record(" select: get ps tree all");
      getTreeAll();
    }
  }
  private void getTreeAll () {
    if (treeAll.equals("")) {
      treeAll = es.getPSTreeAll();
      saveData.record (treeAll);
    }
    psPane.setText (treeAll);
  }

  class SuccessListener implements ActionListener {
    public void actionPerformed (ActionEvent e) {
      saveData.record(" select: get ps tree success");
      getTreeSuccess();
    }
  }
  private void getTreeSuccess () {
    if (treeSuccess.equals("")) {
      treeSuccess = es.getPSTreeSuccess();
      saveData.record (treeSuccess);
    }
    psPane.setText (treeSuccess);
  }

  class ShortListener implements ActionListener {
    public void actionPerformed (ActionEvent e) {
      saveData.record(" select: get ps tree short");
      getTreeShort();
    }
  }
  private void getTreeShort () {
    if (treeShort.equals("")) {
      treeShort = es.getPSTreeShort();
      saveData.record (treeShort);
    }
    psPane.setText (treeShort);
  }

  class GoalsListener implements ActionListener {
    public void actionPerformed (ActionEvent e) {
      saveData.record(" select: get ps tree goals");
      getTreeGoals();
    }
  }
  private void getTreeGoals () {
    if (treeGoals.equals("")) {
      treeGoals = es.getPSTreeGoals();
      saveData.record (treeGoals);
    }
    psPane.setText (treeGoals);
  }

  class PrettyListener implements ActionListener {
    public void actionPerformed (ActionEvent e) {
      saveData.record(" select: get ps tree pretty");
      getTreePretty();
    }
  }
  private void getTreePretty () {
    if (treePretty.equals("")) {
      treePretty = es.getPSTreePretty();
      saveData.record (treePretty);
    }
    psPane.setText (treePretty);
  }
  class PrettyNLListener implements ActionListener {
    public void actionPerformed (ActionEvent e) {
      saveData.record(" select: get ps tree pretty NL");
      getTreePrettyNL();
    }
  }
  private void getTreePrettyNL () {
    if (treePrettyNL.equals("")) {
      treePrettyNL = es.getPSTreePrettyNL();
      saveData.record(treePrettyNL);
    }
    psPane.setText (treePrettyNL);
  }

  class DetailListener implements ActionListener {
    public void actionPerformed (ActionEvent e) {
      saveData.record(" select: get ps tree :very detail");
      getTreeDetail();
    }
  }

  private void getTreeDetail () {
    if (treeDetail.equals("")) 
      treeDetail = es.getPSTreeVeryDetail();
    psPane.setText (treeDetail);
  }

  class EXEGoalsListener implements ActionListener {
    public void actionPerformed (ActionEvent e) {
      saveData.record(" select: get ps tree :very detail");
      getEXEGoals();
    }
  }

  private void getEXEGoals () {
    if (exeGoals.equals("")) 
      exeGoals = es.getEXEGoals();
    psPane.setText (exeGoals);
  }

  class EXEPrettyListener implements ActionListener {
    public void actionPerformed (ActionEvent e) {
      saveData.record(" select: get ps tree :very detail");
      getEXEPretty();
    }
  }

  private void getEXEPretty () {
    if (exePretty.equals("")) 
      exePretty = es.getEXEPretty();
    psPane.setText (exePretty);
  }


  public static void main(String[] args) {
    ExpectServer es = new ExpectServer();
    JFrame frame = new JFrame("PS Describe Panel");
 
    frame.addWindowListener(new WindowAdapter() {
        public void windowClosing(WindowEvent e) {
	System.exit(0);
        }
      });
      
    frame.getContentPane().add("Center", new psDescribePanel(es));
    frame.setSize(1100, 600);
    frame.setVisible(true);
  }
}
