package PSTree;

import javax.swing.JPanel;
import javax.swing.JFrame;
import javax.swing.JTabbedPane;
import javax.swing.JButton;
import java.awt.event.ActionListener;
import java.awt.event.ActionEvent;
import java.awt.BorderLayout;
import java.awt.event.WindowAdapter;
import java.awt.event.WindowEvent;
import Connection.*;
import ExpectWindowPanel;
import CritiqueWizard;
import MethodEditor;
public class psTabbedPanel extends JPanel {  
  private JTabbedPane tabbedPane;
  private JButton reloadButton;
  private ExpectSocketAPI es;
  PSundefinedGoalsPanel ugPanel;
  ExpectWindowPanel  thePanel;
  boolean useNLEditor = false;
  CritiqueWizard wizard;
  String methodName;
  psTabbedPanel self;
  public psTabbedPanel (ExpectSocketAPI server, ExpectWindowPanel rootPanel,
			CritiqueWizard w, boolean useNL) {
    es = server;
    thePanel = rootPanel;
    setLayout(new BorderLayout());
    useNLEditor = useNL;
    wizard = w;
    self = this;
    tabbedPane = new JTabbedPane();


    ugPanel = new PSundefinedGoalsPanel(es, rootPanel, this, wizard, useNLEditor);
    tabbedPane.addTab("Unmatched Goals in problem solving", null, ugPanel);
    tabbedPane.addTab("Method Relation in problem solving", null, 
		      new PSTreePanel(es, this, rootPanel));



    tabbedPane.setSelectedIndex(1);
    add("Center",tabbedPane);
    reloadButton = new JButton("reload");
    reloadButton.addActionListener (new reloadListener());
    add("South",reloadButton);
  }
  class reloadListener implements ActionListener {
    public void actionPerformed (ActionEvent e) {
      reloadPSTabs();
    }
  }

  public void EditMethod (String name) {
    System.out.println(" edit method:"+name);
    methodName = name;
    new MethodEditor(methodName, es) {
      public void respondToDone() {
	if (wizard != null) {
	  wizard.editedMethod(methodName);
	}
	dispose();
	System.out.println("after dispose editor: psTab");
	String result = es.getUserMethodDef(methodName);
	//String result = es.postProcessNLEdit(methodName);
	//System.out.println(" result of post process:"+result);
	//System.out.println("before reload ps tabs");
	self.reloadPSTabs();
      }
    };
   
  }

  public PSundefinedGoalsPanel getUGPanel() {
    return ugPanel;
  }

  public void reloadPSTabs () {
    System.out.println("reload psTab");
    removeAll();
    tabbedPane = new JTabbedPane();
    ugPanel = new PSundefinedGoalsPanel(es, null, this, wizard, useNLEditor);
    tabbedPane.addTab("Unmatched Goals in problem solving", null, ugPanel);
    tabbedPane.addTab("Method Relation in problem solving", null, 
		  new PSTreePanel(es, this, thePanel));
    tabbedPane.setSelectedIndex(1);
    add("Center",tabbedPane);
    reloadButton = new JButton("reload");
    reloadButton.addActionListener (new reloadListener());
    add("South",reloadButton);
    updateUI();
    repaint();
  }
  public static void main(String[] args) {
    ExpectSocketAPI es = new ExpectSocketAPI();
    JFrame frame = new JFrame("Interdependency Analyzer");
 
    frame.addWindowListener(new WindowAdapter() {
        public void windowClosing(WindowEvent e) {
	System.exit(0);
        }
      });
      
    frame.getContentPane().add("Center", new psTabbedPanel(es, null,null,true));
    frame.setSize(1100, 600);
    frame.setVisible(true);
  }
}
