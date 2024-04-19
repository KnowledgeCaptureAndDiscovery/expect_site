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

public class KATool extends JFrame {

    private JScrollPane wizardPane = null, treePane = null;
    private JPanel buttonPanel = null;
    public LispSocketAPI lc = null;
    public ExpectSocketAPI es = null;
    public PSMTool parent = null;

    private String hostName = "camelot.isi.edu";
    private String port = "5679";

    private KATool self = null;
    JPanel right = null; // the panel on the right hand side.
  JSplitPane             splitPane;
  JInternalFrame maker;
  JLayeredPane lp;
  

    CritiqueWizard wizard = null;
    PSTree.psTabbedPanel treePanel = null;
    Tree.messagePanel agendaPanel = null;

    // Set this false to allow two separate windows, better for
    // smaller screens or paper screenshots.
    public boolean allOneWindow = false;

    public KATool() {
        super("Acquisition Wizard");
        lc = new LispSocketAPI(hostName, port);
        es = new ExpectSocketAPI(lc);
        buildInitialWindow();
    }

    public KATool(LispSocketAPI passed_lc, PSMTool passed_parent) {
        super("Acquisition Wizard");
        parent = passed_parent;
        lc = passed_lc;
        es = new ExpectSocketAPI(lc);
        buildInitialWindow();
    }

    public void buildInitialWindow() {
        self = this;
        setFont(new Font("SansSerif", Font.PLAIN, 12));
        getContentPane().setLayout(new BoxLayout(getContentPane(), 
				         BoxLayout.Y_AXIS));
        buttonPanel = new JPanel();
        // Leave out the button panel for the paper.
        //getContentPane().add(buttonPanel);
        JPanel mainPanel = new JPanel();
        getContentPane().add(mainPanel);
        

        JButton psTreeBut = new JButton("PS Tree");
        psTreeBut.addActionListener(new ActionListener() {
	  public void actionPerformed(ActionEvent e) {
	      self.updateTree();
	  }
        });
        buttonPanel.add(psTreeBut);

        /*JButton methodsBut = new JButton("Show all methods");
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
	      self.updateAgenda();
	  }
        });
        buttonPanel.add(agendaBut);

        JButton quitBut = new JButton("quit");
        quitBut.addActionListener(new ActionListener() {
	  public void actionPerformed(ActionEvent e) {
	      self.dispose();
	  }
        });
        buttonPanel.add(quitBut);

        // Create the wizard panel.
        wizard = new CritiqueWizard(lc, this);
        wizard.setPreferredSize(new Dimension(650,600));
        JScrollPane cwScrollPane = new JScrollPane(wizard);
        cwScrollPane.setVerticalScrollBarPolicy(JScrollPane.VERTICAL_SCROLLBAR_ALWAYS);
        cwScrollPane.setHorizontalScrollBarPolicy(JScrollPane.HORIZONTAL_SCROLLBAR_NEVER);
        cwScrollPane.setPreferredSize(new Dimension(650,600));
        mainPanel.add(cwScrollPane);

        // Create the right hand panel, for tree and agenda.
        right = new JPanel();
        right.setLayout(new BoxLayout(right, BoxLayout.Y_AXIS));
        right.setPreferredSize(new Dimension(600,600));
        right.setMaximumSize(new Dimension(600,2000)); 
	/*
	splitPane = new JSplitPane(JSplitPane.VERTICAL_SPLIT, treePanel,
				   agendaPanel);
	splitPane.setContinuousLayout(true);
	splitPane.setPreferredSize(new Dimension(600,600));
        splitPane.setMaximumSize(new Dimension(600,2000)); */
	lp = new JDesktopPane();
	lp.setOpaque(false);
	
	
        if (allOneWindow == true) {
	  //mainPanel.add(right);
	  mainPanel.add(lp);
	  //mainPanel.add(splitPane);
        } else {
	  JFrame secondWindow = new JFrame("Interdependency Analyzer");
	  secondWindow.getContentPane().add(lp);
	  secondWindow.setSize(612,632);
	  //secondWindow.getContentPane().add(right);
	  //secondWindow.pack();
	  secondWindow.setVisible(true);
        }

        pack();
        setVisible(true);
    }

    // Updating components
  /*
    public void updateTree() {
        if (treePanel == null) {
	  treePanel = new PSTree.psTabbedPanel(es, null, wizard, true);
	  right.add(treePanel, BorderLayout.NORTH);
	  right.revalidate();
        } else {
	  treePanel.reloadPSTabs();
        }
    }

    public void updateAgenda() {
        if (agendaPanel == null) {
	  agendaPanel = new Tree.messagePanel(es, wizard, true);
	  right.add(agendaPanel, BorderLayout.NORTH);
	  right.revalidate();
        } else {
	  agendaPanel.refresh();
        }
    }*/
   public JInternalFrame createMakerFrame(JPanel panel, String title) {
    JInternalFrame w;
    JPanel tp;
    Container contentPane;

    w = new JInternalFrame(title);
    contentPane = w.getContentPane();
    //contentPane.setLayout(new GridLayout(0, 1));

    tp = panel;
    contentPane.add(tp);
    w.setResizable(true);            
    w.setMaximizable(true);
    w.setIconifiable(true);

    return w;
  }
 
    public void updateTree() {
        if (treePanel == null) {
	  treePanel = new PSTree.psTabbedPanel(es, null, wizard, true);
	  maker = createMakerFrame(treePanel, "Interdependency");
	  maker.setBounds (0,0, 600, 400);
	  lp.add(maker, JLayeredPane.PALETTE_LAYER);  
	  lp.updateUI();
        } else {
	  treePanel.reloadPSTabs();
        }
    }

    public void updateAgenda() {
        if (agendaPanel == null) {
	  agendaPanel = new Tree.messagePanel(es, null, true);
	  maker = createMakerFrame(agendaPanel, "Warnings");
	  maker.setBounds (0,400, 600, 200);
	  lp.add(maker, JLayeredPane.PALETTE_LAYER);  
	  lp.updateUI();
        } else {
	  agendaPanel.refresh();
        }
    }
    
    public static void main(String[] args) {
        new KATool();
    }
}
