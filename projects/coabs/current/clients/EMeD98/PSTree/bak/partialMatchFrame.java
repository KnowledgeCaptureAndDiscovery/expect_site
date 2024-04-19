package PSTree;

import java.awt.event.ActionListener;
import java.awt.event.ActionEvent;
import com.sun.java.swing.JFrame;
import com.sun.java.swing.JPanel;
import com.sun.java.swing.JScrollPane;
import com.sun.java.swing.JButton;
import com.sun.java.swing.JComponent;
import java.awt.BorderLayout;
import java.awt.GridLayout;
import java.awt.event.WindowListener;
import java.awt.event.WindowEvent;
import com.sun.java.swing.JOptionPane;

import Connection.ExpectServer;
import Tree.expandableTree;
import Tree.expandableTreeNode;
public class partialMatchFrame extends JFrame {
  ExpectServer es;
  JScrollPane sp;
  GRRenderer app;
  expandableTree tree;
  String xmlInput;

  JPanel buttons;
  private JButton applyButton;
  private JButton closeButton;
  psTabbedPanel thePSPanel;

  public partialMatchFrame (ExpectServer theServer,
		        psTabbedPanel thePanel) {
    super ("Potential Matches for incomplete goals");
    es = theServer;
    thePSPanel = thePanel;
    xmlInput = es.getPartialMatch();
    app = new GRRenderer(xmlInput,es);
    tree = app.getTree();
    if (tree.getRoot().getChildCount() == 0) {
      JOptionPane.showMessageDialog(null, "No potential match applicable.");
      return;
    }
    sp = new JScrollPane(tree);
    tree.setCellRenderer(new GRCellRenderer());
    tree.expandTree(); 
    getContentPane().setLayout(new BorderLayout());
    getContentPane().add("Center",sp);

    buttons = new JPanel();
    buttons.setLayout(new GridLayout(1,0));
    applyButton = new JButton("apply partial match");
    applyButton.addActionListener (new applyListener());
    closeButton = new JButton("close");
    closeButton.addActionListener (new closeListener());
    buttons.add(applyButton);
    //buttons.add(closeButton);
    getContentPane().add("South",buttons);
    //addWindowListener(this);
    setSize(700,300);
    setLocation(150,150);
    setVisible(true);
  }

  class applyListener implements ActionListener {
    public void actionPerformed (ActionEvent e) {
      applyMatch();
    }
  }

  private void applyMatch() {
    expandableTreeNode current = tree.getSelectedNode();
    if (current == null) {
      JOptionPane.showMessageDialog(null, "Please select a node first");
    }
    else {
      String name = tree.getSelectedName();
      es.applyPartialMatch(name);
      thePSPanel.reload();
      close();
    }
  }

  class closeListener implements ActionListener {
    public void actionPerformed (ActionEvent e) {
      close();
    }
  }
  private void close () {
    setVisible(false);
    dispose();
  }

  public static void main(String[] args) {
    ExpectServer server = new ExpectServer();
    JFrame frame = new partialMatchFrame(server,null);
  }
}
