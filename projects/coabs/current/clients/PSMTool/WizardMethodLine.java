import javax.swing.*;
import javax.swing.event.*;
import java.awt.*;
import java.awt.event.*;

import Connection.*;

public class WizardMethodLine extends WizardLine {

  String methodName;
  WizardMethodLine self;
  WizardLine topLine;
  JLabel summary;
  int requiredLength = 100;

  public WizardMethodLine(int passed_step, String data, CritiqueWizard pw) {
    // Doesn't pass the data, so it isn't parsed.
    super(passed_step, pw);
    // Create a line structure for the top line. (The bottom line will
    // contain a summary of the method).
    topLine = new WizardLine(passed_step, pw);
    wizard = topLine.wizard;
    step = topLine.step;
    wizard.scriptLines[step] = this;

    setLayout(new BoxLayout(this, BoxLayout.Y_AXIS));
      
    methodName = LispSocketAPI.getPiece(data);
    variable = methodName; 
    index = data.indexOf(methodName) + methodName.length() + 1;
    self = this;

    comesAfter = LispSocketAPI.getPiece(data.substring(index));
    index = data.indexOf(comesAfter, index) + comesAfter.length() + 1;
      
    JLabel numLabel = new JLabel(step + ". ");
    topLine.add(numLabel);
    // Used to have "Show me how to " in front in the button.
    JButton editBut = new JButton(data.substring(index));
    /*
    int colNum = data.substring(index).length();
    if (colNum > maxCols) colNum = maxCols;
    MethodText editBut = new 
      MethodText(data.substring(index), 1, (int)(colNum * 0.6));
    */
    editBut.setMargin(new Insets(0,0,0,0));
    editBut.setBackground(Color.white);
    editBut.addActionListener(new ActionListener() {
      public void actionPerformed(ActionEvent e) {
        doEdit();
      }
    });
    topLine.add(editBut);
    topLine.add(Box.createHorizontalGlue());

    add(topLine);
    summary = new JLabel("This is the method summary", SwingConstants.LEFT);
    summary.setForeground(Color.black);
    JPanel summaryPanel = new JPanel(); // use default flow layout
    summaryPanel.add(summary);
    summaryPanel.add(Box.createHorizontalGlue());
    summaryPanel.setPreferredSize(topLine.getPreferredSize());

    // Can't call this from the constructor, because the server can send
    // several messages to construct method lines simultaneously, and
    // then the order would get mixed up. So this must be called by the
    // wizard when it knows that there's no more on the stack.
    //updateSummary();
    add(summaryPanel);

    setMinimumSize(getPreferredSize());
  }
  
  // If the server sends an automatic answer for this line, it wants the
  // client to pretend the method was modified in order to bump the
  // server along.
  public void setAnswer(String answer) {
    setDone();
    wizard.processReply(methodName, "modified");
    //wizard.refreshPSTree();
    if (wizard.nameField != null) {
      // If we know the field, just recompute for that field.
      wizard.nameField.computeConstraints();
      wizard.nameField.showDetails();
    } else {
      // Otherwise, recompute all the constraints.
      System.out.println("there was no name field");
      wizard.critiqueView.runCritiquer();
    }
    wizard.setNext(step + 1);
  }

  public void doEdit() {
    Cursor oldCursor = getCursor();
    setCursor(Cursor.getPredefinedCursor(Cursor.WAIT_CURSOR));
    MethodEditor med = new MethodEditor(methodName, wizard.lc) {
      // specify extra stuff when the user clicks done:
      // re-run the PS tree, re-build the EMeD data and
      // refresh the EMeD PS tree window, then close the
      // editor.
      public void respondToDone() {
        self.performAction();
        dispose();
      }
    };
    // disallow changing the capability since it was set up through
    // the PSM.
    med.editCapability = false;
    // Tell the PlanView about this methodeditor, so it can tell the
    // editor if the user clicks any NameFieldPanel
    if (wizard.nameField != null && wizard.nameField.planView != null) {
      wizard.nameField.planView.setActiveEditor(med);
    }
    setCursor(oldCursor);
  }

  // Called when the user selects "Done" from the method editor.
  public void performAction() {
    setDone();
    // Give the wizard a chance to update the script
    // based on the changes to the method.
    wizard.lc.sendLispCommand("(expect::ka-process-ps-tree)");
    wizard.lc.safeReadLine();
    wizard.processReply(methodName, "modified");
    wizard.refreshPSTree();
    if (wizard.nameField != null) {
      // If we know the field, just recompute for that field and also
      // for its parent if it has one. (If the parent's chosen value
      // could change, we really should recompute the siblings too but
      // I'm ignoring that for efficiency for now).
      if (wizard.nameField.parent != null)
        wizard.nameField.parent.computeConstraints();
      // would also call updateChildren() on the parent if needed.
      wizard.nameField.computeConstraints();
      wizard.nameField.showDetails();
    } else {
      // Otherwise, recompute all the constraints.
      System.out.println("there was no name field");
      wizard.critiqueView.runCritiquer();
    }
    wizard.setNext(step + 1);
  }

  public void updateSummary() {
    wizard.lc.sendLispCommand("(expect::get-method-summary '" + methodName
			+ ")");
    String rawLine = wizard.lc.safeReadLine();
    String line = "How: " + rawLine.substring(2,rawLine.length() - 1);
    while (line.length() < requiredLength) {
      line = line + " ";
    }
    summary.setText(line);
  }

  /*
  public class MethodText extends JTextArea implements MouseListener {

    public MethodText(String text, int rows, int columns) {
      super(text, rows, columns);
    }

    public void mouseClicked(MouseEvent e) {
      doEdit();
    }

    public void mouseEntered(MouseEvent e) {}
    public void mouseExited(MouseEvent e) {}
    public void mousePressed(MouseEvent e) {}
    public void mouseReleased(MouseEvent e) {}
  }
  */
}
