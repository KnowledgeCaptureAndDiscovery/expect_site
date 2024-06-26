//
// Top-level class to start the PSMTool client
//

import javax.swing.*;
import javax.swing.text.*;
import java.awt.*;
import java.awt.event.*;

import java.io.*;
import java.util.*;

import Connection.*;

/* I need to break this into two separate classes, with their own
controls. This way it will be clearer how to use pieces of this stuff in
other systems.
 */

public class PSMTool extends JFrame {

    private JScrollPane planPanel = null, critPanel = null;
    private JPanel buttonPanel = null;
    private ActiveText planText = null, critText = null;
    public LispSocketAPI lc = null;

    private String hostName = "localhost";
    private String port = "5679";

    private boolean showCritiqueTrace = false;

    private PSMTool self = null;

    public PSMTool() {

        super("Plan evaluator");

        self = this;

        setFont(new Font("SansSerif", Font.PLAIN, 12));

        JButton methodsBut, showplanBut, runBut;

        lc = new LispSocketAPI(hostName, port);

        // Three panels arranged horizontally.
        //getContentPane().setLayout(new GridLayout(1,0));
        getContentPane().setLayout(new BoxLayout(getContentPane(), BoxLayout.X_AXIS));

        // The plan panel scrolls the planTextArea
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
        planPanel.setVerticalScrollBarPolicy(JScrollPane.VERTICAL_SCROLLBAR_ALWAYS);
        planPanel.setHorizontalScrollBarPolicy(JScrollPane.HORIZONTAL_SCROLLBAR_ALWAYS);
        planPanel.setPreferredSize(new Dimension(400,400));

        getContentPane().add(planPanel);

        // The button panel goes down the middle.
        buttonPanel = new JPanel();
        //buttonPanel.setLayout(new GridLayout(0,1));
        buttonPanel.setMinimumSize(new Dimension(100,400));
        buttonPanel.setLayout(new BoxLayout(buttonPanel, BoxLayout.Y_AXIS));

        //JLabel psLabel = new JLabel("Problem solving");
        //buttonPanel.add(psLabel);

        // This button doesn't do anything yet.
        JButton loadPlanBut = new JButton("Load plan");
        buttonPanel.add(loadPlanBut);

        showplanBut = new JButton("Show plan");
        showplanBut.addActionListener(new ActionListener() {
	  public void actionPerformed(ActionEvent e) {
	      planText.setText("");
	      planText.lData = null;
	      if (lc.connected() == true) {
		lc.sendLispCommand("(evaluation::tcl-show-plan)");
		String line;
		while ((line = lc.safeReadLine()).equals("done") == false) {
		    planText.append(line + "\n");
		}
		lc.safeReadLine(); // consume the lisp function return.
	      }
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


        //JLabel critiqueLabel = new JLabel("Critiques");
        //buttonPanel.add(critiqueLabel);

        runBut = new JButton("Check constraints");
        runBut.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent e) {
	      run_critiquer();
	  }
        });
        buttonPanel.add(runBut);

        /*
	JButton showBut = new JButton("Show critique");
        showBut.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent e) {
	      show_critique();
	  }
        });
        buttonPanel.add(showBut); */

        JButton newCritiqueBut = new JButton("Add a new constraint");
        newCritiqueBut.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent e) {
	      //new CritiqueWizard(lc, self);
	      new KATool(lc, self, null);
	  }
        });
        buttonPanel.add(newCritiqueBut);

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
				    
				    KAGrammarTool kagt = new KAGrammarTool(lc, self, top);
	    }
        });
        //buttonPanel.add(newGrammarBut);

        JButton loadBut = new JButton("Load constraints");
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

        JButton saveBut = new JButton("Save constraints");
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

        JButton instanceBut = new JButton("Instance acquirer");
        instanceBut.addActionListener(new ActionListener() {
	  JTextField name;
	  public void actionPerformed(ActionEvent e) {
	      JFrame nameFrame = new JFrame();
	      nameFrame.getContentPane().setLayout(new FlowLayout());
	      name = new JTextField(30);
	      name.setText("planet::book-hotel");
	      nameFrame.getContentPane().add(name);
	      JButton doneBut = new JButton("ok");
	      doneBut.addActionListener(new ActionListener() {
		public void actionPerformed(ActionEvent e) {
		    new InstanceEditor(self.lc, name.getText());
		}});
	      nameFrame.getContentPane().add(doneBut);
	      nameFrame.pack();
	      nameFrame.setVisible(true);
	  }
        });
        buttonPanel.add(instanceBut);

        JButton agendaBut = new JButton("Look at the agenda");
        agendaBut.addActionListener(new ActionListener() {
	  public void actionPerformed(ActionEvent e) {
	      Tree.messagePanel mp = new Tree.messagePanel(new ExpectSocketAPI(lc), null, true);
	      JFrame fm = new JFrame("Agenda");
	      fm.getContentPane().add(mp);
	      fm.pack();
	      fm.setVisible(true);
	  }
        });
        buttonPanel.add(agendaBut);
        */

        JButton quitBut = new JButton("Quit");
        quitBut.addActionListener(new ActionListener() {
	public void actionPerformed(ActionEvent e) {
	  try {lc.close(); } catch (IOException ie) {}
	  System.exit(0);
	}
        });
        buttonPanel.add(quitBut);
        

        getContentPane().add(buttonPanel);

        // The critique panel is on the right and scrolls the
        // critTextArea.
        critText = new ActiveText() {
	public void actionPerformed(MouseEvent e) {
	  ActiveText pt = (ActiveText)e.getComponent();
	  LayedData item = pt.selected;
	  
	  if (item.name != null) {   // clicked on a critique
	    Cursor oldCursor = getCursor();
	    setCursor(Cursor.getPredefinedCursor(Cursor.WAIT_CURSOR));
	    new KATool(lc, self, item.name);
	    setCursor(oldCursor);
	  }
	}
        };
        //JTextArea(5,30);
        critPanel = new JScrollPane(critText);
        critPanel.setPreferredSize(new Dimension(400,400));
        critPanel.setVerticalScrollBarPolicy(JScrollPane.VERTICAL_SCROLLBAR_ALWAYS);
        critPanel.setHorizontalScrollBarPolicy(JScrollPane.HORIZONTAL_SCROLLBAR_ALWAYS);
        getContentPane().add(critPanel);

        pack();
        setVisible(true);

        // Close up the main window nicely
        addWindowListener(new WindowAdapter() {
	  public void windowClosing(WindowEvent e) {
	    try {lc.close(); } catch (IOException ie) {}
	    System.exit(0);
            }
        });
    }

  public void run_critiquer() {
    critText.setText("Running the critiquer...");
    System.out.println("Running the critiquer");
    if (lc.connected() == true) {
      lc.sendLispCommand("(expect::client-run-critiquer :compiled)");
      lc.safeReadLine();
    }
    show_critique();
  }
  
  // Put the output for the critiques in the critText area.
  public void show_critique() {
    if (lc.connected() == true) {
      Style style = critText.normalStyle;
      LayedData cld = null;
      // The commented out lines below display the critique as plain text.
      // The lines in use display it as LayedData so it can be selected.
      critText.setText("");
      critText.lData = new LayedData();
      //critText.append("         Constraints\n\n");
      critText.lData.addChild("         Constraints\n\n");
      lc.sendLispCommand("(evaluation::tcl-write-output)");
      String line;
      while ((line = lc.safeReadLine()).equals("done") == false) {
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
      }
      if (cld != null)
        critText.lData.addChild(cld);
      lc.safeReadLine();
      critText.displayLayedData();
      critText.revalidate();
    }
  }
  
  public static void main(String[] args) {
    PSMTool psmTool = new PSMTool();
  }
}
