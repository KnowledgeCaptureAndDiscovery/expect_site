// Attempt at creating an instance editor


//import javax.swing.JTable;
//import javax.swing.table.AbstractTableModel;

import javax.swing.*;
import javax.swing.text.*;
import javax.swing.table.*;
import javax.swing.event.*;
import javax.swing.border.*;

import java.io.*;
import java.util.*;

import java.awt.*;
import java.awt.event.*;

import Connection.*;
//import Editor.*;

public class InstanceEditor extends JPanel {
    public JFrame      frame;
    RoleTablePanel     essRolePanel, nonEssRolePanel;
    Dimension          origin = new Dimension(0, 0);
    String             instanceClass;
    String             shortName;
    JTextField         instanceName;
    boolean            itIsAnInstance;
    JLabel             classEditingLabel;
    JLabel             instanceEditingLabel;
    JPanel             mainPanel;
    JPanel             classnamePanel;
    JPanel             instancenamePanel;
    JPanel             rolesnamePanel;
    JPanel             altPanel;
    JPanel             buttonPanel;
    JScrollPane        tableAggregate;
    ActiveAltText      alternatives;
    JButton            yesButton;
    JButton            quitButton;
    public LispSocketAPI svrCon = null;

    public InstanceEditor(LispSocketAPI theSvrCon, String theInstanceClass, boolean isTopWindow)
	
        throws Connection.FactoryException {
        super();
        
        makeInstanceEditor(theSvrCon, theInstanceClass);
        if (isTopWindow == true)
	  frame.addWindowListener(new WindowAdapter() {
	      public void windowClosing(WindowEvent e) {
		try {svrCon.close(); } catch (IOException ioe) {}
		System.exit(0);
	      }
	  });
    }

    public InstanceEditor(LispSocketAPI theSvrCon, String theInstanceClass) {
	
	super();
	makeInstanceEditor(theSvrCon, theInstanceClass);
    }

    public void makeInstanceEditor(LispSocketAPI theSvrCon, String theInstanceClass) {
	
	svrCon = theSvrCon;
	instanceClass = theInstanceClass;
	
	frame = new JFrame("Instance Editor");
	frame.getContentPane().add(this, BorderLayout.CENTER);
	
	mainPanel = this;

	svrCon.sendLispCommand("(expect::kb-instance-p '" + instanceClass + ")");
	// itIsAnInstance = ! svrCon.safeReadLine().endsWith("NIL");
	String temp = svrCon.safeReadLine();
	System.out.println("Instance Editor"+temp);
	itIsAnInstance = ! temp.endsWith("NIL");
	//System.out.println("itIsAnInstance = " + itIsAnInstance + "   from \"" + temp + "\"");

	setLayout(new BoxLayout(this, BoxLayout.Y_AXIS));
	classnamePanel = new JPanel(new FlowLayout(FlowLayout.LEFT));
	instancenamePanel = new JPanel(new FlowLayout(FlowLayout.LEFT));
	rolesnamePanel = new JPanel(new FlowLayout(FlowLayout.LEFT));
	altPanel = new JPanel();
	buttonPanel = new JPanel(new FlowLayout(FlowLayout.CENTER));
	mainPanel.add(classnamePanel); 
	mainPanel.add(instancenamePanel); 
	mainPanel.add(rolesnamePanel);
	mainPanel.add(altPanel);
	mainPanel.add(buttonPanel); 

	JPanel row1 = new JPanel(); 
	JPanel row2 = new JPanel(); 

	// Get rid of the package name.
	shortName = instanceClass.substring(instanceClass.lastIndexOf(':')+1);
		
	if (itIsAnInstance)
	    {classEditingLabel = new JLabel("Changing information for " + shortName);}
	else
	    {classEditingLabel = new JLabel("Entering information about a new" + shortName);}
	
	classEditingLabel.setForeground(Color.black);
	row1.add(classEditingLabel);

	instanceEditingLabel = new JLabel("Name: ");
	instanceEditingLabel.setHorizontalTextPosition(instanceEditingLabel.RIGHT);
	instanceEditingLabel.setForeground(Color.black);
	instanceName = new JTextField(30);
	if (itIsAnInstance)
	    {instanceName.setText(shortName);}
    
	instanceEditingLabel.setLabelFor(instanceName);

	row2.add(instanceEditingLabel);
	row2.add(instanceName);

	classnamePanel.add(row1);
	instancenamePanel.add(row2);

	essRolePanel = new RoleTablePanel
	    ("expect-find-essential-roles",
	     "This information is needed",
	     svrCon);

	nonEssRolePanel = new RoleTablePanel
	    ("expect-find-nonessential-roles",
	     "This information is optional",
	     svrCon);

	// Make sure the tables are the same height.
	if (essRolePanel.jt != null && nonEssRolePanel.jt != null) {
	    Dimension essDim = 
	        essRolePanel.jt.getPreferredScrollableViewportSize();
	    Dimension nonEssDim = 
	        nonEssRolePanel.jt.getPreferredScrollableViewportSize();
	    if (essDim.height > nonEssDim.height) // works in both java 1 and 2.
	        nonEssDim.setSize(essDim);
	    else
	        essDim.setSize(nonEssDim);
	}
	rolesnamePanel.add(essRolePanel);
	rolesnamePanel.add(nonEssRolePanel);

	if (essRolePanel.jt != null || nonEssRolePanel.jt != null) {
	    alternatives = new ActiveAltText();
	    alternatives.itemSeparator = "   ";
	    JScrollPane altScroll = new JScrollPane(alternatives);
	    if (essRolePanel.jt == null || nonEssRolePanel.jt == null)
	        altScroll.setPreferredSize(new Dimension(500, 60));
	    else
	        altScroll.setPreferredSize(new Dimension(1000, 60));
	    altPanel.add(altScroll);
	}

	yesButton = new JButton("Commit");
	yesButton.addActionListener(new ActionListener() {
	    public void actionPerformed(ActionEvent e) {
	        String fullName;
	        if (instanceName.getText().equals(shortName) == true) {
		  fullName = instanceClass;
	        } else {
		  fullName = instanceName.getText();
	        }
	        svrCon.sendLispCommand("(expect::expect-add-new-instance '" + instanceClass + " '" + fullName + ")");
	        svrCon.safeReadLine();
	        essRolePanel.saveBack();
	        nonEssRolePanel.saveBack();
	        respondToDone();
	        frame.dispose();
	    }
	});
	buttonPanel.add(yesButton);


	quitButton = new JButton("Quit");
	quitButton.addActionListener(new ActionListener() {
	    public void actionPerformed(ActionEvent e) {
	        frame.dispose();
	    }
	});
	buttonPanel.add(quitButton);
	
	frame.pack();
	frame.setVisible(true);
	
    }

