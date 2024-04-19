import javax.swing.*;
import java.awt.*;
import java.awt.event.*;

import Connection.*;

public class WizardLine extends JPanel {

    public int step;  // Step number of this line in the script.
    protected int index;
    protected CritiqueWizard wizard;
    protected String variable;
    JButton statusBut;

    public WizardLine(int passed_step, CritiqueWizard pass_wiz) {
        setLayout(new FlowLayout(FlowLayout.LEFT));
        variable = null;
        step = passed_step;
        wizard = pass_wiz;
        wizard.scriptLines[step] = this;
        index = 0;

        statusBut = new JButton("to do");
        statusBut.setBackground(Color.white);
        add(statusBut);
    }

    public WizardLine(int passed_step, String data, CritiqueWizard pass_wiz) {

        step = passed_step;

        setLayout(new FlowLayout(FlowLayout.LEFT));
        
        int space = data.indexOf(" ");
        variable = data.substring(0,space);

        statusBut = new JButton("to do");
        statusBut.setMargin(new Insets(0,0,0,0));
        statusBut.setBackground(Color.white);
        add(statusBut);

        String description = LispSocketAPI.getPiece(data.substring(space+1));
        JButton descBut = new JButton(step + ". " + description);
        descBut.setMargin(new Insets(0,0,0,0));
        add(descBut);

        space = data.indexOf(description) + description.length() + 1;
        String question = LispSocketAPI.getPiece(data.substring(space));
        int colNum = question.length();
        if (colNum > 50) colNum = 50;
        JTextArea qText = new JTextArea(question, 2 , (int)(colNum * 0.6));
        qText.setFont(new Font("SansSerif", Font.PLAIN, 12));
        qText.setLineWrap(true);
        qText.setWrapStyleWord(true);
        add(qText);

        wizard = pass_wiz;
        wizard.scriptLines[step] = this;
        index = data.indexOf(question) + question.length() + 1;
    }

    // Indicate that this line is the next to be processed.
    public void setNext() {
        statusBut.setText("doing");
        statusBut.setBackground(Color.green);
    }

    // Indicate that this line has been processed.
    public void setDone() {
        statusBut.setText("done");
        statusBut.setBackground(Color.gray);
    }
}

