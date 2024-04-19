//
// Top-level class to start the Temple client
//

import javax.swing.*;
import javax.swing.text.*;
import java.awt.*;
import java.awt.event.*;

import java.io.*;
import java.util.*;

import Connection.*;

public class Temple extends JFrame {

  public LispSocketAPI lc = null;

  private String hostname = "localhost";
  private String port = "5679";
  
  private String concept = "";
  private Temple self = null;

  public Temple() {
    super("Deployment Template");
    self = this;

    lc = new LispSocketAPI(hostname, port);

    getContentPane().setLayout(new BoxLayout(getContentPane(), 
					     BoxLayout.Y_AXIS));
    concept = "EVALUATION::PLAN1";
    makeStandardFields();

    pack();
    setVisible(true);

    // Close up the main window nicely
    addWindowListener(new WindowAdapter() {
      public void windowClosing(WindowEvent e) {
	if (lc != null) {
	  try {lc.close(); } catch (IOException ie) {}
	}
	System.exit(0);
      }
    });
  }

  // Given an object name, gets the field list and creates a simple
  // editor.
  public void makeStandardFields() {
    lc.sendLispCommand("(expect::find-standard-role-concepts '" + 
		       concept + ")");
    Vector fields = (Vector)lc.readList().elementAt(0);
    for (int i = 0; i < fields.size() ; i++) {
      getContentPane().add(new NameFieldPanel((String)fields.elementAt(i)));
    }
  }

  
  // Copied from RelationEditor. Should make this a public class with
  // its own file if this becomes useful in general.
  // A widget that contains a label and a text field stuck
  // together. The getText and setText methods work on the text field.
  // I added a JButton to call up the method editor for the field.
  private class NameFieldPanel extends JPanel {
    private JTextField nameField = null;
    private int textLength = 20;
    private String name = "", packageName = "";

    public NameFieldPanel(String pname) {
      makeNFP(pname);
    }

    public NameFieldPanel(String pname, String initialValue) {
      makeNFP(pname);
      setText(initialValue);
    }

    public NameFieldPanel(String pname, String initialValue, int passedLength) {
      textLength = passedLength;
      makeNFP(pname);
      setText(initialValue);
    }

    public void makeNFP(String pname) {
      name = pname;
      JLabel nameLabel = new JLabel(pname);
      nameField = new JTextField(textLength);
      nameField.addKeyListener(new KeyAdapter() {
	public void keyTyped(KeyEvent e) {
	  if (e.getKeyChar() == '\n' || e.getKeyChar() == '\r') {
	    lc.sendLispCommand("(expect::set-role-concept '" +
			       name + " '" + concept + " '" +
			       getText() + ")");
	    lc.safeReadLine();
	  }
	}
      });

      JButton compute = new JButton("compute");
      compute.addActionListener(new ActionListener() {
	public void actionPerformed(ActionEvent e) {
	    computeRole();
	}
      });
      JButton editMethod = new JButton("edit constraint");
      editMethod.addActionListener(new ActionListener() {
	public void actionPerformed(ActionEvent e) {
	  lc.sendLispCommand("(expect::find-method-for-role-concept '" +
			     name + " '" + concept + ")");
	  String methodName = lc.safeReadLine();
	  new MethodEditor(methodName, lc) {
		  /* Don't bother with the java frame for now */
	    public void respondToDone() {
	      /*this.lc.sendLispCommand("(expect::send-java-code)");
	      String javaCode = "";
	      String line = this.lc.safeReadLine();
	      while (line.equals("done") == false) {
		javaCode = javaCode + "\n" + line;
		line = this.lc.safeReadLine();
	      }
	      this.lc.safeReadLine();  // consume function return.
	      JFrame f = new JFrame("Java representation");
	      f.getContentPane().add(new JTextArea(javaCode));
	      f.pack();
	      f.setVisible(true); */
	      dispose();
	      // Automatically recompute.
	      computeRole();
	      }
	  };
	}
      });
      add(nameLabel);
      add(nameField);
      add(compute);
      add(editMethod);
    }

      public void computeRole() {
	  lc.sendLispCommand("(expect::compute-role-concept '" + name +
			     " '" + concept + ")");
	  String result = lc.safeReadLine();
	  setText(result);
      }

    public void setText(String txt) {
      if (txt.lastIndexOf(':') != -1) {
	packageName = txt.substring(0,txt.lastIndexOf(':') + 1);
      }
      nameField.setText(txt.substring(txt.lastIndexOf(':') + 1));
    }

    public String getText() {
      return packageName + nameField.getText();
    }

    public float getValue() {
      java.text.NumberFormat nf = java.text.NumberFormat.getInstance();
      try {
	return nf.parse(getText()).floatValue();
      } catch (java.text.ParseException pe) {
	return 0;
      }
    }
  }
  
  public static void main(String[] args) {
    new Temple();
  }
}