    // This method is called when the user hits "commit" and can be
    // overwritten by calling methods.
    public void respondToDone() {
    }

    private class ActiveAltText extends ActiveText {
        JTable jt = null;  // points to the active table.
        int row = 0;
        String concept = "";
        public void actionPerformed(MouseEvent e) {
	  ActiveText pt = (ActiveText)e.getComponent();
	  LayedData item = pt.selected;
	  
	  if (item != null) {
	      // Assuming single-valued for now.
	      if (item.name != null) 
		jt.setValueAt(item.name, row, 1);
	      else {  // this means we're adding a new instance.
		new InstanceEditor(svrCon, concept) {
		    public void respondToDone() {
		        jt.setValueAt(instanceName.getText(), row, 1);
		    }
		};
	      }
	      
	  }
	  
        }
    }

    // a RoleTablePanel is a panel with a label and a JTable containing
    // role information. The saveBack() method stores the edited role
    // info back in the server.
    private class RoleTablePanel extends JPanel {
        public Vector roleNames;
        protected String[][] data;
        protected String[] roleType;
        protected boolean[] singleValued;
        public JTable jt = null;
        LispSocketAPI sc;
        final String[] names = {"Name" , "Value"};

        RoleTablePanel(String command, String label, 
		   LispSocketAPI svrCon) {
	  sc = svrCon;
	  sc.sendLispCommand("(expect::" + command + " '" +  instanceClass + ")");
	  roleNames = (Vector)sc.readList().elementAt(0);
	  //System.out.println("roleNames has " + roleNames.size() + " elements");
	  if (roleNames.size() > 0) {
	      data = new String[roleNames.size()][2];
	      roleType = new String[roleNames.size()];
	      singleValued = new boolean[roleNames.size()];
	      try {
		fillRoleArray();
	        
		RoleTableModel dataModel = new RoleTableModel();
	        
		setLayout(new BoxLayout(this, BoxLayout.Y_AXIS));
		JLabel infoLabel = new JLabel(label);
		infoLabel.setForeground(Color.black);
		add(infoLabel);
		jt = new JTable(dataModel);

		ListSelectionModel lsm = jt.getSelectionModel();
		lsm.addListSelectionListener
		    (new ListSelectionListener() {
		        public void valueChanged(ListSelectionEvent e) {
			  if (e.getValueIsAdjusting())
			      return;
			  ListSelectionModel hsm = 
			      (ListSelectionModel)e.getSource();
			  if (hsm.isSelectionEmpty())
			      return;
			  int selRow = hsm.getMinSelectionIndex();
			  setAlternatives(selRow);
		        }
		    });
	        
		jt.setRowHeight(20);
		JScrollPane scrollPane = new JScrollPane(jt);
		// Make the size match the length (which won't change).
		if ((10 * roleNames.size() + 10) < 500) {
		  jt.setPreferredScrollableViewportSize
		    (new Dimension(400, 10 * roleNames.size() + 10));
		}
		else {
		  jt.setPreferredScrollableViewportSize
		    (new Dimension(400, 500));
		}
		add(scrollPane);
	      } catch (FactoryException fe) {
		System.err.println("Problem talking to the server.");
	      }
	  }
        }

