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
    JTable             essTableView;
    JTable             nonEssTableView;
    JScrollPane        essScrollPane;
    JScrollPane        nonEssScrollPane;
    Dimension          origin = new Dimension(0, 0);
    String             instanceClass;
    JTextField         instanceName;
    boolean            itIsAnInstance;
    JLabel             classEditingLabel;
    JLabel             instanceEditingLabel;
    JLabel             essInfoLabel;
    JLabel             nonEssInfoLabel;
    JPanel             mainPanel;
    JPanel             classnamePanel;
    JPanel             instancenamePanel;
    JPanel             rolesnamePanel;
    JPanel             buttonPanel;
    JScrollPane        tableAggregate;
    JButton            yesButton;
    JButton            quitButton;
    public LispSocketAPI svrCon = null;
    Vector             essRoleNames;
    Vector             nonEssRoleNames;

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

    public InstanceEditor(LispSocketAPI theSvrCon, String theInstanceClass)
	
	throws Connection.FactoryException {
	super();
	makeInstanceEditor(theSvrCon, theInstanceClass);
    }

    public void makeInstanceEditor(LispSocketAPI theSvrCon, String theInstanceClass)
	
	throws Connection.FactoryException {
	svrCon = theSvrCon;
	instanceClass = theInstanceClass;
	
	frame = new JFrame("Instance Acquirer");
	frame.getContentPane().add(this, BorderLayout.CENTER);
	
	mainPanel = this;

	svrCon.sendLispCommand("(expect::kb-instance-p '" + instanceClass + ")");
	// itIsAnInstance = ! svrCon.safeReadLine().endsWith("NIL");
	String temp = svrCon.safeReadLine();
	itIsAnInstance = ! temp.endsWith("NIL");
	//System.out.println("itIsAnInstance = " + itIsAnInstance + "   from \"" + temp + "\"");

	setLayout(new BoxLayout(this, BoxLayout.Y_AXIS));
	classnamePanel = new JPanel(new FlowLayout(FlowLayout.LEFT));
	instancenamePanel = new JPanel(new FlowLayout(FlowLayout.LEFT));
	rolesnamePanel = new JPanel(new FlowLayout(FlowLayout.LEFT));
	buttonPanel = new JPanel(new FlowLayout(FlowLayout.CENTER));
	mainPanel.add(classnamePanel); 
	mainPanel.add(instancenamePanel); 
	mainPanel.add(rolesnamePanel);
	mainPanel.add(buttonPanel); 

	JPanel row1 = new JPanel(); 
	JPanel row2 = new JPanel(); 
		
	if (itIsAnInstance)
	    {classEditingLabel = new JLabel("Changing information for " + instanceClass);}
	else
	    {classEditingLabel = new JLabel("Entering information on instance belonging to class: " + instanceClass);}
	
	
	row1.add(classEditingLabel);

	instanceEditingLabel = new JLabel("Instance name: ");
	instanceEditingLabel.setHorizontalTextPosition(instanceEditingLabel.RIGHT);
	instanceName = new JTextField(30);
	if (itIsAnInstance)
	    {instanceName.setText(instanceClass);}
    
	instanceEditingLabel.setLabelFor(instanceName);

	row2.add(instanceEditingLabel);
	row2.add(instanceName);

	classnamePanel.add(row1);
	instancenamePanel.add(row2);

	svrCon.sendLispCommand("(expect::expect-find-essential-roles '" +  instanceClass + ")");
	essRoleNames = (Vector)svrCon.readList().elementAt(0);
	System.out.println("essRoleNames has " + essRoleNames.size() + " elements");
	final String[] names = {"Role Name" , "Role Value"};
	int essRoleRows;
	if (essRoleNames.size() == 0)
	    essRoleRows = 1;
	else
	    essRoleRows = essRoleNames.size();
	final Object[][] essData = new Object[essRoleRows] [2];
	if (essRoleNames.size() > 0) {
	    fillRoleArray(theSvrCon, essData, essRoleNames, instanceClass, itIsAnInstance);
	    
	    TableModel essDataModel = new AbstractTableModel() {
	        public int getColumnCount() { return names.length; }
	        public int getRowCount() { return essData.length;}
	        public Object getValueAt(int row, int col) {return essData[row][col];}
	        public String getColumnName(int column) {return names[column];}
	        public Class getColumnClass(int c) {return getValueAt(0, c).getClass();}
	        //		public boolean isCellEditable(int row, int col) {return getColumnClass(col) == String.class;}
	        public boolean isCellEditable(int row, int col) {return col == 1;}
	        public void setValueAt(Object aValue, int row, int column) { essData[row][column] = aValue; }};
	    
	    
	    
	    // Create the table
	    
	    //TableSorter EssSorter = new TableSorter(essDataModel); 
	    //JTable essTableView = new JTable(EssSorter);
	    //essSorter.addMouseListenerToHeaderInTable(essTableView); 
	    
	    JPanel essPanel = new JPanel();
	    essPanel.setLayout(new BoxLayout(essPanel, BoxLayout.Y_AXIS));
	    essInfoLabel = new JLabel("These roles are needed by the problem solver");
	    essPanel.add(essInfoLabel);
	    essTableView = new JTable(essDataModel);
	    
	    essTableView.setRowHeight(essRoleNames.size());
	    
	    essScrollPane = new JScrollPane(essTableView);
	    essPanel.add(essScrollPane);
	    rolesnamePanel.add(essPanel);
	}

///////////////////////////////////////////


	svrCon.sendLispCommand("(expect::expect-find-nonessential-roles '" +  instanceClass + ")");
	nonEssRoleNames = (Vector)svrCon.readList().elementAt(0);
	// This is a hack because the declaration of nonEssData needs
	// to be at this level. Jim.
	int nonEssDataRows;
	if (nonEssRoleNames.size() > 0)
	    nonEssDataRows = nonEssRoleNames.size();
	else
	    nonEssDataRows = 1;
	final Object[][] nonEssData = new Object[nonEssDataRows] [2];
	if (nonEssRoleNames.size() > 0) {
	    fillRoleArray(theSvrCon, nonEssData, nonEssRoleNames, instanceClass, itIsAnInstance);
	    
	    TableModel nonEssDataModel = new AbstractTableModel() {
	        public int getColumnCount() { return names.length; }
	        public int getRowCount() { return nonEssData.length;}
	        public Object getValueAt(int row, int col) {return nonEssData[row][col];}
	        public String getColumnName(int column) {return names[column];}
	        public Class getColumnClass(int c) {return getValueAt(0, c).getClass();}
	        //		public boolean isCellEditable(int row, int col) {return getColumnClass(col) == String.class;}
	        public boolean isCellEditable(int row, int col) {return col == 1;}
	        public void setValueAt(Object aValue, int row, int column) { nonEssData[row][column] = aValue; }};
	    
	    
	    
	    // Create the table
	    
	    //TableSorter nonEssSorter = new TableSorter(nonEssDataModel); 
	    //JTable nonEssTableView = new JTable(nonEssSorter);
	    //nonEssSorter.addMouseListenerToHeaderInTable(nonEssTableView); 
	    
	    nonEssTableView = new JTable(nonEssDataModel);
	    
	    nonEssTableView.setRowHeight(nonEssRoleNames.size());
	    
	    nonEssScrollPane = new JScrollPane(nonEssTableView);
	    rolesnamePanel.add(nonEssScrollPane);
	}

///////////////////////////////////////////


	yesButton = new JButton("Commit");
	yesButton.addActionListener(new ActionListener() {
	    public void actionPerformed(ActionEvent e) {
	        javax.swing.CellEditor essCurrentEditor = null;
	        javax.swing.CellEditor nonEssCurrentEditor = null;
	        if (essRoleNames.size() > 0)
		  essCurrentEditor = essTableView.getCellEditor();
	        if (nonEssRoleNames.size() > 0) 
		  {nonEssCurrentEditor = nonEssTableView.getCellEditor();}
	        
	        if (essCurrentEditor != null) {
		  // Can use the boolean return value to see if this
		  //  can really stop editing.  If not, an error message
		  //  an no commit action may be more appropriate.
		  essCurrentEditor.stopCellEditing();
	        }
	        if (nonEssRoleNames.size() > 0) {
		  if (nonEssCurrentEditor != null) {
		      nonEssCurrentEditor.stopCellEditing();
		  }
	        }
	        svrCon.sendLispCommand("(expect::expect-add-new-instance '" + instanceClass + " '" + instanceName.getText() + ")");
	        svrCon.safeReadLine();
	        for (int i = 0; i < essRoleNames.size(); i++) {
		  svrCon.sendLispCommand("(expect::expect-add-instance-roles '" + instanceName.getText() + " '" + essData[i][0] + " \"" + essData[i][1] + "\")");
		  svrCon.safeReadLine();
	        }
	        for (int i = 0; i < nonEssRoleNames.size(); i++) {
		  svrCon.sendLispCommand("(expect::expect-add-instance-roles '" + instanceName.getText() + " '" + nonEssData[i][0] + " \"" + nonEssData[i][1] + "\")");
		  svrCon.safeReadLine();
	        }
	    }
	});
	buttonPanel.add(yesButton);



////////////////////////////////////


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

    private class IETableModel extends AbstractTableModel {
        public Object[][] dataArray;
        final String[] names = {"Role Name" , "Role Value"};

        IETableModel(Object[][] theArray) {
	  dataArray = theArray;
        }

        public int getColumnCount() { return names.length; }
        public int getRowCount() { return dataArray.length;}
        public Object getValueAt(int row, int col) {
	  return dataArray[row][col];
        }
        public String getColumnName(int column) {return names[column];}
        public Class getColumnClass(int c) {
	  return getValueAt(0, c).getClass();}
        public boolean isCellEditable(int row, int col) {
	  return col == 1;
        }
        public void setValueAt(Object aValue, int row, int column) { 
	  dataArray[row][column] = aValue; 
        }
    }
    
    static void fillRoleArray (LispSocketAPI svrCon, Object[][] data, Vector roleNames, String instanceClass, boolean itIsAnInstance)
        throws Connection.FactoryException {
        //System.out.println("Filling role array: data is " + data.length + " x " + data[0].length);
        //System.out.println("...    roleNames has length " + roleNames.size());
        for (int i = 0; i < roleNames.size(); i++) {
	  data[i][0] = roleNames.elementAt(i);
	  System.out.print("data[" + i + "][0] = " + data[i][0] + "      ");
	  if (itIsAnInstance) {
	      svrCon.sendLispCommand("(expect::expect-get-role-values '" +
			         roleNames.elementAt(i) + 
			         " '" + instanceClass + ")");
	      Object temp = svrCon.readList().elementAt(0);
	      if (temp instanceof Vector) {data[i][1] = "";} else {data[i][1] = temp;}
	  } else {
	      data[i][1] = "";
	  }
	  //System.out.println("data[" + i + "][1] = " + data[i][1]);
        }
    }

    public static void main(String[] args) {
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
    }
}





