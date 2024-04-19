package Describe;

import com.sun.java.swing.JPanel;
import com.sun.java.swing.JFrame;
import com.sun.java.swing.JTabbedPane;
import com.sun.java.swing.JButton;
import com.sun.java.swing.JTextPane;
import com.sun.java.swing.JScrollPane;

import java.awt.event.ActionListener;
import java.awt.event.ActionEvent;
import java.awt.BorderLayout;
import java.awt.event.WindowAdapter;
import java.awt.event.WindowEvent;

import Connection.ExpectServer;
import ExpectWindowPanel;
public class psDescribePanel extends JPanel {  
  private JTabbedPane tabbedPane;
  private JButton reloadButton;
  private ExpectServer es;

  public psDescribePanel (ExpectServer server) {
    es = server;
    setLayout(new BorderLayout());

    tabbedPane = new JTabbedPane();

    tabbedPane.addTab("PS Tree: All", null, 
		  getPSPane("All"));
    tabbedPane.addTab("PS Tree: Success", null,
		  getPSPane("Success"));
    tabbedPane.addTab("PS Tree: Short", null,
		  getPSPane("Short"));
    tabbedPane.addTab("PS Tree: Goals", null,
		  getPSPane("Goals"));
    tabbedPane.addTab("PS Tree: Pretty", null,
		  getPSPane("Pretty"));
    tabbedPane.addTab("PS Tree: Pretty (NL)", null,
		  getPSPane("Pretty NL"));
    tabbedPane.addTab("PS Tree: Very Detail", null,
		  getPSPane("Very Detail"));
    
    tabbedPane.setSelectedIndex(0);
    tabbedPane.setTabPlacement(JTabbedPane.BOTTOM);
    add("Center",tabbedPane);
    //reloadButton = new JButton("reload");
    //reloadButton.addActionListener (new reloadListener());
    //add("South",reloadButton);
  }

  private JScrollPane getPSPane (String type) {
    String treeInString="";
    JTextPane psPane = new JTextPane();
    if (type.equals("All"))
      treeInString = es.getPSTreeAll();
    else if (type.equals("Success"))
      treeInString = es.getPSTreeSuccess();
    else if (type.equals("Short"))
      treeInString = es.getPSTreeShort();
    else if (type.equals("Goals")) 
      treeInString = es.getPSTreeGoals();
    else if (type.equals("Pretty")) 
      treeInString = es.getPSTreePretty();
    else if (type.equals("Pretty NL")) 
      treeInString = es.getPSTreePrettyNL();
    else if (type.equals("Very Detail")) 
      treeInString = es.getPSTreeVeryDetail();
    
    psPane.setText(treeInString);
    return new JScrollPane (psPane);
  }

  /*
  public void reload () {
    tabbedPane.removeAll(); 
    tabbedPane.addTab("PS Tree: All", null, 
		  getPSPane("All"));
    tabbedPane.addTab("PS Tree: Success", null,
		  getPSPane("Success"));
    tabbedPane.addTab("PS Tree: Short", null,
		  getPSPane("Short"));
    tabbedPane.addTab("PS Tree: Goals", null,
		  getPSPane("Goals"));
    tabbedPane.addTab("PS Tree: Pretty", null,
		  getPSPane("Pretty"));
    tabbedPane.addTab("PS Tree: Pretty (NL)", null,
		  getPSPane("Pretty NL"));
    tabbedPane.addTab("PS Tree: Very Detail", null,
		  getPSPane("Very Detail"));
    
    tabbedPane.setSelectedIndex(0);
    tabbedPane.setTabPlacement(JTabbedPane.BOTTOM);
  }
  */
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
