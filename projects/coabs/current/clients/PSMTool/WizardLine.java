import javax.swing.*;
import java.awt.*;
import java.awt.event.*;

import Connection.*;

public class WizardLine extends JPanel {

  public int step;  // Step number of this line in the script.
  public int maxCols = 50; // Maximum width of the lines of text.
  public boolean answered = false, serverAsked = false;
  public Font textFont = null;
  public String description, comesAfter = null;
  protected int index;
  protected CritiqueWizard wizard;
  public String variable;
  JButton statusBut;

  public WizardLine(int passed_step, CritiqueWizard pass_wiz) {
    //setLayout(new FlowLayout(FlowLayout.LEFT));
    setLayout(new BoxLayout(this, BoxLayout.X_AXIS));
    variable = null;
    step = passed_step;
    wizard = pass_wiz;
    wizard.scriptLines[step] = this;
    index = 0;
    textFont = new Font("SansSerif", Font.PLAIN, 14);
      
    /*statusBut = new JButton("to do");
      statusBut.setMargin(new Insets(0,0,0,0));
      statusBut.setBackground(Color.white);
      add(statusBut);
      */
  }

  public WizardLine(int passed_step, String data, CritiqueWizard pass_wiz) {
    
    step = passed_step;
    
    setLayout(new FlowLayout(FlowLayout.LEFT));
    textFont = new Font("SansSerif", Font.PLAIN, 12);
    
    int space = data.indexOf(" ");
    variable = data.substring(0,space);
    
    // This button doesn't really reflect what's happening any more.
    /*statusBut = new JButton("to do");
      statusBut.setMargin(new Insets(0,0,0,0));
      statusBut.setBackground(Color.white);
      add(statusBut);
      */
    
    comesAfter = LispSocketAPI.getPiece(data.substring(space));
    
    space = data.indexOf(comesAfter) + comesAfter.length();
    description = LispSocketAPI.getPiece(data.substring(space+1));
    /* This was also confusing
       JButton descBut = new JButton(step + ". " + description);
       descBut.setMargin(new Insets(0,0,0,0));
       add(descBut);
       */
    JLabel numLabel = new JLabel(step + ". ");
    add(numLabel);

    space = data.indexOf(description) + description.length() + 1;
    String question = LispSocketAPI.getPiece(data.substring(space));


    int colNum = question.length();
    if (colNum > maxCols) colNum = maxCols;
    JTextArea qText = new JTextArea(question, 1, (int)(colNum * 0.6));
    qText.setFont(textFont);
    qText.setLineWrap(true);
    qText.setWrapStyleWord(true);
    add(qText);
    
    wizard = pass_wiz;
    wizard.scriptLines[step] = this;
    index = data.indexOf(question) + question.length() + 1;
  }

  // Ask the server for an answer for this question, and note that we
  // asked it, so this is only done once.
  public void askServer () {
    if (serverAsked == false) {
      String response;

      serverAsked = true;
      //commented by mukta
      /*wizard.lc.sendLispCommand("(evaluation::wizard-respond-to-query '" +
			  variable + ")");*/
			  
	wizard.lc.sendLispCommand("(expect::wizard-respond-to-query '" +
			  variable + ")");		  
      response = wizard.lc.safeReadLine();
      System.out.println("Response for " + step + " (" + variable
		     + ") is " + response);
      if (response.equals(" NIL") == true)
        return;
      while (response.startsWith(" ")) 
        response = response.substring(1);
      // remove any pesky package prefixes.
      response = response.substring(response.lastIndexOf(":") + 1);
      // remove any surrounding brackets.
      if (response.indexOf("{") == 0 && 
	response.indexOf("}") == response.length() - 1)
        response = response.substring(1,response.length() - 1);
      setAnswer(response);
    }
  }

  // If the server gives an answer for the question, we call this method
  // to do the book-keeping. It is subclassed in WizardReader,
  // WizardMenu and WizardMethodLine.
  public void setAnswer (String answer) {
  }
  
  // Indicate that this line is the next to be processed.
  public void setNext() {
    //statusBut.setText("doing");
    //statusBut.setBackground(Color.green);
  }
  
  // Indicate that this line has been processed.
  public void setDone() {
    answered = true;
    //statusBut.setText("done");
    //statusBut.setBackground(Color.gray);
  }

  public void updateSummary() {
  }
}
