// 
// Jihie Kim, 1999
// 
// process alternatives

package editor;

import javax.swing.*;
import java.awt.event.*;
import java.awt.*;
import java.util.*;
import Connection.*;

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
  private ExpectSocketAPI es;

  private eButton selectedButton = null;
  private int source = -1;
  private JScrollPane ascrollpane;
  private JScrollPane mscrollpane;
  JList listBox;
  private int numAlts;
  private Vector memory = new Vector();
  private Vector memoryDesc = new Vector();
  private Vector searchedCapButtons;
  private Vector searchedCaps;	 
   
  public altPanel (MEditor parent,
	         ExpectSocketAPI theServer) {
    es = theServer;
    theParent = parent;
    setLayout(new BoxLayout(this, BoxLayout.Y_AXIS));
    setAlignmentX(LEFT_ALIGNMENT);
    searchedCaps = theParent.getSearchedCapabilities();
    if (searchedCaps != null)
      for (int i=0; i<searchedCaps.size(); i++) {
	searchedCapButtons = (Vector) searchedCaps.elementAt(i);
	if (searchedCapButtons != null) {
	  memory.addElement(searchedCapButtons);
	  memoryDesc.addElement(getDescriptionFromButtons(searchedCapButtons));
	}
      }
  }

  public void updateAlts (String ntSelected,
		      Component c) {
    System.out.println("NT:"+ntSelected);
    String xmlInput;
    removeAll();
    selectedButton = (eButton) c;
    source = selectedButton.getSource();
    selectedIdx = -1;
    // use CACHE
    if (ntSelected.equals("expect-instance-name")) {
      if (instances == null) {
        xmlInput = es.getEditAlts(ntSelected);
        //System.out.println("EditAlts:"+xmlInput);
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
      //System.out.println(xmlInput);
      altListRenderer ar = new altListRenderer(xmlInput);
      listOfAltButtons = ar.getAlts();
    }
    else {
      xmlInput = es.getEditAlts(ntSelected);
      //System.out.println("NT:"+ntSelected + "\nEditAlts:"+xmlInput);
      altListRenderer ar = new altListRenderer(xmlInput);
      if (ntSelected.equals("expect-goal-form")) {
	listOfAltButtons = theParent.getSystemGoalsButtons();
	Vector alts = ar.getAlts();
	for (int i=0; i<alts.size(); i++) {
	  listOfAltButtons.addElement(alts.elementAt(i));
	}
      }
      else if (ntSelected.equals("expect-expression") &&
	       source == theParent.BODY &&
	       (selectedButton.getText().startsWith("(inst-of") ||
		selectedButton.getText().startsWith("(set-of"))) {
	listOfAltButtons = ar.getAlts();
	xmlInput = es.getVarForType(theParent.getDesc(),
				    selectedButton.getText());
	altListRenderer ar2 = new altListRenderer(xmlInput);
	Vector alts = ar2.getAlts();
	if (alts.size() ==1)
	  listOfAltButtons.addElement(alts.elementAt(0));
      }
      else       
	listOfAltButtons = ar.getAlts();
    }
    Vector options = addSelections();
    listBox = new JList(options);
    listBox.setCellRenderer(new editListCellRenderer());
    //listBox.setSelectionMode(JList.SINGLE_SELECTION);
   
    // if there is only one alternative, set it selected
    if (options.size() == 1) {
      listBox.setSelectedIndex(0);
      selectedIdx = 0;
    }
    ascrollpane = new JScrollPane(listBox);
    add(ascrollpane);

    ascrollpane.updateUI();
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
      //System.out.println(desc);
      result.addElement(desc);
    }
    if (source ==theParent.BODY) {
      updateMemory();
      for (int k =0; k < memory.size(); k++)
        result.addElement((String)memoryDesc.elementAt(k));
      if (selectedButton.getText().equals (" ")) {
	result.addElement("CUT");
      }
      result.addElement("COPY");
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
    searchedCaps = theParent.getSearchedCapabilities();
    for (int i=0; i<searchedCaps.size(); i++) {
      searchedCapButtons = (Vector) searchedCaps.elementAt(i);
      if (searchedCapButtons != null) {
	int mindex = findInMemory(getDescriptionFromButtons(searchedCapButtons));
	if (mindex <0) {
	  memory.addElement(searchedCapButtons);
	  memoryDesc.addElement(getDescriptionFromButtons(searchedCapButtons));
	}
      }
    }
      
  }
  public void mousePressed(MouseEvent e) {;  }
  public void mouseReleased(MouseEvent e) {;}
  public void mouseClicked(MouseEvent e) {
    Component c = e.getComponent();
    String name = c.getName();

  }
   
  public void commit () {
    int index = listBox.getSelectedIndex();

    selectedIdx = index;
    if (selectedIdx >=0) {
      removeAll();
      String desc = (String) listBox.getSelectedValue();
      if (desc.equals("CUT")) {
	String mdesc = getDescriptionFromButtons(theParent.getMappedButtonsFromSelected());
	memoryDesc.addElement(mdesc);
	memory.addElement(theParent.getMappedButtonsFromSelected());
	
	  eButton bt = new eButton("EXPRESSION","",source);
	  bt.setName("expect-expression");
	  Vector v = new Vector();
	  v.addElement(bt);
	  theParent.replaceSelection(v);
	
      } 
      else if (desc.equals("COPY")) {
	String mdesc = getDescriptionFromButtons(theParent.getMappedButtonsFromSelected());
	memoryDesc.addElement(mdesc);
	memory.addElement(theParent.getMappedButtonsFromSelected());
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

  class editListCellRenderer extends JLabel implements ListCellRenderer {
    public editListCellRenderer() {
      setOpaque(true);
    }
    public Component getListCellRendererComponent(
         JList list, 
         Object value, 
         int index, 
         boolean isSelected, 
         boolean cellHasFocus) 
     {
         setText(value.toString());
	 //System.out.println(" index:"+index);
	 //System.out.println(" numAlts:"+numAlts);
	 if (index >= numAlts)
	   setBackground(isSelected ? Color.blue : new Color(255,242,200));         
	 else setBackground(isSelected ? Color.blue : Color.white);
         setForeground(isSelected ? Color.white : Color.black);

         return this;
     }
  }

}
