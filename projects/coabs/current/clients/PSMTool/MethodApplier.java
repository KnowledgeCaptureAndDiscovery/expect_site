//
// Top-level class for a method applier - takes a capability and helps
// the user construct a test call on instances in the KB, then runs the
// execution tree and returns the result. Should lead to calling an
// execution tree widget so the user can check into the result in more
// detail, but this is not implemented yet.
//

// Jim, Jan 2001: created, based on the method editor, for RKF PI
// meeting.

import javax.swing.*;
import javax.swing.text.*;
import javax.swing.event.*;
import javax.swing.tree.*;
import java.awt.*;
import java.awt.event.*;

import java.io.*;
import java.util.*;

import Connection.*;

public class MethodApplier extends JFrame {

  public LispSocketAPI lc = null;
  private MethodApplier self = null;
  private StyleContext sc;
  private Style replaceHighlight, withHighlight;
  private ActiveText capArea = null; //, bodyArea = null;
  private JTree bodyArea = null;
  private DefaultTreeModel treeModel;
  private LayedData treeNL = null;
  private String methodName = null;
  ActiveAltText      alternatives;
  private static final int SELECTING_OLD = 1;
  private static final int SELECTING_NEW = 2;
  private int state = SELECTING_OLD;

  public MethodApplier(String passed_goalName, LispSocketAPI passed_lc)
  {
    super("Apply the method");
    System.out.println("beg of apply");
    lc = passed_lc;
    methodName = passed_goalName;
    self = this;
    sc = new StyleContext();
    //runAttr = new HashTable();

    getContentPane().setLayout(new BoxLayout(getContentPane(), BoxLayout.Y_AXIS));
    
    JPanel donePane = new JPanel();
    donePane.setLayout(new FlowLayout(FlowLayout.LEFT));
    JButton doneBut = new JButton("done");
    doneBut.addActionListener(new ActionListener() {
      public void actionPerformed(ActionEvent e) {
        self.dispose();
      }
    });
    donePane.add(doneBut);

    JButton applyBut = new JButton("apply");
    applyBut.addActionListener(new ActionListener() {
    
    public void actionPerformed(ActionEvent e) {
	lc.sendLispCommand("(expect::method-applier-apply)");
	String result = lc.safeReadLine();
	System.out.println("Result is :" + result);
	Document doc = capArea.getDocument();
	try {
	  doc.insertString(doc.getLength(), 
			   "\n   > " + result, 
			   capArea.sc.getStyle("bold"));
	} catch (BadLocationException ble) {
	  System.err.println("Couldn't display initial text in method applier");
	}
      }
    });
    donePane.add(applyBut);

    getContentPane().add(donePane);

    capArea = new ActiveText(sc) {
      public void actionPerformed(MouseEvent e) {
        if (state == SELECTING_OLD) {
	setAlternatives(selected.name);
        } else if (state == SELECTING_NEW) {
        }
      }
    };
    JScrollPane capScrollPane = new JScrollPane(capArea);
    capScrollPane.setVerticalScrollBarPolicy(JScrollPane.VERTICAL_SCROLLBAR_ALWAYS);
    capScrollPane.setPreferredSize(new Dimension(500,100));
    
    getContentPane().add(capScrollPane);

    alternatives = new ActiveAltText();
    alternatives.itemSeparator = "   ";
    JScrollPane bodyScrollPane = new JScrollPane(alternatives);
    bodyScrollPane.setVerticalScrollBarPolicy(JScrollPane.VERTICAL_SCROLLBAR_ALWAYS);
    bodyScrollPane.setPreferredSize(new Dimension(500,200));
    
    getContentPane().add(bodyScrollPane);
    System.out.println("goal being called");
    readAndDisplayGoal();

    pack();
    setVisible(true);
  }
  
  /*public MethodApplier(String passed_methodName, LispSocketAPI passed_lc) {

    super("Apply the method");
    lc = passed_lc;
    methodName = passed_methodName;
    self = this;
    sc = new StyleContext();
    //runAttr = new HashTable();

    getContentPane().setLayout(new BoxLayout(getContentPane(), BoxLayout.Y_AXIS));
    
    JPanel donePane = new JPanel();
    donePane.setLayout(new FlowLayout(FlowLayout.LEFT));
    JButton doneBut = new JButton("done");
    doneBut.addActionListener(new ActionListener() {
      public void actionPerformed(ActionEvent e) {
        self.dispose();
      }
    });
    donePane.add(doneBut);

    JButton applyBut = new JButton("apply");
    applyBut.addActionListener(new ActionListener() {
      public void actionPerformed(ActionEvent e) {
	lc.sendLispCommand("(expect::method-applier-apply)");
	String result = lc.safeReadLine();
	System.out.println("Result is :" + result);
	Document doc = capArea.getDocument();
	try {
	  doc.insertString(doc.getLength(), 
			   "\n   > " + result, 
			   capArea.sc.getStyle("bold"));
	} catch (BadLocationException ble) {
	  System.err.println("Couldn't display initial text in method applier");
	}
      }
    });
    donePane.add(applyBut);

    getContentPane().add(donePane);

    capArea = new ActiveText(sc) {
      public void actionPerformed(MouseEvent e) {
        if (state == SELECTING_OLD) {
	setAlternatives(selected.name);
        } else if (state == SELECTING_NEW) {
        }
      }
    };
    JScrollPane capScrollPane = new JScrollPane(capArea);
    capScrollPane.setVerticalScrollBarPolicy(JScrollPane.VERTICAL_SCROLLBAR_ALWAYS);
    capScrollPane.setPreferredSize(new Dimension(500,100));
    
    getContentPane().add(capScrollPane);

    alternatives = new ActiveAltText();
    alternatives.itemSeparator = "   ";
    JScrollPane bodyScrollPane = new JScrollPane(alternatives);
    bodyScrollPane.setVerticalScrollBarPolicy(JScrollPane.VERTICAL_SCROLLBAR_ALWAYS);
    bodyScrollPane.setPreferredSize(new Dimension(500,200));
    
    getContentPane().add(bodyScrollPane);

    readAndDisplayMethod();

    pack();
    setVisible(true);
  } */

