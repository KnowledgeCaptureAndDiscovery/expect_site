//
// A text widget to view the plan, along with some controls.
//

import javax.swing.*;
import javax.swing.text.*;
import java.awt.*;
import java.awt.event.*;

import java.io.*;
import java.util.*;

import Connection.*;

public class PlanView extends JPanel {

  private JScrollPane planPanel = null;
  public LispSocketAPI lc = null;
  //public ActiveText planText = null;
  public PlanView self = null;
  public JPanel planViewPanel = null;
  public String concept = "";
  public NameFieldPanel fields[], selectedField = null;
  public CritiqueView critiqueView = null;
  public MethodEditor activeEditor = null;

  public PlanView(LispSocketAPI plc) {

    lc = plc;
    self = this;

    setLayout(new BorderLayout());
    setBorder(BorderFactory.createTitledBorder(BorderFactory.createLoweredBevelBorder(),
				       "Template View"));

    // button panel along the top
    JPanel buttonPanel = new JPanel();
    JButton loadPlanBut = new JButton("Load plan");
    loadPlanBut.addActionListener(new ActionListener() {
      public void actionPerformed(ActionEvent e) {
        lc.sendLispCommand("(namestring expect::*domain-plan-directory*)");
        // Lisp's os-independent file structure should take care of us here..
        String planDir = lc.safeReadLine();
        // Note: source for ExtensionFileFilter can be found in the
        // SwingSet demo.
        JFileChooser chooser = new JFileChooser(planDir.substring(2,planDir.length() - 1));
        //ExtensionFileFilter filter = new ExtensionFileFilter(); 
        //filter.addExtension("xml"); 
        //filter.addExtension("gif");
        //filter.setDescription("JPG & GIF Images"); 
        //chooser.setFileFilter(filter); 
        chooser.setDialogTitle("File containing plan");
        int returnVal = chooser.showOpenDialog(self); 
        if(returnVal == JFileChooser.APPROVE_OPTION) {
	String fullName = chooser.getSelectedFile().getAbsolutePath();
	System.out.println("Loading constraints from " + fullName);
	lc.sendLispCommand("(expect::set-plan-from-xml-file \"" +
		         fullName.replace('\\','/') + "\")");
	System.out.println("Server says: " + lc.safeReadLine());
	showPlan();
        }
      }
    });
    buttonPanel.add(loadPlanBut);
    
    JButton showplanBut = new JButton("Show plan");
    showplanBut.addActionListener(new ActionListener() {
      public void actionPerformed(ActionEvent e) {
        showPlan();
      }
    });
    buttonPanel.add(showplanBut);
    
    JButton editPlanBut = new JButton("Edit plan");
    editPlanBut.addActionListener(new ActionListener() {
      public void actionPerformed(ActionEvent e) {
        if (lc.connected() == true) {
	String line;
	lc.sendLispCommand("(expect::plan-from-exe-goal)");
	line = lc.safeReadLine();
	if (line != "NIL") {
	  new InstanceEditor(lc, line);
	}
        }
      }
    });
    //buttonPanel.add(editPlanBut);

    JButton addPlanBut = new JButton("Add plan");
    addPlanBut.setEnabled(false);
    buttonPanel.add(addPlanBut);

    JButton newBut = new JButton("New field");
    newBut.addActionListener(new ActionListener() {
      public void actionPerformed(ActionEvent e) {
        addNewField();
      }
    });
    buttonPanel.add(newBut);
    
    // add edit to tp menu 
    JButton editBut = new JButton("edit");
	buttonPanel.add(editBut);
    JButton detailsBut = new JButton("details");
	buttonPanel.add(detailsBut);

   
    JButton quitBut = new JButton("Quit");
    quitBut.addActionListener(new ActionListener() {
      public void actionPerformed(ActionEvent e) {
        try {lc.close(); } catch (IOException ie) {}
        System.exit(0);
      }
    });
    buttonPanel.add(quitBut);


    add(buttonPanel, BorderLayout.NORTH);


    /*
      planText = new ActiveText() {
      public void actionPerformed(MouseEvent e) {
      ActiveText pt = (ActiveText)e.getComponent();
      LayedData item = pt.selected;
        
      if (item.index == 1) {   // clicked on a method
      new MethodEditor(item.name, lc);
      }
      }
      };
      planPanel = new JScrollPane(planText);
      */
    planViewPanel = new JPanel();
    planViewPanel.setLayout(new BoxLayout(planViewPanel, BoxLayout.Y_AXIS));
    planPanel = new JScrollPane(planViewPanel);
    planPanel.setVerticalScrollBarPolicy(JScrollPane.VERTICAL_SCROLLBAR_ALWAYS);
    planPanel.setHorizontalScrollBarPolicy(JScrollPane.HORIZONTAL_SCROLLBAR_ALWAYS);
    planPanel.setPreferredSize(new Dimension(600,400));
    add(planPanel, BorderLayout.CENTER);

    // To show any plan information there is on startup, uncomment the
    // next line (not done by default since it holds up showing the window).
    // showPlan();
  }

