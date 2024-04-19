//
// Top-level class to view the set of critiques and their results
//

import javax.swing.*;
import javax.swing.text.*;
import java.awt.*;
import java.awt.event.*;

import java.io.*;
import java.util.*;

import Connection.*;

public class CritiqueView extends JPanel {

  private JScrollPane critPanel = null;
  private JPanel buttonPanel = null;
  private ActiveText critText = null;
  private Component glue;
  public LispSocketAPI lc = null;
  public CritiqueWizard critiqueWizard = null;
  public String fieldShown = null;
  
  private boolean showCritiqueTrace = false;

  public CritiqueView self = null;
  
  public CritiqueView(LispSocketAPI plc) {

    lc = plc;
    self = this;


    setLayout(new BoxLayout(this, BoxLayout.Y_AXIS));
    setBorder(BorderFactory.createTitledBorder(BorderFactory.createLoweredBevelBorder(),
				       "Constraint View"));
    
    buttonPanel = new JPanel();
    
    JButton runBut = new JButton("Show all");
    runBut.addActionListener(new ActionListener() {
      public void actionPerformed(ActionEvent e) {
        runCritiquer();
      }
    });
    buttonPanel.add(runBut);
    
    /*
      JButton showBut = new JButton("Show critique");
      showBut.addActionListener(new ActionListener() {
      public void actionPerformed(ActionEvent e) {
      showCritique();
      }
      });
      buttonPanel.add(showBut); */

    /*
      JButton newGrammarBut = new JButton("Add from grammar");
      newGrammarBut.addActionListener(new ActionListener() {
      public void actionPerformed(ActionEvent e) {
      String topLine[] = {},
      featureLine[] = {"show me the", "[feature]"},
      critLine[] = {"warn me if the", "[feature]", "@1"},
      boundLine[] = {"@1", "[some threshold]"},
      upperLine[] = {"is more than"},
      lowerLine[] = {"is less than"};
      GClass top = new GClass(topLine),
      feature = new GClass(featureLine),
      critique = new GClass(critLine),
      bound = new GClass(boundLine),
      upper = new GClass(upperLine),
      lower = new GClass(lowerLine);
				    
      top.addPartition(feature);
      top.addPartition(critique);
      critique.addPartition(bound);
      bound.addPartition(lower);
      bound.addPartition(upper);
				    
      //KAGrammarTool kagt = new KAGrammarTool(lc, self, top);
      }
      });
      //buttonPanel.add(newGrammarBut);
      */

    JButton loadBut = new JButton("Load");
    loadBut.addActionListener(new ActionListener() {
      public void actionPerformed(ActionEvent e) {
        JFileChooser chooser = new JFileChooser(); // Note: source for ExtensionFileFilter can be found in the SwingSet demo
        //ExtensionFileFilter filter = new ExtensionFileFilter(); 
        //filter.addExtension("jpg"); 
        //filter.addExtension("gif");
        //filter.setDescription("JPG & GIF Images"); 
        //chooser.setFileFilter(filter); 
        chooser.setDialogTitle("File to load constraints");
        int returnVal = chooser.showOpenDialog(self); 
        if(returnVal == JFileChooser.APPROVE_OPTION) {
	String fullName = chooser.getSelectedFile().getAbsolutePath();
	System.out.println("Loading constraints from " + fullName);
	lc.sendLispCommand("(expect::load-constraints-from-file \""
+ fullName + "\")");
	System.out.println("Server says: " + lc.safeReadLine());
        }
      }
    });
    buttonPanel.add(loadBut);
    
    JButton saveBut = new JButton("Save");
    saveBut.addActionListener(new ActionListener() {
      public void actionPerformed(ActionEvent e) {
        JFileChooser chooser = new JFileChooser(); // Note: source for ExtensionFileFilter can be found in the SwingSet demo
        //ExtensionFileFilter filter = new ExtensionFileFilter(); 
        //filter.addExtension("jpg"); 
        //filter.addExtension("gif");
        //filter.setDescription("JPG & GIF Images"); 
        //chooser.setFileFilter(filter); 
        chooser.setDialogType(JFileChooser.SAVE_DIALOG);
        chooser.setDialogTitle("File to save constraints");
        int returnVal = chooser.showOpenDialog(self); 
        if (returnVal == JFileChooser.APPROVE_OPTION) {
	String fullName = chooser.getSelectedFile().getAbsolutePath();
	System.out.println("Saving constraints to " + fullName);
	lc.sendLispCommand("(expect::save-constraints-to-file \""
+ fullName + "\")");
	System.out.println("Server says: " + lc.safeReadLine());
        }
      }
    });
    buttonPanel.add(saveBut);

	
    JButton newCritiqueBut = new JButton("Add new");
    newCritiqueBut.addActionListener(new ActionListener() {
      public void actionPerformed(ActionEvent e) {
        //new CritiqueWizard(lc, self);
        new KATool(lc, self, null);
      }
    });
    buttonPanel.add(newCritiqueBut);

    /*
      JButton javaBut = new JButton("Show java code");
      javaBut.addActionListener(new ActionListener() {
      public void actionPerformed(ActionEvent e) {
      JFrame f = new JFrame("Java code");
      JTextArea text = new JTextArea();
      text.setFont(new Font("SansSerif", Font.PLAIN, 12));
      JScrollPane sp = new JScrollPane(text);
      sp.setVerticalScrollBarPolicy(JScrollPane.VERTICAL_SCROLLBAR_ALWAYS);
      sp.setPreferredSize(new Dimension(500,500));
      f.getContentPane().add(sp);
      lc.sendLispCommand("(expect::show-compiled-java)");
      String res;
      while ((res = lc.safeReadLine()).equals("done") == false
      && res != "")
      text.append(res + "\n");
      f.pack();
      f.setVisible(true);
      }
      });
      buttonPanel.add(javaBut);
      */

    /*JLabel methodLabel = new JLabel("Methods");
      buttonPanel.add(methodLabel);

      JButton psTreeBut = new JButton("PS Tree");
      psTreeBut.addActionListener(new ActionListener() {
      public void actionPerformed(ActionEvent e) {
      JFrame f = new JFrame("testing EMeD call");
      ExpectSocketAPI es = new ExpectSocketAPI(lc);
      PSTree.PSTabbedPanel tp = new PSTree.PSTabbedPanel(es, null, null, true);
      f.getContentPane().add(tp);
      f.setSize(700, 500);
      f.setVisible(true);
      }
      });
      buttonPanel.add(psTreeBut);

      methodsBut = new JButton("Show all methods");
      methodsBut.addActionListener(new ActionListener() {
      public void actionPerformed(ActionEvent e) {
      planText.setText("");
      if (lc.connected() == true) {
      lc.sendLispCommand("(expect::tcl-show-methods)");
      LayedData methods = lc.readLayedData();
      // Currently always a list of length one whose first
      // element is the list I want.
      methods = (LayedData) methods.children.elementAt(0);
      // Set up the methods so they can be read properly
      for (int i = 0; i < methods.children.size(); i++) {
      LayedData child = (LayedData)methods.children.elementAt(i);
      //System.out.println("Method " + (i+1) + child);
      Vector data = child.children;
      // There has to be a better representation.
      child.text = ((LayedData)((LayedData)data.elementAt(0)).children.elementAt(0)).text;
      child.name = ((LayedData)data.elementAt(2)).text;
      child.index = 1; // says it's a method, but I don't know how to do enumerations yet.
      child.children = null;
      }
      planText.lData = methods;
      planText.itemSeparator = "\n";
      planText.displayLayedData();
      }
      }
      });
      buttonPanel.add(methodsBut);
      */

    buttonPanel.setPreferredSize(buttonPanel.getMinimumSize());
    
    // The critique panel is on the right and scrolls the
    // critTextArea.
    critText = new ActiveText() {
      // I want to turn this off, but it tweaks that active text bug I
      // was having for the December experiments.
      public void actionPerformed(MouseEvent e) {
        ActiveText pt = (ActiveText)e.getComponent();
        LayedData item = pt.selected;
	  
        /*
	if (item.name != null) {   // clicked on a critique
	Cursor oldCursor = getCursor();
	setCursor(Cursor.getPredefinedCursor(Cursor.WAIT_CURSOR));
	new KATool(lc, self, item.name);
	setCursor(oldCursor);
	}
	*/
      }
    };

    //JTextArea(5,30);
    critPanel = new JScrollPane(critText);
    critPanel.setMaximumSize(new Dimension(99999,400));
    critPanel.setVerticalScrollBarPolicy(JScrollPane.VERTICAL_SCROLLBAR_ALWAYS);
    critPanel.setHorizontalScrollBarPolicy(JScrollPane.HORIZONTAL_SCROLLBAR_ALWAYS);

    buttonPanel.setMaximumSize(new Dimension(99999,
			     buttonPanel.getPreferredSize().height));
    add(buttonPanel);
    add(critPanel);

    glue = Box.createVerticalGlue();
    add(glue);
  }