  private class ActiveAltText extends ActiveText {
    String concept = "";
    public void actionPerformed(MouseEvent e) {
      ActiveText pt = (ActiveText)e.getComponent();
      LayedData item = pt.selected;
	  
      if (item != null) {
        // Assuming single-valued for now.
        if (item.name != null) 
	updateValue(item.name);
        else {  // this means we're adding a new instance.
	new InstanceEditor(lc, concept) {
	  public void respondToDone() {
	    updateValue(instanceName.getText());
	  }
	};
        }
	      
      }
	  
    }
  }

  public void readMethodGoal(String command) {
  	System.out.println("read method with " + command);
    lc.sendLispCommand(command);
    System.out.println("sent");
    Vector indexedNL = lc.readList();
    System.out.println("Read " + indexedNL);
    
    // Currently all lists have length 1, extra nesting added by the
    // new server.
    indexedNL = (Vector)indexedNL.elementAt(0);
    System.out.println("Read goal: " + indexedNL);
    
    // Hack to make treeNL an overall object that points to both
    // pieces of linked text.
    treeNL = new LayedData(0);
    treeNL.children = new Vector();
    //Vector subNL = (Vector) indexedNL.elementAt(1);
    LayedData capabilityData = makeTreeNL((Vector)indexedNL,
					  capArea.normalStyle);
    treeNL.children.addElement(capabilityData);

    // install the LayedData in the capability active text object
    capArea.lData = treeNL;
  }
  
  public void displayMethod() {
    Document doc = capArea.getDocument();
    
    try {
      Vector kids = treeNL.children;
      doc.remove(0, doc.getLength());
      //doc.insertString(doc.getLength(), "", capArea.sc.getStyle("bold"));
      capArea.displayLayedData((LayedData)kids.elementAt(0));
    } catch (BadLocationException ble) {
      System.err.println("Couldn't display initial text in method applier");
    }
  }
  
  // Parse the 4-element list structure of lisp's linked text into LayedData.
  public LayedData makeTreeNL(Vector linkedNL, Style style) {
    LayedData res = new LayedData();
    
    res.normalStyle = style;
    Vector english = (Vector)linkedNL.elementAt(0);
    if (english.size() > 0) {
      res.text = (String)english.elementAt(0);
    }
    res.name = (String)linkedNL.elementAt(2);
    // Process any error info.
    if (linkedNL.size() > 4) {
      System.out.println("Errors for " + res.name + ": " 
		     + linkedNL.elementAt(4));
      // If there is a problem other than with the children, make the
      // default style for this piece of text be the error style.
      Vector problems = (Vector)linkedNL.elementAt(4);
      for (int i = 0; i < problems.size(); i++) {
        Vector problem = (Vector)problems.elementAt(i);
        String pname = (String)problem.elementAt(0);
        if (pname.equals(":BAD-CHILDREN") == false) {
	res.normalStyle = capArea.errorStyle;  // red.
	Vector probEng = (Vector)problem.elementAt(1);
        }
      }
    }
    // build the children
    if (linkedNL.elementAt(3).equals("NIL") == false) {	// always true now
      Vector lkids = (Vector)linkedNL.elementAt(3);
      res.children = new Vector();
      for(int i = 0; i < lkids.size(); i++) {
        res.children.addElement(makeTreeNL((Vector)lkids.elementAt(i),
				   res.normalStyle));
      }
    }
    return res;
  }

  /*public void readAndDisplayMethod() {
    readMethodGoal("(let ((*package* (find-package \"EXPECT\"))) (expect::create-and-display-method-applier-goal '" + methodName + "))");
    displayMethod();
  }*/

  public void readAndDisplayGoal() {
    System.out.println("check goal");
    readMethodGoal("(let ((*package* (find-package \"EXPECT\"))) (expect::display-goal-to-apply \"" + methodName + "\"))");
    displayMethod();
  }
  void setAlternatives(String index) {
    alternatives.setText("");
    lc.sendLispCommand("(expect::concept-from-nl-index " + index + ")");
    String concept = lc.safeReadLine();
    alternatives.concept = concept;
    if (concept.equals("NUMBER") == false) {
      lc.sendLispCommand("(expect::kb-get-instances '" + concept + ")");
      Vector values = (Vector)lc.readList().elementAt(0);
      //System.err.println("The possible values are: " + values);
      LayedData altLD = new LayedData();
      for (int i = 0; i < values.size(); i++) {
        String instance = (String)values.elementAt(i);
        LayedData child = altLD.addChild
	(instance.substring
	 (instance.lastIndexOf(':') + 1));
        child.name = instance; // store the whole name here.
      }
      altLD.addChild("Add a new " + concept);
      alternatives.lData = altLD;
      alternatives.displayLayedData();
    }
  }

  public void updateValue(String name) {
    System.err.println("Updating concept with " + name);
    readMethodGoal("(expect::method-applier-update '" + name + ")");
    displayMethod();
  }

}
