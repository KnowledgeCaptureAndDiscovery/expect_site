//File: setTopGoalPanel.java
//
// Copyright (C) 1998 by Jihie Kim
// All Rights Reserved
//
package Tree;

import java.awt.BorderLayout;
import java.awt.TextArea;
import java.awt.event.*;
import java.awt.GridLayout;
import java.awt.BorderLayout;
import javax.swing.JFrame;
import javax.swing.JPanel;
import javax.swing.JButton;
import javax.swing.JComponent;
import javax.swing.JLabel;
import Connection.ExpectSocketAPI;
import javax.swing.JOptionPane;

public class setTopGoalPanel extends JPanel{
  TextArea textArea = new TextArea();
  TextArea inputArea = new TextArea();
  JButton okButton;
  private ExpectSocketAPI es;
  TextArea responseArea = new TextArea();

  public setTopGoalPanel(ExpectSocketAPI theServer) {
    //inputArea.addKeyListener(this);
    es = theServer;
    JPanel showPanel = new JPanel();
    showPanel.setLayout(new BorderLayout());
    textArea.setText(es.getTopGoal());
    showPanel.add("North",new JLabel("Current top goal"));
    showPanel.add("Center",textArea);
    
    JPanel inputPanel = new JPanel();
    inputPanel.setLayout(new BorderLayout());
    inputPanel.add("North",new JLabel("New top goal")); 
    inputPanel.add("Center",inputArea);

    okButton = new JButton("OK");
    okButton.addActionListener(new okListener());    
    JPanel responsePanel = new JPanel();//new GridLayout(1,0));

    responsePanel.setLayout(new BorderLayout());
    responsePanel.add("North",okButton);
    responsePanel.add("Center",responseArea);

    setLayout(new BorderLayout());
    add("North",showPanel);
    add("Center",inputPanel);
    add("South",responsePanel);

  }

  class okListener implements ActionListener {
    public void actionPerformed(ActionEvent e) {   
      String response = es.setTopGoal(inputArea.getText());
      responseArea.setText("RESPONSE:"+response);
    }
  }


  public static void main(String[] args) {
      JFrame frame = new JFrame("Set Top Goal");
      ExpectSocketAPI es = new ExpectSocketAPI();
      frame.addWindowListener(new WindowAdapter() {
        public void windowClosing(WindowEvent e) {
                  System.exit(0);
        }
      });
      
      frame.getContentPane().add("Center", new setTopGoalPanel(es));
      frame.setSize(800, 800);
      frame.setVisible(true);
    }
 




}
