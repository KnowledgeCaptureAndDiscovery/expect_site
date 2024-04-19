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
  private JButton commitButton;
  private int selectedIdx = -1;
  private MEditor theParent;
  public altPanel (MEditor parent, String ntSelected,
	         ExpectServer es) {
    theParent = parent;
    commitButton = new JButton("commit");
    commitButton.setName("commit");
    add (commitButton);
    commitButton.setBackground(Color.red);
    commitButton.repaint();

    if (ntSelected.equals("")) {
      eButton dummyButton = new eButton(" test ");
      add (dummyButton);
    }
    else {
      String xmlInput = es.getEditAlts(ntSelected);
      System.out.println(xmlInput);
      altListRenderer ar = new altListRenderer(xmlInput);
      listOfAltButtons = ar.getAlts();
      addSelections();
    }

  }

  public void updateAlts (String ntSelected) {
    this.removeAll();
    commitButton = new JButton("commit");
    commitButton.setName("commit");
    add (commitButton);
    commitButton.setBackground(Color.red);
    commitButton.repaint();

    if (ntSelected.equals("")) {
      eButton dummyButton = new eButton(" test ");
      add (dummyButton);
    }
    else {
      String xmlInput = es.getEditAlts(ntSelected);
      System.out.println(xmlInput);
      altListRenderer ar = new altListRenderer(xmlInput);
      listOfAltButtons = ar.getAlts();
      addSelections();
    }
    
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
      add (bt);
      //ascrollpane.add(bt);
      System.out.println("n of component:"+getComponentCount());
    }
  }
  public void mousePressed(MouseEvent e) {;  }
  public void mouseReleased(MouseEvent e) {;}
  public void mouseClicked(MouseEvent e) {
    Component c = e.getComponent();
    String name = c.getName();
    if (name.equals("commit")) {
      if (selectedIdx >=0) {
        theParent.replaceSelection((Vector)listOfAltButtons.elementAt(selectedIdx));
      }
      selectedIdx = -1;
    }
    else if (!(name.equals("") || name == null)) {
      c.setBackground(Color.blue);
      c.repaint();
      try {
        selectedIdx = Integer.parseInt(name);
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
