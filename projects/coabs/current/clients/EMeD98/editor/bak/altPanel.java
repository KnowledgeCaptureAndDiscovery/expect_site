// 
// Jihie Kim, 1999
// 

import com.sun.java.swing.*;
import java.awt.event.*;
import java.awt.*;
import java.util.*;
import Connection.ExpectServer;

public class altPanel extends JPanel 
                  implements MouseListener{
  private Vector listOfAltButtons;
  private int selectedIdx = -1;
  private MEditor theParent;
  private ExpectServer es;

  private JButton commitButton;
  private Component selectedButton = null;
  private JScrollPane altAggregate;
  private JPanel subPanel = null;
  public altPanel (MEditor parent,
	         ExpectServer theServer) {
    es = theServer;
    theParent = parent;
    setLayout(new BoxLayout(this, BoxLayout.Y_AXIS));
    setAlignmentX(LEFT_ALIGNMENT);

  }

  public void updateAlts (String ntSelected) {
    removeAll();
    subPanel = new JPanel();
    subPanel.setLayout(new BoxLayout(subPanel, BoxLayout.Y_AXIS));
    subPanel.setAlignmentX(LEFT_ALIGNMENT);
    selectedButton = null;
    selectedIdx = -1;
    String xmlInput = es.getEditAlts(ntSelected);
    System.out.println(xmlInput);
    altListRenderer ar = new altListRenderer(xmlInput);
    listOfAltButtons = ar.getAlts();
    addSelections();
    altAggregate = new JScrollPane(subPanel);
    add(altAggregate);
    subPanel.updateUI();
    altAggregate.updateUI();
    commitButton = new JButton("commit selection");
    commitButton.setName("commit");
    commitButton.setBackground(Color.red);
    commitButton.addMouseListener(this);
    add (commitButton);
  }

  private void addSelections() {
    int numAlts = listOfAltButtons.size();

    for(int i=0; i < numAlts; i++){
      String desc = "";
      Vector buttons = (Vector)listOfAltButtons.elementAt(i);
      int numBtns = buttons.size();
      for (int j=0; j < numBtns; j++) {
        desc = desc +" "+ ((eButton)buttons.elementAt(j)).getText();
      }
      eButton bt = new eButton (desc);
      System.out.println(desc);
      Integer ii = new Integer(i);
      bt.setName (ii.toString());
      bt.addMouseListener(this);
      subPanel.add (bt);
      //ascrollpane.add(bt);
    }
  }
  public void mousePressed(MouseEvent e) {;  }
  public void mouseReleased(MouseEvent e) {;}
  public void mouseClicked(MouseEvent e) {
    Component c = e.getComponent();
    String name = c.getName();
    if (name.equals("commit")) {
      if (selectedIdx >=0) {
        removeAll();
        theParent.replaceSelection((Vector)listOfAltButtons.elementAt(selectedIdx));
      }
      selectedIdx = -1;
    }
    else if (!(name.equals("") || name == null)) {
      c.setBackground(Color.white);
      c.repaint();
      if (selectedIdx >=0) {// old selection
        selectedButton.setBackground(Color.lightGray);
        selectedButton.repaint();
      }
      selectedButton = c;
      try {
        selectedIdx = Integer.parseInt(name);
        System.out.println("selected:" + selectedIdx);
      }
      catch (Exception ex) {
        System.out.println("invalid ID:"+ name);
        selectedIdx = -1;
      }
    }

  }

  public void mouseEntered(MouseEvent e) {;  }
  public void mouseExited(MouseEvent e) {;  } 
}
