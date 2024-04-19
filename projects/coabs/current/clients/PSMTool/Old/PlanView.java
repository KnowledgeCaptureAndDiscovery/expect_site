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
  public ActiveText planText = null;
  public PlanView self = null;

  public PlanView(LispSocketAPI plc) {

    lc = plc;
    self = this;

    setLayout(new BorderLayout());
    setBorder(BorderFactory.createTitledBorder(BorderFactory.createLoweredBevelBorder(),
				       "Plan View"));

    // button panel along the top
    JPanel buttonPanel = new JPanel();
    JButton loadPlanBut = new JButton("Load plan");
    loadPlanBut.addActionListener(new ActionListener() {
      public void actionPerformed(ActionEvent e) {
        JFileChooser chooser = new JFileChooser(); // Note: source for ExtensionFileFilter can be found in the SwingSet demo
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

    JButton quitBut = new JButton("Quit");
    quitBut.addActionListener(new ActionListener() {
      public void actionPerformed(ActionEvent e) {
        try {lc.close(); } catch (IOException ie) {}
        System.exit(0);
      }
    });
    buttonPanel.add(quitBut);


    add(buttonPanel, BorderLayout.NORTH);


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
    add(planPanel, BorderLayout.CENTER);

    // Show any plan information there is on startup
    showPlan();
  }

  public void showPlan() {
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

  public static void main(String[] args) {
    JFrame p = new JFrame();
    p.getContentPane().add(new PlanView(new LispSocketAPI("localhost", "5679")));
    p.pack();
    p.setVisible(true);
  }

}
