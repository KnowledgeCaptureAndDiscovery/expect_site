//
// Building a list using checkboxes for all the possible elements.
// Jim Blythe, Dec 2000
//


import javax.swing.*;
import javax.swing.event.*;
import java.awt.*;
import java.awt.event.*;

import java.io.*;
import java.util.*;

public class ListBuilder extends JFrame {
  
  // I'm sticking with vectors for now for jdk1.1 compatibility, in case
  // I need to run this on a mac.
  Vector options = null;
  Vector currentList = null;

  ListBuilder self;
  CheckBoxListener myListener;

  JPanel listDisplay, commandPanel, optionPanel;
  JTextField listText;

  public ListBuilder(Vector initial, Vector allChoices) {
    super("Choose elements of set");

    options = allChoices;
    currentList = initial;
    self = this;
    myListener = new CheckBoxListener();
    
    getContentPane().setLayout(new BoxLayout(getContentPane(), BoxLayout.Y_AXIS));

    listDisplay = new JPanel();
    listText = new JTextField("\n\n\n\n", 40);
    displayCurrent();
    listDisplay.add(listText);
    listDisplay.setPreferredSize(new Dimension(500,1000));
    JScrollPane listScrollPane = new JScrollPane(listDisplay);
    listScrollPane.setVerticalScrollBarPolicy(JScrollPane.VERTICAL_SCROLLBAR_ALWAYS);
    listScrollPane.setPreferredSize(new Dimension(540, 200));
    getContentPane().add(listScrollPane);

    commandPanel = new JPanel();
    commandPanel.setLayout(new FlowLayout(FlowLayout.LEFT));
    JButton doneBut = new JButton("done");
    doneBut.addActionListener(new ActionListener() {
      public void actionPerformed(ActionEvent e) {
        self.performDone();
        self.dispose();
      }
    });
    commandPanel.add(doneBut);
    getContentPane().add(commandPanel);

    optionPanel = new JPanel();
    // set the width, see how long the panel needs to be then set the height
    // (in displayOptions).
    optionPanel.setPreferredSize(new Dimension(500,500));
    displayOptions();
    JScrollPane optionScrollPane = new JScrollPane(optionPanel);
    optionScrollPane.setVerticalScrollBarPolicy(JScrollPane.VERTICAL_SCROLLBAR_ALWAYS);
    optionScrollPane.setPreferredSize(new Dimension(540, 200));
    getContentPane().add(optionScrollPane);

    setSize(540, 500);
    pack();
    setVisible(true);
  }

  /** Listens to the check boxes. */
  class CheckBoxListener implements ItemListener {
    public void itemStateChanged(ItemEvent e) {
      JCheckBox source = (JCheckBox)e.getItemSelectable();
      
      if (e.getStateChange() == ItemEvent.DESELECTED)
        self.removeFromList(source.getText());
      else
        self.addToEndOfList(source.getText());
    }
  }

  // re-display the current list. Use the same format for lists that the
  // MethodEditor uses to avoid confusion.
  public void displayCurrent() {
    String s = "No elements";
    if (currentList != null) {
      s = "The set: ";
      for (int i = 0; i < currentList.size(); i++)
        s = s + (String)currentList.elementAt(i) + ", ";
    }
    listText.setText(s);
  }

  public void displayOptions() {
    for (int i = 0; i < options.size(); i++) {
      String s = (String)options.elementAt(i);
      boolean found = false;
      int j = 0;
      s = s.substring(s.lastIndexOf(":") + 1); // remove package prefix
      for (found = false, j = 0; j < currentList.size(); j++) {
        if (s.equals(currentList.elementAt(j)) == true) {
	found = true;
	break;
        }
      }
      // The checkbox is selected iff the string is currently in the list.
      JCheckBox cb = new JCheckBox(s, found);
      cb.addItemListener(myListener);
      optionPanel.add(cb);
    }
    /* Couldn't get this to work.
    Component cpts[] = optionPanel.getComponents();
    int maxY = 0;
    for (int i = 0; i < cpts.length; i++) {
      JComponent jc = (JComponent)(cpts[i]);
      if (jc.getY() > maxY)
        maxY = jc.getY();
    }
    */
    // This should give roughly 40 pixels per row.
    int maxY = options.size() * 13;
    System.out.println("Setting preferred length to " + maxY);
    optionPanel.setPreferredSize(new Dimension(500, maxY));
  }

  // Add an item to the end of the list. item does not need to be one of
  // the "options". This is a public method.
  public void addToEndOfList (String item) {
    if (currentList == null)
      currentList = new Vector();
    currentList.add(item);
    displayCurrent();
  }

  public void removeFromList (String item) {
    for(int i = 0; i < currentList.size(); i++) {
      if (item.equals((String)currentList.elementAt(i)) == true) {
        currentList.remove(i);
        break;
      }
    }
    displayCurrent();
  }

  // What to do when someone clicks "done". This is a public method
  // designed to be subclassed.
  public void performDone() {
  }

}
