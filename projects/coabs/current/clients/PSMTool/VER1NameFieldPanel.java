// Copied from RelationEditor. Should make this a public class with
// its own file if this becomes useful in general.  A widget that
// contains a label and a text field stuck together. The getText and
// setText methods work on the text field.  I added a JButton to
// call up a method editor to compute the value for the field.

import javax.swing.*;
import javax.swing.text.*;
import java.awt.*;
import java.awt.event.*;

import java.io.*;
import java.util.*;

import Connection.*;

public class NameFieldPanel extends JPanel {
  public LispSocketAPI lc = null;
  public CritiqueView critiqueView = null;
  public PlanView planView = null;
  public boolean selected = false;
  public String concept = "";
  public JTextField labelField = null, valueField = null;
  public JComboBox valueCombo = null;
  public JPanel valuePanel = null;
  public int index = -1, indent = 0, textLength = 20, numValues = 0, 
    chosenValue = 0;
  public String name = "", longName = "", packageName = "";
  public String[] values = null;
  public NameFieldPanel self = null, parent = null;
  public Vector children = null;
  public String path;
  public Vector elementSatisfies = null;
  public Color neutral = null;

  public NameFieldPanel(String pname, int pindex, int pindent, String pconcept,
		    LispSocketAPI plc, CritiqueView pcv, PlanView ppv,
		    String[] ppath, NameFieldPanel pparent) {
    index = pindex;
    indent = pindent;
    concept = pconcept;
    lc = plc;
    critiqueView = pcv;
    planView = ppv;
    path = "'(";
    for (int i = 0; i < indent; i++)
      path = path + " " + ppath[i];
    path = path + ")";
    parent = pparent;
    neutral = getBackground();
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
    self = this;
    children = new Vector();
    setLayout(new BoxLayout(this, BoxLayout.X_AXIS));
    lc.sendLispCommand("(expect::get-label-for-field '" + name + ")");
    longName = lc.safeReadLine();
    longName = longName.substring(2, longName.length() - 1);
    //nameLabel = new JLabel(longName);
    //nameLabel.setForeground(Color.black);
    labelField = new JTextField(longName);
    labelField.addKeyListener(new KeyAdapter() {
      public void keyTyped(KeyEvent e) {
        if (e.getKeyChar() == '\n' || e.getKeyChar() == '\r') {
	    setLabel(getLabel());
        }
      }
    });
    labelField.addMouseListener(new MouseAdapter() {
      public void mouseClicked(MouseEvent e) {
        setSelected(true);
      }
    });

    valuePanel = new JPanel();
    valuePanel.setBorder(BorderFactory.createEmptyBorder());
    valueField = new JTextField();
    valueField.addKeyListener(new KeyAdapter() {
      public void keyTyped(KeyEvent e) {
        if (e.getKeyChar() == '\n' || e.getKeyChar() == '\r') {
	    setValue(getText());
        }
      }
    });


    /*
      JButton compute = new JButton("compute");
      compute.setMargin(new Insets(0,0,0,0));
      compute.addActionListener(new ActionListener() {
      public void actionPerformed(ActionEvent e) {
      toggleSelected();
      computeConstraints();
      }
      });
      */

    JButton editBut = new JButton("edit");
    editBut.setMargin(new Insets(0,0,0,0));
    editBut.addActionListener(new ActionListener() {
      public void actionPerformed(ActionEvent e) {
        toggleSelected();
        editField();
      }
    });

    JButton detailButton = new JButton("details");
    detailButton.setMargin(new Insets(0,0,0,0));
    detailButton.addActionListener(new ActionListener() {
      public void actionPerformed(ActionEvent e) {
        toggleSelected();
        showDetails();
      }});

    computeConstraints();
    int labelLength = 200 - indent * 25;
    labelField.setPreferredSize(new Dimension(labelLength, 20));
    labelField.setMaximumSize(new Dimension(labelLength, 20));
	valuePanel.setPreferredSize(new Dimension(200, 20));
    valuePanel.setMaximumSize(new Dimension(200, 20));
    add(Box.createHorizontalGlue());
    add(labelField);
    add(Box.createRigidArea(new Dimension(5, 0)));
    valuePanel.add(valueField);
    add(valuePanel);
    add(Box.createRigidArea(new Dimension(5, 0)));
    add(editBut);
    add(Box.createRigidArea(new Dimension(5, 0)));
    add(detailButton);
    setSelected(false);
  }

