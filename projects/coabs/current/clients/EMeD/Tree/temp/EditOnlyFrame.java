//File: EditOnlyFrame.java
//
// Copyright (C) 1998 by Jihie Kim
// All Rights Reserved
//
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
import javax.swing.JFrame;
import javax.swing.JPanel;
import javax.swing.JButton;
import javax.swing.JComponent;
import Connection.*;
import javax.swing.JOptionPane;

public class EditOnlyFrame extends JFrame 
implements WindowListener, KeyListener{
  TextArea textArea = new TextArea();
  JButton doneButton;
  JButton cancelButton;
  JPanel buttons;
  ExpectSocketAPI thisServer;
  String type;
  String[]      confirm = {"OK"};
  String theName = "";
  JComponent parent;
  public static void main(String[] args) {
    //ExpectSocketAPI server = new ExpectSocketAPI();
    //JFrame frame = new EditOnlyFrame("Concept", "jjj", "(Defconcept jjj)");
  }


  public EditOnlyFrame(String editType, String name, 
		   String initText, ExpectSocketAPI theServer,
		   JComponent caller) {

    super("Show - " + editType);
    theName = name;
    parent = caller;
    type = editType;
    thisServer = theServer;
    textArea.setText(initText);
    textArea.addKeyListener(this);
    doneButton = new JButton("done");
    cancelButton = new JButton("cancel");
    
    doneButton.addActionListener(new doneEditListener());
    cancelButton.addActionListener(new cancelListener());
    buttons = new JPanel();//new GridLayout(1,0));
    buttons.add(doneButton);
    buttons.add(cancelButton);
    getContentPane().setLayout(new BorderLayout());
    getContentPane().add("Center",textArea);
    getContentPane().add("South",buttons);
    addWindowListener(this);
    setSize(500,300);
    setLocation(150,150);
    setVisible(true);
    
  }
  
  class doneEditListener implements ActionListener {
    public void actionPerformed(ActionEvent e) {   
      setVisible(false);
      String response = null;
      String newDefinition = textArea.getText();
      System.out.println("definition:"+newDefinition);
      //System.out.println("response:"+response);
      
	((EditOnlyPanel) parent).editPostProcess(theName, newDefinition);

    }
  }

  class cancelListener implements ActionListener {
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
