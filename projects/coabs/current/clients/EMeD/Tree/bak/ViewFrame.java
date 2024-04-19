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
import Connection.ExpectServer;
import com.sun.java.swing.JOptionPane;

public class ViewFrame extends JFrame 
implements WindowListener, KeyListener{
  TextArea textArea = new TextArea();
  JButton okButton;
  JPanel buttons;
  String type;
  String[]      confirm = {"OK"};
  String defName;

  public static void main(String[] args) {
    //ExpectServer server = new ExpectServer();
    //JFrame frame = new ViewFrame("Concept", "jjj", "(Defconcept jjj)");
  }


  public ViewFrame(String editType, String name, 
	         String initText) {
    super("Show - " + editType);

    type = editType;
    textArea.setText(initText);
    textArea.addKeyListener(this);
    okButton = new JButton("ok");
    
    okButton.addActionListener(new okListener());
    buttons = new JPanel();//new GridLayout(1,0));
    buttons.add(okButton);
    getContentPane().setLayout(new BorderLayout());
    getContentPane().add("Center",textArea);
    getContentPane().add("South",buttons);
    addWindowListener(this);
    setSize(500,300);
    setLocation(150,150);
    setVisible(true);
    
  }
  
  class okListener implements ActionListener {
    public void actionPerformed(ActionEvent e) {   
      setVisible(false);
      dispose();
    }
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
