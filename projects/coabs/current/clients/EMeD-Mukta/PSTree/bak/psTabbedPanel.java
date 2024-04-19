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
import Connection.ExpectServer;
import Connection.ExpectSocketAPI;
import ExpectWindowPanel;
public class psTabbedPanel extends JPanel {  
  private JTabbedPane tabbedPane;
  private JButton reloadButton;
  private ExpectSocketAPI es;
  PSundefinedGoalsPanel ugPanel;
  ExpectWindowPanel  thePanel;
  public psTabbedPanel (ExpectSocketAPI server, ExpectWindowPanel rootPanel) {
    es = server;
    thePanel = rootPanel;
    setLayout(new BorderLayout());
    
    tabbedPane = new JTabbedPane();
    ugPanel = new PSundefinedGoalsPanel(es, rootPanel);

    tabbedPane.addTab("Method Relation in problem solving", null, 
		      new PSTreePanel(es, this, rootPanel));
    tabbedPane.addTab("Unmatched Goals in problem solving", null, ugPanel);
    tabbedPane.setSelectedIndex(0);
    add("Center",tabbedPane);
    reloadButton = new JButton("reload");
    reloadButton.addActionListener (new reloadListener());
    add("South",reloadButton);
  }
  class reloadListener implements ActionListener {
    public void actionPerformed (ActionEvent e) {
      reload();
    }
  }

  public PSundefinedGoalsPanel getUGPanel() {
    return ugPanel;
  }

  public void reload () {
    tabbedPane.removeAll(); 
    PSundefinedGoalsPanel ugPanel = new PSundefinedGoalsPanel(es, null);
    tabbedPane.addTab("Method Relation in problem solving", null, 
		  new PSTreePanel(es, this, thePanel));
    tabbedPane.addTab("Unmatched Goals in problem solving", null, ugPanel);
    tabbedPane.setSelectedIndex(0);
  }
  public static void main(String[] args) {
    ExpectSocketAPI es = new ExpectSocketAPI();
    JFrame frame = new JFrame("PS Tabbed Panel");
 
    frame.addWindowListener(new WindowAdapter() {
        public void windowClosing(WindowEvent e) {
	System.exit(0);
        }
      });
      
    frame.getContentPane().add("Center", new psTabbedPanel(es, null));
    frame.setSize(1100, 600);
    frame.setVisible(true);
  }
}
