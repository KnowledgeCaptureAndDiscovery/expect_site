package Tree;

import java.awt.BorderLayout;
import java.awt.TextArea;
import java.awt.event.*;
import java.awt.GridLayout;
import java.awt.BorderLayout;
import com.sun.java.swing.JFrame;
import com.sun.java.swing.JPanel;
import com.sun.java.swing.JButton;
import com.sun.java.swing.JComponent;
import Connection.ExpectServer;
import com.sun.java.swing.JOptionPane;

public class setTopGoalPanel extends JPanel{
  TextArea textArea = new TextArea();
  JButton okButton;
  private ExpectServer es;
  TextArea responseArea = new TextArea();

  public setTopGoalPanel(ExpectServer theServer) {
    //textArea.addKeyListener(this);
    es = theServer;
    okButton = new JButton("OK");
    okButton.addActionListener(new okListener());    
    JPanel buttons = new JPanel();//new GridLayout(1,0));

    buttons.setLayout(new BorderLayout());
    buttons.add("Center",responseArea);
    buttons.add("South",okButton);

    setLayout(new BorderLayout());
    add("Center",textArea);
    add("South",buttons);
  }

  class okListener implements ActionListener {
    public void actionPerformed(ActionEvent e) {   
      String response = es.setTopGoal(textArea.getText());
      responseArea.setText("RESPONSE:"+response);
    }
  }


  public static void main(String[] args) {
      JFrame frame = new JFrame("Set Top Goal");
      ExpectServer es = new ExpectServer();
      frame.addWindowListener(new WindowAdapter() {
        public void windowClosing(WindowEvent e) {
                  System.exit(0);
        }
      });
      
      frame.getContentPane().add("Center", new setTopGoalPanel(es));
      frame.setSize(800, 400);
      frame.setVisible(true);
    }
 




}
