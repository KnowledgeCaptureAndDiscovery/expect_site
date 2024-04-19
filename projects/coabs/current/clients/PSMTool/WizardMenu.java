import javax.swing.*;
import java.awt.*;
import java.awt.event.*;

import java.util.*;

import Connection.*;

// This is the class for a line in the wizard tool that implements a choice.
public class WizardMenu extends WizardLine {

    private ButtonGroup choiceGroup = null;

    public WizardMenu(int passed_step, String line, CritiqueWizard pw) {
        super(passed_step, line, pw);

        // Add a panel with a radio button for each entry in the list of
        // choices.
        JPanel radioPanel = new JPanel();
        radioPanel.setLayout(new GridLayout(0, 1));
        choiceGroup = new ButtonGroup();

        // Pick up all the choices as a list in the Lisp data string.
        String choices = LispSocketAPI.getPiece(line.substring(index));
        String butName;
        JRadioButton tmp;
        int choiceIndex = 0;
        while (choiceIndex < choices.length() && 
	     (butName = LispSocketAPI.getPiece(choices.substring(choiceIndex))) != null) {
	  tmp = new JRadioButton(butName);
	  tmp.setActionCommand(butName);
	  choiceGroup.add(tmp);
	  radioPanel.add(tmp);
	  // Need a better implementation.
	  choiceIndex = choices.indexOf(butName) + butName.length() + 1;
        }
        add(radioPanel);

        JButton okBut = new JButton("OK");
        okBut.addActionListener(new ActionListener() {
	  public void actionPerformed(ActionEvent e) {
	    performAction();
	  }
        });
        add(okBut);
    }
  
  public void performAction () {
    setDone();
    // variable and wizard are inherited from WizardLine.
    if (choiceGroup.getSelection() != null) {
      wizard.processReply(variable, choiceGroup.getSelection().getActionCommand());
    }
    wizard.setNext(step + 1);
    //wizard.refreshPSTree();
  }

  public void setAnswer (String answer) {
    // Find the button whose action command matches the string and set
    // it to be selected. Then perform the line's action.
    // Need to remove the "{}" around the string.
    System.out.println("Looking for " + answer);
    for (Enumeration en = choiceGroup.getElements() ; en.hasMoreElements() ; ) {
      JRadioButton bm = (JRadioButton)en.nextElement();
      if (bm.getActionCommand().equals(answer) == true) {
        bm.setSelected(true);
        System.out.println("Found it with button " + bm);
      }
      else
        bm.setSelected(false);
    }
    performAction();
  }

}