        public void saveBack() {
	  javax.swing.CellEditor currentEditor = null;
	  if (roleNames.size() > 0)
	      currentEditor = jt.getCellEditor();

	  if (currentEditor != null) {
	      // Can use the boolean return value to see if this
	      //  can really stop editing.  If not, an error message
	      //  an no commit action may be more appropriate.
	      currentEditor.stopCellEditing();
	  }
	  String fullName;
	  if (instanceName.getText().equals(shortName) == true) {
	      fullName = instanceClass;
	  } else {
	      fullName = instanceName.getText();
	  }
	  for (int i = 0; i < roleNames.size(); i++) {
	      // For now, only save when it was single-valued, because
	      // we only read the values in that case.
	      if (itIsAnInstance == false || singleValued[i] == true) {
		sc.sendLispCommand("(expect::expect-add-instance-roles '" + fullName + " '" + data[i][0] + " \"" + data[i][1] + "\")");
		sc.safeReadLine();
	      }
	  }
        }
        
        void fillRoleArray ()
	  throws Connection.FactoryException {
	  //System.out.println("Filling role array: data is " + data.length + " x " + data[0].length);
	  //System.out.println("...    roleNames has length " + roleNames.size());
	  for (int i = 0; i < roleNames.size(); i++) {
	      data[i][0] = (String)roleNames.elementAt(i);
	      //System.out.print("data[" + i + "][0] = " + data[i][0] + "      ");
	      data[i][1] = "";      // initial value
	      if (itIsAnInstance) {
		sc.sendLispCommand("(expect::expect-get-role-values '" +
			         roleNames.elementAt(i) + 
			         " '" + instanceClass + ")");
		Object temp = sc.readList().elementAt(0);
		//System.out.println("For " + roleNames.elementAt(i) + ", " + temp);
		if ((temp instanceof Vector) == false) {
		    data[i][1] = (String)temp;
		    singleValued[i] = true;
		} else {
		    if (((Vector)temp).size() > 0) {
		        singleValued[i] = false;
		    } else {
		        singleValued[i] = true; // really, no value.
		    }
		}
	      }
	      sc.sendLispCommand("(expect::retrieve-rel-range '" +
				 roleNames.elementAt(i) + "'(" +
				 instanceClass + "))");
	      roleType[i] = sc.safeReadLine();
	      //System.out.println("data[" + i + "][1] = " + data[i][1]);
	  }
        }

      void setAlternatives(int row) {
        //System.err.println("Setting alts for " + roleNames.elementAt(row)
        //+ ", with range type " + roleType[row]);
        alternatives.setText("");
        alternatives.jt = jt;
        alternatives.row = row;
        alternatives.concept = roleType[row];
        if (roleType[row].equals("NUMBER") == false) {
	sc.sendLispCommand("(expect::kb-get-instances '" + roleType[row]
		         + ")");
	Vector values = (Vector)sc.readList().elementAt(0);
	//System.err.println("The possible values are: " + values);
	LayedData altLD = new LayedData();
	for (int i = 0; i < values.size(); i++) {
	  String instance = (String)values.elementAt(i);
	  LayedData child = altLD.addChild
	    (instance.substring
	     (instance.lastIndexOf(':') + 1));
	  child.name = instance; // store the whole name here.
	}
	altLD.addChild("Add a new " + roleType[row].substring(roleType[row].lastIndexOf(':') + 1));
	alternatives.lData = altLD;
	alternatives.displayLayedData();
        }
      }

        // the table model is declared as an internal class within the
        // RoleTablePanel so it can share data.
        private class RoleTableModel extends AbstractTableModel {

	  public int getColumnCount() { return names.length; }
	  public int getRowCount() { return data.length;}
	  public Object getValueAt(int row, int col) {
	      if (data[row][col] == "")
		return "<" + roleType[row].substring(roleType[row].lastIndexOf(':') + 1) + ">";
	      else
		return data[row][col].substring(data[row][col].lastIndexOf(':') + 1);
	  }
	  public String getColumnName(int column) {return names[column];}
	  public Class getColumnClass(int c) {
	      return getValueAt(0, c).getClass();}
	  public boolean isCellEditable(int row, int col) {
	      return col == 1;
	  }
	  public void setValueAt(Object aValue, int row, int column) { 
	      data[row][column] = (String)aValue; 
	  }
        }
    

    }

    /*public static void main(String[] args) {
        LispSocketAPI mainlc = new LispSocketAPI("camelot.isi.edu", "5950");
        String type;
        if (args.length > 0) {
	  type = args[0];
        } else {
	  type = "ship";
        }
        try{
	  InstanceEditor iE = new InstanceEditor(mainlc, type, true);
        } catch (Connection.FactoryException e) {
	  System.err.println("Error creating instance editor, while evaluating Lisp command:");
	  System.err.println(e.toString());
        }
    }*/
}

