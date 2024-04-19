import javax.swing.*;
import java.awt.*;
import java.awt.event.*;

// This is the class for a line in the wizard tool that reads a variable.
public class WizardReader extends WizardLine {

    private JTextField answer = null;

    public WizardReader(int step, String line, CritiqueWizard pw) {
        super(step, line, pw);

        answer = new JTextField(15);
        answer.setFont(new Font("SansSerif", Font.PLAIN, 12));
        answer.addKeyListener(new KeyAdapter() {
	  public void keyTyped(KeyEvent e) {
	      if (e.getKeyChar() == '\n' || e.getKeyChar() == '\r') {
		performAction();
	      }
	  }
        });
        add(answer);
        
        JButton okBut = new JButton("OK");
        okBut.addActionListener(new ActionListener() {
	  public void actionPerformed(ActionEvent e) {
	      performAction();
	  }
        });
        add(okBut);
    }

  public void setAnswer(String answerString) {
    answer.setText(answerString);
    performAction();
  }

    public void performAction() {
        setDone();
        // variable and wizard are inherited from WizardLine.
        wizard.processReply(variable, answer.getText());
        wizard.setNext(step + 1);
    }

}

