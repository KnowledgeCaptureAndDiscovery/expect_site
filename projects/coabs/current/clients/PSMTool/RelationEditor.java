//
// A simple relation editor that brings up a window to give the name of
// the new relation and has Lisp create it. The constructor takes the 
// LispSocketAPI and optionally a suggested domain and range, as strings.
//

import javax.swing.*;
import javax.swing.text.*;
import javax.swing.event.*;
import java.awt.*;
import java.awt.event.*;

import java.io.*;
import java.util.*;

import Connection.*;


public class RelationEditor extends JFrame {

    public LispSocketAPI lc = null;
    NameFieldPanel namePanel, domainPanel, rangePanel, defaultPanel;
    public boolean multiValued = false;
    RelationEditor self;

    public RelationEditor(LispSocketAPI passed_lc, String pDomain, 
		      String pRange) {
        super("Relation editor: new information about " + 
	    pDomain.substring(pDomain.lastIndexOf(':') + 1)
	    + "s");
        self = this;
        lc = passed_lc;
        makeRelationEditor(pDomain, pRange);
    }

    private class NameFieldPanel extends JPanel {
        private JTextField nameField = null;
        private int textLength = 20;
        private String packageName = "";

        public NameFieldPanel(String name) {
	  makeNFP(name);
        }

        public NameFieldPanel(String name, String initialValue) {
	  makeNFP(name);
	  setText(initialValue);
        }

        public NameFieldPanel(String name, String initialValue, int passedLength) {
	  textLength = passedLength;
	  makeNFP(name);
	  setText(initialValue);
        }

        public void makeNFP(String name) {
	  JLabel nameLabel = new JLabel(name);
	  nameField = new JTextField(textLength);
	  add(nameLabel);
	  add(nameField);
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
    }

    // First cut: 
    private void makeRelationEditor(String pDomain, String pRange) {

        getContentPane().setLayout(new BoxLayout(getContentPane(), BoxLayout.Y_AXIS));

        JPanel editPanel = new JPanel();

        namePanel = new NameFieldPanel("The");
        editPanel.add(namePanel);

        domainPanel = new NameFieldPanel("of a", pDomain, 15);
        editPanel.add(domainPanel);

        rangePanel = new NameFieldPanel("is a", pRange, 10);
        editPanel.add(rangePanel);

        getContentPane().add(editPanel);

        JLabel example = new JLabel("Example: the cost of a flight is a number");
        getContentPane().add(example);

        JPanel defaultHolderPanel = new JPanel();
        defaultPanel = new NameFieldPanel("Default value: ");
        defaultHolderPanel.add(defaultPanel);
        // This is padding to try to make the lines look nice.
        defaultHolderPanel.add(new JLabel("                                "));
        getContentPane().add(defaultHolderPanel);

        JPanel checkBoxRow = new JPanel();
        JCheckBox multiValuedBox = new JCheckBox("Can have more than one value at once");
        multiValuedBox.setSelected(multiValued);
        multiValuedBox.addItemListener(new ItemListener() {
	  public void itemStateChanged(ItemEvent e) {
	      if (e.getStateChange() == ItemEvent.DESELECTED)
		multiValued = false;
	      else
		multiValued = true;
	  }
        });
        checkBoxRow.add(multiValuedBox);
        getContentPane().add(checkBoxRow);

        JPanel buttonPanel = new JPanel();
        JButton cancelBut = new JButton("cancel");
        cancelBut.addActionListener(new ActionListener() {
	  public void actionPerformed(ActionEvent e) {
	      dispose();
	  }
        });
        JButton commitBut = new JButton("commit");
        commitBut.addActionListener(new ActionListener() {
	  public void actionPerformed(ActionEvent e) {
	      lc.sendLispCommand("(expect::add-relation-from-editor \""
			     + namePanel.getText() + "\" \""
			     + domainPanel.getText() + "\" \"" 
			     + rangePanel.getText() + "\" \""
			     + multiValued + "\" \"" 
			     + defaultPanel.getText() + "\")");
	      lc.safeReadLine();
	      // call the (overwritable) respondToDone function and disappear
	      respondToDone();
	      dispose();
	  }
        });
        buttonPanel.add(cancelBut);
        buttonPanel.add(commitBut);
        getContentPane().add(buttonPanel);

        pack();
        setVisible(true);
    }

    // This method is called when the user hits "commit" after creating
    // the new relation. It exists so it can be customized - see
    // MethodEditor for an example.
    public void respondToDone() {
    }

    public static void main(String[] args) {
        LispSocketAPI mainlc = new LispSocketAPI("camelot.isi.edu", "5679");
        RelationEditor re = new RelationEditor(mainlc, "", "");
    }
}