  public void runCritiquer() {
    runCritiquer("", "NIL", "NIL");
  }

  public void runCritiquer(String field, String instance, String path) {
    Cursor oldCursor = getCursor();
    setCursor(Cursor.getPredefinedCursor(Cursor.WAIT_CURSOR));
    System.out.println("Showing field " + field);
    if (fieldShown != field) {
      clearWizard();
      fieldShown = field;
    }
    critText.setText("Running the critiquer...");
    if (lc.connected() == true) {
      if (field.equals("") == true) 
        lc.sendLispCommand("(expect::client-run-critiquer :compiled)");
      else
        lc.sendLispCommand("(expect::evaluate-field '" + field + 
		       " '" + instance + " " + path + ")");
      lc.safeReadLine();
    }
    showCritique();
    setCursor(oldCursor);
  }
  
  // Put the output for the critiques in the critText area.
  public void showCritique() {
    if (lc.connected() == true) {
      Style style = critText.normalStyle;
      LayedData cld = null;
      // The commented out lines below display the critique as plain text.
      // The lines in use display it as LayedData so it can be selected.
      critText.setText("");
      critText.lData = new LayedData();
      //critText.append("         Constraints\n\n");
      critText.lData.addChild("         Constraints\n\n");
      //commented by Mukta
      //lc.sendLispCommand("(evaluation::tcl-write-output)");
      lc.sendLispCommand("(expect::tcl-write-output)");
      String line;
      line = lc.safeReadLine();
      while (line.equals("done") == false) {
        if (line.indexOf("AA") == 0) {
	//critText.append("\n");
	if (cld != null)
	  critText.lData.addChild(cld);
	cld = new LayedData();
	cld.name = line.substring(2);
	cld.text = "\n";
        } else if (showCritiqueTrace == true || line.indexOf("xx") != 0) {
	if (line.indexOf("nv") == 0)
	  cld.normalStyle = critText.normalStyle;
	else if (line.indexOf("vv") == 0)
	  cld.normalStyle = critText.errorStyle;  // happens to be red.
	if (line.length() > 2) {
	  //critText.append(line.substring(2) + "\n", style);
	  cld.text = cld.text + line.substring(2) + "\n";
	}
        }
        line = lc.safeReadLine();
      }
      lc.safeReadLine();
      if (cld != null)
        critText.lData.addChild(cld);
      critText.displayLayedData();
      critText.revalidate();
    }
  }

  public void doWizard(String name, NameFieldPanel passed_field) {
    clearWizard();
    critiqueWizard = new CritiqueWizard(lc, self, passed_field, name);
    //add(critiqueWizard, BorderLayout.CENTER);
    remove(glue);
    add(critiqueWizard);
    add(glue);
    revalidate();
    repaint();
  }

  public void clearWizard() {
    if (critiqueWizard != null) {
      remove(critiqueWizard);
      revalidate();
      repaint();
      critiqueWizard = null;
    }
  }
  
  public static void main(String[] args) {
    JFrame p = new JFrame();
    p.getContentPane().add(new CritiqueView(new LispSocketAPI("localhost", "5679")));
    p.pack();
    p.setVisible(true);
  }
  
}
