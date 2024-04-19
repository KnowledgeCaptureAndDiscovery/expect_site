import javax.swing.*;
import java.awt.*;
import java.awt.event.*;

import java.io.*;

import Connection.*;

// This is the class for a line in the wizard tool that performs some
// pre-determined step.
public class WizardStep extends WizardLine {

    public String[] knownCommands = { "run_critiquer" };
    public String command;

    public WizardStep(int passed_step, String line, CritiqueWizard pw) {
        super(passed_step, line, pw);

        command = LispSocketAPI.getPiece(line.substring(index));
        //System.out.println("Index is " + index + ", so the command is " + command);

        JButton okBut = new JButton("OK");
        okBut.addActionListener(new ActionListener() {
	  public void actionPerformed(ActionEvent e) {
	      setDone();
	      performStep();
	      // variable and wizard are inherited from WizardLine.
	      wizard.processReply(variable, "performed");
	      wizard.setNext(step + 1);
	  }
        });
        add(okBut);
    }

    // This can be overwritten if some other action is desired.
    public void performStep() {
        if (command.equals("run_critiquer") == true) {
	  regenAndRunCritiquer();
        }
    }

    public void regenAndRunCritiquer() {
        wizard.lc.sendLispCommand("(evaluation::regen-critiquer)");
        wizard.lc.safeReadLine();
        wizard.parent.parent.run_critiquer();
    }

}

