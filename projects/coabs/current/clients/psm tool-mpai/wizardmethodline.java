import javax.swing.*;
import java.awt.*;
import java.awt.event.*;

import Connection.*;

public class WizardMethodLine extends WizardLine {

    String methodName;
    WizardMethodLine self;

    public WizardMethodLine(int passed_step, String data, CritiqueWizard pw) {
        super(passed_step, pw);

        methodName = LispSocketAPI.getPiece(data);
        index = data.indexOf(methodName) + methodName.length() + 1;
        self = this;

        JButton editBut = new JButton("Show me how to " + data.substring(index));
        editBut.setBackground(Color.white);
        editBut.addActionListener(new ActionListener() {
	  public void actionPerformed(ActionEvent e) {
	      new MethodEditor(methodName, wizard.lc) {
		// specify extra stuff when the user clicks done:
		// re-run the PS tree, re-build the EMeD data and
		// refresh the EMeD PS tree window, then close the
		// editor.
		public void respondToDone() {
		    self.respondToDone();
		    dispose();
		}
	      };
	  }
        });
        add(editBut);
    }

    public void respondToDone() {
        setDone();
        // Give the wizard a chance to update the script
        // based on the changes to the method.
        wizard.lc.sendLispCommand("(expect::ka-process-ps-tree)");
        wizard.lc.safeReadLine();
        wizard.processReply(methodName, "modified");
        wizard.refreshPSTree();
        wizard.setNext(step + 1);
    }
}