  public void setSelected(boolean selValue) {
    selected = selValue;
    if (selected == true) {
      setBorder(BorderFactory.createLineBorder(Color.black, 2));
    } else {
      setBorder(BorderFactory.createEmptyBorder(2,2,2,2));
    }
    if (planView != null) {
      if (selected == true)
        planView.setSelectedField(this);
      else
        planView.deSelectField(this);
    }
  }

  public void toggleSelected() {
    if (selected == true)
      setSelected(false);
    else
      setSelected(true);
  }

  public void computeConstraints() {
    Cursor oldCursor = getCursor();
    setCursor(Cursor.getPredefinedCursor(Cursor.WAIT_CURSOR));
    // Compute the value and write it into the text field
    /*lc.sendLispCommand("(expect::compute-and-display-field '" + name +
		   " '" + concept + " " + path + ")");*/
    // Send the expect goal appropriate for this point in the form
    if (parent == null) {
      lc.sendLispCommand("<compute><goal><action>compute</action>"
		     + "<param><name>obj</name><value>" + name 
		     + "</value></param>"
		     + "<param><name>of</name><value>" + concept
		     + "</value></param>"
		     + "</goal></compute>");
    } else {
      String parentVal;
      if (parent.numValues == 0) 
        parentVal = "0";
      else
        parentVal = parent.values[parent.chosenValue];
      lc.sendLispCommand("<compute><goal><action>compute</action>"
		     + "<param><name>obj</name><value>" + name 
		     + "</value></param>"
		     + "<param><name>of</name><value>" + parentVal
		     + "</value></param>"
		     + "<param><name>in</name><value>" + concept
		     + "</value></param>"
		     + "</goal></compute>");
    }
    String result = lc.safeReadLine().substring(1);
    // If it's a list, parse it and create a JComboBox to choose an element
    if (result.indexOf("{") != -1) { // used to look for "The set:"
      /*
      Vector names = new Vector();
      int index = result.indexOf("The set: ") + 9;
      int nextComma;
      while((nextComma = result.indexOf(',', index)) != -1) {
        names.add(result.substring(index, nextComma));
        index = nextComma + 2;
      }
      names.add(result.substring(index, result.length() - 1));
      */
      Vector names = lc.readList(result);
      names = (Vector)names.elementAt(0);
      numValues = names.size();
      values = new String[numValues];
      for (int i = 0; i < names.size(); i++)
        values[i] = (String)names.elementAt(i);
      if (valueCombo != null) {
       valuePanel.remove(valueCombo);
      }
      if (valueField != null)
      // ? remove(valueField); 
     valuePanel.remove(valueField);

      valueCombo = new JComboBox(names);
      valueCombo.setMaximumRowCount(30); // show many options without scrolling
      valueCombo.setRenderer(new NFPComboRenderer());
      // This is not part of the Constable API for most systems - they
      // would maintain their own info about choices and pass the choice
      // to Constable when sub-fields are computed. But we happen to
      // delegate that process to the server.
      lc.sendLispCommand("(expect::get-chosen-element-for-field '"
		         + name + " '" + concept + " " + path + ")");
      chosenValue = Integer.parseInt(lc.safeReadLine().substring(1));
      if (chosenValue >= 0 && chosenValue < names.size())
        valueCombo.setSelectedIndex(chosenValue);
      // Read whether each item satisfied the constraints or not
      lc.sendLispCommand("(expect::check-if-instances-satisfy-child-constraints  '"
		     + name + " '" + concept + " " + path + ")");
      elementSatisfies = (Vector)(lc.readList().elementAt(0));
      valueCombo.addActionListener(new ActionListener() {
        public void actionPerformed(ActionEvent e) {
	JComboBox cb = (JComboBox)e.getSource();
	chosenValue = cb.getSelectedIndex();
	// tell the server which element we're using
	lc.sendLispCommand("(expect::set-chosen-element-for-field '"
		         + name + " '" + concept + " " + path + " "
		         + chosenValue + ")");
	lc.safeReadLine();
	// recompute and re-display all the children whenever the selection
	// changes.
	updateChildren();
        }
      });
      valueCombo.setPreferredSize(new Dimension(200, 20));
      valueCombo.setMaximumSize(new Dimension(200, 20));
      add(valueCombo);

	valuePanel.add(valueCombo);
      valuePanel.revalidate();
      valuePanel.repaint();
      revalidate();
      repaint();
    } else {  // if it's not a list just fill the text field
      // Get rid of the brackets, since we passed a string.
      //setText(result.substring(2,result.length() - 1));
      setText(result.replace('-', ' '));
      values = new String[1];
      values[0] = result;
      numValues = 1;
      valueField.setPreferredSize(new Dimension(200, 20));
      valueField.setMaximumSize(new Dimension(200, 20));
    }

    // Compute whether the value violates the critique, and if so
    // paint the field red.
    lc.sendLispCommand("(expect::evaluate-field '" + name + " '" + 
		   concept + " " + path + ")");
    result = lc.safeReadLine();
    System.out.println("Evaluate " + name + " on " + concept + ": "
		       + result);
    if (result.equals(" FALSE") == true) {
      setBackground(Color.red);
    } else if (result.equals(" TRUE") == true) {
      setBackground(Color.green);
    } else {
      setBackground(neutral);
    }
    setCursor(oldCursor);
  }

