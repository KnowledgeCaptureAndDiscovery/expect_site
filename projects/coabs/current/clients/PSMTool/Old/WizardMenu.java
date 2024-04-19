import javax.swing.*;
import java.awt.*;
import java.awt.event.*;

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
	      setDone();
	      // variable and wizard are inherited from WizardLine.
	      if (choiceGroup.getSelection() != null) {
		wizard.processReply(variable, choiceGroup.getSelection().getActionCommand());
	      }
	      wizard.setNext(step + 1);
	      wizard.refreshPSTree();
	  }
        });
        add(okBut);
    }

}
