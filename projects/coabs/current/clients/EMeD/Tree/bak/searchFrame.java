package Tree;

import java.awt.BorderLayout;
import java.awt.TextArea;
import java.awt.event.ActionListener;
import java.awt.event.ActionEvent;
import java.awt.event.KeyListener;
import java.awt.event.KeyEvent;
import java.awt.event.WindowListener;
import java.awt.event.WindowEvent;
import java.awt.GridLayout;
import java.awt.BorderLayout;
import com.sun.java.swing.JFrame;
import com.sun.java.swing.JPanel;
import com.sun.java.swing.JButton;
import com.sun.java.swing.JComponent;
import com.sun.java.swing.JTestField;

public class SearchFrame extends JFrame 
implements WindowListener, KeyListener{

  JTextField inputField = new JTextField(30);
  JButton doneButton;
  JButton searchButton;
  JPanel buttons;
  JPanel searchInfo;
  JTree tree = null;

  public static void main(String[] args) {
    //ExpectServer server = new ExpectServer();
    //JFrame frame = new SearchFrame("Concept", "jjj", "(Defconcept jjj)");
  }


  public SearchFrame(ExpectServer theServer, String input) {
    super("Search Methods");
    getContentPane().setLayout(new BorderLayout());

    if (input == null) {
      JScrollPane scrollPane = new JScrollPane();
      
    }
    else {
      String xmlInput = theServer.getSearchedMethodNameList ("", input);
      methodListRenderer thisRenderer = new methodListRenderer(theServer);
      tree = thisRenderer.getMethodsAsTree(xmlInput);
      tree.setCellRenderer(new methodListCellRenderer());
      tree.expandPath(tree.findPath("Method List"));
      root = (expandableTreeNode) treeModel.getRoot();
      JScrollPane scrollPane = new JScrollPane(tree);
    }
    getContentPane().add("Center",scrollPane);

    inputField.setText(input);
    inputField.addKeyListener(this);
    searchInfo = new JPanel();
    searchInfo.add(inputField);
    searchButton = new JButton("Search");
    searchButton.addActionListener(new searchListener());
    searchInfo.add(searchButton);
    getContentPane().add("North",searchInfo);

    doneButton = new JButton("done");
    doneButton.addActionListener(new doneListener());
    buttons = new JPanel();//new GridLayout(1,0));
    buttons.add(doneButton);


    getContentPane().add("South",buttons);
    addWindowListener(this);
    setSize(500,300);
    setLocation(150,150);
    setVisible(true);
    
  }

  private JTree createSearchPanel(JTree tree) {
    
    
  }



  public void windowClosed(WindowEvent event){}
  public void windowDeiconified(WindowEvent event){}
  public void windowIconified(WindowEvent event){}
  public void windowActivated(WindowEvent event){}
  public void windowDeactivated(WindowEvent event){}
  public void windowOpened(WindowEvent event){}
  
  public void windowClosing(WindowEvent event)
  {  
    setVisible(false);
    dispose();
  }

  public void keyTyped(KeyEvent e)
  {
  }

  public void keyPressed(KeyEvent e)
  {
  }

  public void keyReleased(KeyEvent e)
  {
  }
}