  public void showDetails() {
    if (critiqueView != null)
      critiqueView.runCritiquer(name, concept, path);
  }
    
  public void setText(String txt) {
    valueField.setText(txt);
  }

    public void setValue(String text) {
	lc.sendLispCommand("(expect::set-field '" +
			   name + " '" + concept + " '" +
			   text + ")");
	lc.safeReadLine();
    }
    
  public String getText() {
    return packageName + valueField.getText();
  }

  public String getLabel() {
    return labelField.getText();
  }

    public void setLabel(String text) {
	lc.sendLispCommand("(expect::set-label '" +
			   name + " '" + concept + " \"" +
			   text + "\")");
	// update the stored field name if the call was successful.
	String newName = lc.safeReadLine().substring(1);
	System.out.println("New field name: " + newName);
	if (newName.equals("NIL") == false)
	    name = newName;
    }

  public float getValue() {
    java.text.NumberFormat nf = java.text.NumberFormat.getInstance();
    try {
      return nf.parse(getText()).floatValue();
    } catch (java.text.ParseException pe) {
      return 0;
    }
  }

  // call up the wizard to edit the field's methods.
  public void editField() {
    // First check if the field label should be updated.
    if (longName.equals(getLabel()) == false) {
      setLabel(getLabel());
    }

    // Then call up the KA script with the field name.
    //new KATool(lc, critiqueView, name, self);
    critiqueView.doWizard(name, self);

    /* The old code called the method editor directly
       (WARNING: find-method-for-field returns the structure not the name)
       lc.sendLispCommand("(expect::find-method-for-field '" +
       name + " '" + concept + " " + index + ")");
       String methodName = lc.safeReadLine();
       new MethodEditor(methodName, lc) {
       // Don't bother with the java frame for now
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
         f.setVisible(true); * /
         dispose();
         // Automatically recompute.
         computeConstraints();
         }
         };
         */
  }

  public void addChild(NameFieldPanel child) {
    children.add(child);
  }

  public void addParent(NameFieldPanel nfp) {
    parent = nfp;
  }

  public void updateChildren() {
    for (int i = 0; i < children.size(); i++) {
      ((NameFieldPanel)children.elementAt(i)).computeConstraints();
      ((NameFieldPanel)children.elementAt(i)).updateChildren();
    }
  }


  class NFPComboRenderer extends JLabel implements ListCellRenderer {
    public NFPComboRenderer() {
      setOpaque(true);
    }

    public Component getListCellRendererComponent(JList list,
					Object value,
					int index,
					boolean isSelected,
					boolean cellHasFocus) {
      // have to do the selection highlighting by hand.
      if (isSelected) {
        this.setBackground(list.getSelectionBackground());
        this.setForeground(list.getSelectionForeground());
      } else {
        this.setBackground(list.getBackground());
        setForeground(list.getForeground());
      }
      // colour the element red or green if we have information about
      // whether it satisfied the child constraints.
      if (isSelected == false && elementSatisfies != null && index >= 0 
	&& index < elementSatisfies.size() ) {
        String sat = (String)elementSatisfies.elementAt(index);
        if (sat.equals("1") == true) {
	this.setBackground(Color.green);
        } else if (sat.equals("0") == true) {
	this.setBackground(Color.red);
        }
      }
      // Do the pretty printing right in the rendered, so the stored
      // strings correspond to Lisp objects.
      this.setText(((String)value).replace('-', ' '));
      return this;
    }
  }
}
  
