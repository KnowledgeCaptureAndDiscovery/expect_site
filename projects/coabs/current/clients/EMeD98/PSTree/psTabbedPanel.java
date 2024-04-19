package PSTree;

import com.sun.java.swing.JPanel;
import com.sun.java.swing.JFrame;
import com.sun.java.swing.JTabbedPane;
import com.sun.java.swing.JButton;
import java.awt.event.ActionListener;
import java.awt.event.ActionEvent;
import java.awt.BorderLayout;
import java.awt.event.WindowAdapter;
import java.awt.event.WindowEvent;

import Connection.ExpectServer;
import ExpectWindowPanel;
public class psTabbedPanel extends JPanel {  
  private JTabbedPane tabbedPane;
  private JButton reloadButton;
  private ExpectServer es;
  PSundefinedGoalsPanel ugPanel;
  public psTabbedPanel (ExpectServer server, ExpectWindowPanel rootPanel) {
    es = server;
    setLayout(new BorderLayout());

    tabbedPane = new JTabbedPane();
    ugPanel = new PSundefinedGoalsPanel(es, rootPanel);

    tabbedPane.addTab("Method Relation in problem solving", null, 
		      new PSTreePanel(es, this));
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
		  new PSTreePanel(es, this));
    tabbedPane.addTab("Unmatched Goals in problem solving", null, ugPanel);
    tabbedPane.setSelectedIndex(0);
  }
  public static void main(String[] args) {
    ExpectServer es = new ExpectServer();
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
