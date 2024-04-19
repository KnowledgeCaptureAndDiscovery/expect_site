// 
// Jihie Kim, 1999
// 
package editor;

import com.sun.java.swing.*;
import java.awt.event.*;
import java.awt.*;
import java.util.*;
import Connection.ExpectServer;

public class altPanel extends JPanel 
                  implements MouseListener{
  // cache
  private Vector instances = null;
  private Vector concepts = null;
  private Vector relations = null;
  private Vector goalForms = null;

  private Vector listOfAltButtons;
  private int selectedIdx = -1;
  private MEditor theParent;
  private ExpectServer es;

  private JButton commitButton;
  private eButton selectedButton = null;
  private int source = -1;
  private JScrollPane ascrollpane;
  JList listBox;
  private int numAlts;
  private Vector memory = new Vector();
  private Vector memoryDesc = new Vector();
  private Vector searchedCapButtons = null;
  public altPanel (MEditor parent,
	         ExpectServer theServer) {
    es = theServer;
    theParent = parent;
    setLayout(new BoxLayout(this, BoxLayout.Y_AXIS));
    setAlignmentX(LEFT_ALIGNMENT);
    searchedCapButtons = theParent.getSearchedCapability();
    if (searchedCapButtons != null) {
      memory.addElement(searchedCapButtons);
      memoryDesc.addElement(getDescriptionFromButtons(searchedCapButtons));
    }
  }

  public void updateAlts (String ntSelected,
		      Component c) {
    String xmlInput;
    removeAll();
    selectedButton = (eButton) c;
    source = selectedButton.getSource();
    selectedIdx = -1;
    // use CACHE
    if (ntSelected.equals("expect-instance-name")) {
      if (instances == null) {
        xmlInput = es.getEditAlts(ntSelected);
        //System.out.println(xmlInput);
        altListRenderer ar = new altListRenderer(xmlInput);
        listOfAltButtons = ar.getAlts();
        instances = listOfAltButtons;
      }
      else listOfAltButtons = instances;
    }
    else if (ntSelected.equals("expect-concept-name")) {
      if (concepts == null) {
        xmlInput = es.getEditAlts(ntSelected);
        //System.out.println(xmlInput);
        altListRenderer ar = new altListRenderer(xmlInput);
        listOfAltButtons = ar.getAlts();
        concepts = listOfAltButtons;
      }
      else listOfAltButtons = concepts;
    }    
    else if (ntSelected.equals("expect-goal-form")) {
      if (goalForms == null) {
        xmlInput = es.getEditAlts(ntSelected);
        //System.out.println(xmlInput);
        altListRenderer ar = new altListRenderer(xmlInput);
        listOfAltButtons = ar.getAlts();
        goalForms = listOfAltButtons;
      }
      else listOfAltButtons = goalForms;
    }
    else if (ntSelected.equals("expect-relation-name")) {
      if (relations == null) {
        xmlInput = es.getEditAlts(ntSelected);
        //System.out.println(xmlInput);
        altListRenderer ar = new altListRenderer(xmlInput);
        listOfAltButtons = ar.getAlts();
        relations = listOfAltButtons;
      }
      else listOfAltButtons = relations;
    }
    else if (source == theParent.BODY &&
	   (ntSelected.equals("expect-variable-name") ||
	    ntSelected.startsWith("?"))) {
      xmlInput = es.getEditVars(theParent.getDesc());
      System.out.println(xmlInput);
      altListRenderer ar = new altListRenderer(xmlInput);
      listOfAltButtons = ar.getAlts();
    }
    else {
      xmlInput = es.getEditAlts(ntSelected);
      //System.out.println(xmlInput);
      altListRenderer ar = new altListRenderer(xmlInput);
      listOfAltButtons = ar.getAlts();
    }
    Vector buttonsToDisplay = addSelections();
    listBox = new JList(buttonsToDisplay);
    //listBox.setSelectionMode(JList.SINGLE_SELECTION);
   
    // if there is only one alternative, set it selected
    if (buttonsToDisplay.size() == 1) {
      listBox.setSelectedIndex(0);
      selectedIdx = 0;
    }
    ascrollpane = new JScrollPane(listBox);
    add(ascrollpane);
    ascrollpane.updateUI();
    commitButton = new JButton("commit selection");
    commitButton.setName("commit");
    commitButton.setBackground(new Color(200,250,200));
    //commitButton.setForeground(Color.white);
    commitButton.addMouseListener(this);
    add (commitButton);
  }

    // create selection list
  private Vector addSelections() {
    Vector result = new Vector();
    numAlts = listOfAltButtons.size();

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
    if (source ==theParent.BODY) {
      updateMemory();
      for (int k =0; k < memory.size(); k++)
        result.addElement((String)memoryDesc.elementAt(k));
      if (selectedButton.getText().equals (" ")) 
        result.addElement("CUT and STORE");
      result.addElement("USER INPUT in FREE TEXT");
    }
    else if (source ==theParent.CAP) {
      String desc = selectedButton.getText();
      if (desc.equals("VARIABLE")|| desc.startsWith("?"))
        result.addElement("USER INPUT in FREE TEXT");
    }
    return result;
  }
  private void updateMemory() {
    searchedCapButtons = theParent.getSearchedCapability();
    if (searchedCapButtons != null) {
    int mindex = findInMemory(getDescriptionFromButtons(searchedCapButtons));
    if (mindex <0) {
      memory.addElement(searchedCapButtons);
      memoryDesc.addElement(getDescriptionFromButtons(searchedCapButtons));
    }
    }
    
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
        String desc = (String) listBox.getSelectedValue();
        if (desc.equals("CUT and STORE")) {
	String mdesc = getDescriptionFromButtons(theParent.getMappedButtonsFromSelected());
	memoryDesc.addElement(mdesc);
	memory.addElement(theParent.getMappedButtonsFromSelected());
	eButton bt = new eButton("EXPRESSION","",source);
	bt.setName("expect-expression");
	Vector v = new Vector();
	v.addElement(bt);
	theParent.replaceSelection(v);
        } 
        else if (desc.equals("USER INPUT in FREE TEXT")) {
	String userInput =  JOptionPane.showInputDialog(null, "INPUT:");
	if (null != userInput) {
	  userInput = userInput.trim();
	  Vector v = new Vector();
	  eButton bt = new eButton(userInput,"",source);
	  bt.setName("expect-expression");
	  v.addElement(bt);
	  theParent.replaceSelection(v);
	}
        }
        else if (index <numAlts) {
	  theParent.replaceSelection((Vector)listOfAltButtons.elementAt(index));
        }
        else {
	  int mindex = findInMemory(desc);
	  if (mindex >=0)
	    theParent.replaceSelection((Vector)memory.elementAt(mindex));
        }
      }
      selectedIdx = -1;
    }
   

  }

  public void mouseEntered(MouseEvent e) {;  }
  public void mouseExited(MouseEvent e) {;  } 

  public String getDescriptionFromButtons (Vector buttons) {
    String result = "";
    for (int i=0; i< buttons.size(); i++) 
      result = result + " "+ ((eButton)buttons.elementAt(i)).getText();
    return result;
  }
  public int findInMemory(String desc) {
    int i = 0;
    while (i<memoryDesc.size() && 
	 (!((String)memoryDesc.elementAt(i)).equals(desc)))
      i++;
    if (i==memoryDesc.size()) return -1; // not found
    else return i;
  }
}
