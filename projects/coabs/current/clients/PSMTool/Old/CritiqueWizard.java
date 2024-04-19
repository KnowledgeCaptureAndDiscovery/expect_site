//
// Top-level class for a critique wizard frame
//


import javax.swing.*;
import java.awt.*;
import java.awt.event.*;

import java.io.*;

import Connection.*;

// Used to be a JFrame. Now as a JPanel the tool can be embedded in
// another window. If you want this to come up in its own window, create
// it and then call the setStandalone() method.

public class CritiqueWizard extends JPanel {

    public LispSocketAPI lc = null;

    public KATool parent = null;

    private WizardPanel questionPanel = null,
        methodPanel = null, runPanel = null;

    private WizardPanel[] sectionPanel;
    public WizardLine[] scriptLines;

    private int step = 1;

    public JFrame psTree = null;
    ExpectSocketAPI es = null;
    
    public CritiqueWizard() {}

    public CritiqueWizard(LispSocketAPI passed_lc, KATool passed_parent) {
        lc = passed_lc;
        parent = passed_parent;
        sectionPanel = new WizardPanel[20];
        scriptLines = new WizardLine[100];

        // Three panels arranged vertically.
        setLayout(new BoxLayout(this, BoxLayout.Y_AXIS));

        /* The panels are now set by the script, from the server.
W        questionPanel = new WizardPanel("Part 1. Answer some questions about the critique");
        cp.add(questionPanel);

        methodPanel = new WizardPanel("Part 2. Define some methods for the critique");
        cp.add(methodPanel);

        runPanel = new WizardPanel("Part 3. Check the critique");
        cp.add(runPanel);
        */

        processReply("start", "start");
    }

    // Create a frame to hold this panel and display it.
    public void setStandalone() {
        JFrame frame = new JFrame("Critique Wizard");
        frame.getContentPane().add(this);
        frame.pack();
        frame.setVisible(true);
    }

    public void processReply(String variable, String value) {
        String line;
        WizardPanel currentPanel = sectionPanel[0];

        // If the value has a space, send it to lisp in string quotes.
        if (value.indexOf(" ") == -1) {
	  lc.sendLispCommand("(evaluation::tcl-wizard-value '" + variable + " '" + value + ")");
        } else {
	  // otherwise send it as a symbol or number.
	  lc.sendLispCommand("(evaluation::tcl-wizard-value '" + variable + " \"" + value + "\")");
        }
        while ((line = lc.safeReadLine()).equals("done") == false) {
	  //System.out.println("Got line: " + line);
	  if (line.startsWith(":read ") == true) {
	      currentPanel.add(new WizardReader(step++, line.substring(6), this));
	      currentPanel.revalidate();
	  } else if (line.startsWith(":menu ") == true) {
	      currentPanel.add(new WizardMenu(step++, line.substring(6), this));
	      currentPanel.revalidate();
	  } else if (line.startsWith(":method-desc ") == true) {
	      // The sizes shouldn't be buried here, this is a first stab.
	      JTextArea descText = new JTextArea(line.substring(13), 3, 30);
	      descText.setFont(new Font("SansSerif", Font.PLAIN, 12));
	      descText.setLineWrap(true);
	      descText.setWrapStyleWord(true);
	      while ((line = lc.safeReadLine()).equals("done-method-desc") == false)
		descText.append(line);
	      JPanel holder = new JPanel();
	      holder.add(descText);
	      JButton treeBut = new JButton("show analysis");
	      // don't add the PS tree window directly here, because
	      // it talks to lisp through the socket and we are having
	      // a conversation right now. We may need to introduce a
	      // lock into LispSocketAPI.
	      treeBut.addActionListener(new ActionListener() {
		public void actionPerformed(ActionEvent e) {
		    refreshPSTree();
		}
	      });
	      holder.add(treeBut);
	      currentPanel.add(holder);
	      currentPanel.revalidate();
	  } else if (line.startsWith(":method ") == true) {
	      currentPanel.add(new WizardMethodLine(step++, line.substring(8),
					   this));
	      currentPanel.revalidate();
	  } else if (line.startsWith(":step ") == true) {
	      currentPanel.add(new WizardStep(step++, line.substring(6), this));
	      currentPanel.revalidate();
	  } else if (line.startsWith(":section ") == true) {
	      int section = Integer.parseInt(line.substring(9,10));
	      //System.out.println("Adding section " + section + "as " + line.substring(11));
	      sectionPanel[section] = new WizardPanel(line.substring(11));
	      add(sectionPanel[section]);
	  } else if (line.startsWith(":current section ") == true) {
	      int section = Integer.parseInt(line.substring(17,18));
	      //System.out.println("Switching to section " + section);
	      currentPanel = sectionPanel[section];
	  }
        }
        lc.safeReadLine();
    }

    public void refreshPSTree() {
        // If there is a KATool parent, refresh the PS tree
        // there. Otherwise create a standalone window.
        if (parent != null) {
	  parent.updateTree();
	  parent.updateAgenda();
        } else {
	  if (es == null)
	      es = new ExpectSocketAPI(lc);
	  // Make sure the EMeD info is up to date.
	  lc.sendLispCommand("(expect::ps-build-method-relation-tree-all)");
	  lc.safeReadLine();
	  //PSTree.PSTreePanel tp = new PSTree.PSTreePanel(es, null, null);
	  PSTree.psTabbedPanel tp = new PSTree.psTabbedPanel(es, null, this, true);
	  if (psTree == null) {
	      psTree = new JFrame("Summary of new critique");
	      psTree.setSize(700, 500);
	  } else
	      psTree.getContentPane().removeAll();
	  psTree.getContentPane().add(tp);
	  psTree.setVisible(true);
        }
    }

    // Find the script line with the given step number, and display it
    // as the next step.
    public void setNext(int thisStep) {
        // Check that we have added a line with this number, and if so
        // set it up as the next step.
        if (thisStep < step) {
	  scriptLines[thisStep].setNext();
        }
    }

    // This method is called from the method editor and the agenda to
    // inform the wizard that a particular method just got edited. If
    // there is a line for this method, it gets marked as "done". If it
    // was the current line, we move the script on.
    public void editedMethod(String methodName) {
        // Search through the script lines to find one for this method.
        int i;
        for (i = 0; i < scriptLines.length; i++) {
	  if (scriptLines[i] instanceof WizardMethodLine) {
	      WizardMethodLine wml = (WizardMethodLine)scriptLines[i];
	      if (wml.methodName.equals(methodName) == true) {
		boolean wasCurrent = wml.statusBut.getText().equals("doing");
		wml.respondToDone();
		if (wasCurrent == true && i + 1 < scriptLines.length &&
		    scriptLines[i+1] != null) {
		    scriptLines[i+1].setNext();
		}
	      }
	  }
        }
    }

    public static void main(String[] args) {
        CritiqueWizard cw = new CritiqueWizard();
        cw.setStandalone();
    }
    
}
