import javax.swing.*;
import java.awt.*;
import java.awt.event.*;

public class WizardPanel extends JPanel {

    private int index;
    private String variable;

    public WizardPanel(String title) {
        super();
        
        // Subwindows (panels and labels) arranged vertically.
        setLayout(new BoxLayout(this, BoxLayout.Y_AXIS));

        JPanel subPanel = new JPanel();
        subPanel.setBackground(Color.yellow);
        JLabel titleLabel = new JLabel(title);
        titleLabel.setFont(new Font("SansSerif", Font.PLAIN, 14));
        titleLabel.setForeground(Color.black);
        titleLabel.setBackground(Color.yellow);
        subPanel.setPreferredSize(titleLabel.getPreferredSize());
        subPanel.setMaximumSize(new Dimension(99999,
				      titleLabel.getPreferredSize().height * 3));
        subPanel.add(titleLabel);
        add(subPanel);
    }

}

