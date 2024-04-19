import java.awt.*;
import java.awt.event.*;
import com.sun.java.swing.*; 
import com.sun.java.swing.text.*; 

import java.net.URL;

public class EeyoreQuotes extends JPanel {

    private Font demoFont = new Font("Serif", Font.PLAIN, 14);
    private boolean DEBUG = true;

    public EeyoreQuotes() {

	//create text field
	JTextField textField = new JTextField("Don't bustle me.", 15);
	textField.setFont(demoFont);

	//create password field
	JPasswordField passwordField = new JPasswordField("Don't now-then me.", 15);
	passwordField.setFont(demoFont);
	passwordField.setEchoChar('$');

	//create panel to contain text fields
	JPanel textFieldPane = new JPanel();
	textFieldPane.setLayout(new GridLayout(0, 1));
        textFieldPane.add(textField);
        textFieldPane.add(passwordField);
        textFieldPane.setBorder(BorderFactory.createCompoundBorder(
		      BorderFactory.createTitledBorder("Text Fields"),
		      BorderFactory.createEmptyBorder(0, 5, 5, 5)
	));

	//create text area
	String text = "It's snowing still. \nAnd freezing. \n" +
			"However, we haven't had \nan earthquake lately.";
	JTextArea textArea = new JTextArea(text);
	textArea.setEditable(false);
	textArea.setFont(demoFont);
	textArea.setMargin(new Insets(5,5,5,5));
	textArea.setPreferredSize(new Dimension(170,80));

	//create panel to contain text area
	JPanel textAreaPane = new JPanel();
	textAreaPane.add(textArea);
        textAreaPane.setBorder(BorderFactory.createCompoundBorder(
		      BorderFactory.createTitledBorder("Text Area"),
		      BorderFactory.createEmptyBorder(0, 5, 5, 5)
	));

	//create html area
	JEditorPane quotePane = null;
	JScrollPane scrollPane = null;
	try {
	    URL url = new URL("http://java.sun.com/docs/books/tutorial/ui/swing/" +
				"example-swing/EeyoreQuote.html");
	    quotePane = new JEditorPane(url);
	    quotePane.setEditable(false);
            scrollPane = new JScrollPane(quotePane);
	    scrollPane.setPreferredSize(new Dimension(300, 175));
	    if (DEBUG) {
	        System.out.println(quotePane.getText());
	        quotePane.setText(quotePane.getText());
	    }

	} catch (java.io.IOException e) {
            scrollPane = new JScrollPane(new JTextArea("Can't find HTML file."));
	    scrollPane.setFont(demoFont);
	}

	//create panel to contain html text
	JPanel htmlTextPane = new JPanel();
	htmlTextPane.add(scrollPane);
        htmlTextPane.setBorder(BorderFactory.createCompoundBorder(
                      BorderFactory.createTitledBorder("HTML Text"),
                      BorderFactory.createEmptyBorder(0, 5, 5, 5)
        ));


	GridBagLayout gridBag = new GridBagLayout();
	GridBagConstraints c = new GridBagConstraints();

	gridBag.setConstraints(textFieldPane, c);
	add(textFieldPane);

	c.gridwidth = GridBagConstraints.REMAINDER;

	gridBag.setConstraints(textAreaPane, c);
	add(textAreaPane);

	gridBag.setConstraints(htmlTextPane, c);
	add(htmlTextPane);

	setLayout(gridBag);
        setBorder(BorderFactory.createEmptyBorder(20, 20, 20, 20));

    }

    public static void main(String[] args) {
	JFrame frame = new JFrame("Eeyore Quotes");

	frame.addWindowListener(new WindowAdapter() {
	        public void windowClosing(WindowEvent e) {
		    System.exit(0);
		}
	    });

	frame.getContentPane().add("Center", new EeyoreQuotes());
	frame.pack();
	frame.show();
    }
}
