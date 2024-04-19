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
  private JScrollPane ascrollpane;
  JList listBox;
  public altPanel (MEditor parent,
	         ExpectServer theServer) {
    es = theServer;
    theParent = parent;
    setLayout(new BoxLayout(this, BoxLayout.Y_AXIS));
    setAlignmentX(LEFT_ALIGNMENT);

  }

  public void updateAlts (String ntSelected) {
    removeAll();
    selectedButton = null;
    selectedIdx = -1;
    String xmlInput = es.getEditAlts(ntSelected);
    System.out.println(xmlInput);
    altListRenderer ar = new altListRenderer(xmlInput);
    listOfAltButtons = ar.getAlts();
    Vector buttonsToDisplay = addSelections();
    listBox = new JList(buttonsToDisplay);
    //listBox.setSelectionMode(JList.SINGLE_SELECTION);
    ascrollpane = new JScrollPane(listBox);
    add(ascrollpane);
    ascrollpane.updateUI();
    commitButton = new JButton("commit selection");
    commitButton.setName("commit");
    commitButton.setBackground(Color.red);
    commitButton.addMouseListener(this);
    add (commitButton);
  }

  private Vector addSelections() {
    Vector result = new Vector();
    int numAlts = listOfAltButtons.size();

    for(int i=0; i < numAlts; i++){
      String desc = "";
      Vector buttons = (Vector)listOfAltButtons.elementAt(i);
      int numBtns = buttons.size();
      for (int j=0; j < numBtns; j++) {
        desc = desc +" "+ ((eButton)buttons.elementAt(j)).getText();
      }
      System.out.println(desc);
      result.addElement(desc);
    }
    return result;
  }
  public void mousePressed(MouseEvent e) {;  }
  public void mouseReleased(MouseEvent e) {;}
  public void mouseClicked(MouseEvent e) {
    Component c = e.getComponent();
    String name = c.getName();
    if (name.equals("commit")) {
      int index = listBox.getSelectedIndex();
      selectedIdx = index;
      if (selectedIdx >=0) {
        removeAll();
        System.out.println(" selected in list:" + index);
        theParent.replaceSelection((Vector)listOfAltButtons.elementAt(index));
      }
      selectedIdx = -1;
    }
   

  }

  public void mouseEntered(MouseEvent e) {;  }
  public void mouseExited(MouseEvent e) {;  } 

}