  public void addNewField() {
    // Ultimately it should be easy to change any field's label. Until
    // then, this method should launch a dialog box to ask the name at
    // startup.
    if (selectedField != null) {
      lc.sendLispCommand("(expect::add-new-field-after '" + 
		     selectedField.name + ")");
    } else {
      lc.sendLispCommand("(expect::add-new-field-after nil)");
    }
    lc.safeReadLine();
    showPlan();
    //showFieldAndChildren(
  }

  public void showPlan() {
    planViewPanel.removeAll();  // This is probably costly compared to reusing
    if (lc.connected() == true) {
      lc.sendLispCommand("(expect::plan-from-exe-goal)");
      concept = lc.safeReadLine();
      lc.sendLispCommand("(expect::fields-to-show)");
      Vector fieldnames = (Vector)lc.readList().elementAt(0);
      System.out.println("Fields: " + fieldnames);
      fields = new NameFieldPanel[100];  // the list is nested..
      showFields(fieldnames, fields, 0, 0, new String[30], null);
    }
  }    

  public int showFields(Vector fieldnames, NameFieldPanel[] fields,
		    int fieldNum, int indent, String[] path,
		    NameFieldPanel parent) {
    // skip the first element, which is a field that has already been shown
    for (int i = 1; i < fieldnames.size() ; i++) {
      fieldNum = showFieldAndChildren((Vector)fieldnames.elementAt(i), 
			        fields, fieldNum, indent, path, parent);
    }
    return fieldNum;
  }

  public int showFieldAndChildren(Vector fieldList, NameFieldPanel[] fields,
			    int fieldNum, int indent, String[] path,
			    NameFieldPanel parent) {
    String l = (String)fieldList.elementAt(0);
    path[indent] = l;
    fields[fieldNum] = new NameFieldPanel(l, fieldNum, indent, concept, lc, critiqueView, this, path, parent);
    planViewPanel.add(fields[fieldNum]);
    if (parent != null) {
      fields[fieldNum].addParent(parent);
      parent.addChild(fields[fieldNum]);
    }
    // used to be 10, but now each field has a border of width 2.
    planViewPanel.add(Box.createRigidArea(new Dimension(0, 6)));
    planViewPanel.revalidate();
    planViewPanel.repaint();
    fieldNum += 1;
    if (fieldList.size() > 1) {
      fieldNum = showFields(fieldList, fields, fieldNum, indent + 1, path,
		        fields[fieldNum-1]);
    }
    return fieldNum;
  }

  public void setSelectedField(NameFieldPanel newSel) {
    if (selectedField != newSel) {
      NameFieldPanel oldSel = selectedField;
      selectedField = newSel;
      if (oldSel != null) {
        oldSel.setSelected(false);
      }
      if (activeEditor != null) {
        activeEditor.setNameFieldPanel(newSel);
      }
    }
  }

// This is call from a child when it's deselected, so no need to call back.
public void deSelectField(NameFieldPanel oldSel) {
  if (selectedField == oldSel)
    selectedField = null;
}

  // The "active editor" gets sent a message if the user clicks in a
  // field of the plan view. This message can be used to set the
  // "replace" field with code to compute the field, if the editor so chooses.
  public void setActiveEditor(MethodEditor med) {
    activeEditor = med;
  }



  public static void main(String[] args) {
    JFrame p = new JFrame();
    p.getContentPane().add(new PlanView(new LispSocketAPI("localhost", "5679")));
    p.pack();
    p.setVisible(true);
  }

}
