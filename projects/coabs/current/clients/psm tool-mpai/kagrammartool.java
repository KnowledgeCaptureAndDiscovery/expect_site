//
// Top-level class to start the main KA window.
//

import javax.swing.*;
import javax.swing.text.*;
import java.awt.*;
import java.awt.event.*;
import javax.swing.border.*;
import javax.accessibility.*;

import java.io.*;
import java.util.*;

import Connection.*;

public class KAGrammarTool extends JFrame {

    private JScrollPane wizardPane = null, treePane = null;
    private JPanel buttonPanel = null, mainPanel = null;
    public LispSocketAPI lc = null;
    public ExpectSocketAPI es = null;
    public PSMTool parent = null;

    private String hostName = "camelot.isi.edu";
    private String port = "5679";

    private KAGrammarTool self = null;
    JPanel right = null; // the panel on the right hand side.
    JSplitPane             splitPane;
    JInternalFrame maker;
    JLayeredPane lp;
  

    CritiqueWizard wizard = null;
    PSTree.psTabbedPanel treePanel = null;
    Tree.messagePanel agendaPanel = null;

    GClass grammar = null;

    // Set this false to allow two separate windows, better for
    // smaller screens or paper screenshots.
    public boolean allOneWindow = false;

    public KAGrammarTool(GClass pgram) {
        super("KA tool");
        //lc = new LispSocketAPI(hostName, port);
        //es = new ExpectSocketAPI(lc);
        buildInitialWindow(pgram);
    }

    public KAGrammarTool(LispSocketAPI passed_lc, PSMTool passed_parent,
			 GClass pgram) {
        super("KA Tool");
        parent = passed_parent;
        lc = passed_lc;
        es = new ExpectSocketAPI(lc);
        buildInitialWindow(pgram);
    }

    public void buildInitialWindow(GClass pgram) {
        self = this;
	grammar = pgram;

        setFont(new Font("SansSerif", Font.PLAIN, 12));
        getContentPane().setLayout(new BoxLayout(getContentPane(), 
						 BoxLayout.Y_AXIS));
        buttonPanel = new JPanel();
        // Leave out the button panel for the paper.
        //getContentPane().add(buttonPanel);
        mainPanel = new JPanel();
        getContentPane().add(mainPanel);
        

        JButton psTreeBut = new JButton("PS Tree");
        psTreeBut.addActionListener(new ActionListener() {
	  public void actionPerformed(ActionEvent e) {
	      //self.updateTree();
	  }
        });
        buttonPanel.add(psTreeBut);

	displayGrammar();

	pack();
	setVisible(true);
    }

    public void displayGrammar() {
	JTextArea qText = new JTextArea(grammar.toString(), 10 , 
					80);
	mainPanel.add(qText);
	pack();
    }

    public static void main(String args[]) {
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
			    
			    top.addClass(feature);
			    top.addClass(critique);
			    critique.addPartition(bound);
			    bound.addPartition(lower);
			    bound.addPartition(upper);
			    
			    KAGrammarTool kagt = new KAGrammarTool(top);
    }
}


