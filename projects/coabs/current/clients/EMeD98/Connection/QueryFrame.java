/*  
 * QueryFrame.java  7/14/98
 */
 
/*
 * Main program for client: 
 * @author Jihie Kim
 */
package Connection;

import com.sun.java.swing.*;
import java.awt.*;
import java.awt.event.*;
import java.awt.Dimension;
import java.io.*;

public class QueryFrame extends JPanel implements LayoutManager {
    Dimension   origin = new Dimension(0, 0); 

    JTable table;
    String query;
    JComboBox  component; // DB Table name
    JPanel compPane;
    JPanel paramPane;
    Object[][] data;
  JLabel      compNameLabel;
  JTextField  compNameField;
    JButton selectButton;
    JButton closeButton;

  JComponent  queryAggregate;
  JTextArea   queryTextArea;

  static ExpectServer server;

    public QueryFrame() {
        table = new JTable();
	table.setAutoCreateColumnsFromModel(false);

	

	compPane = new JPanel();      
	compPane.setBorder(BorderFactory.createTitledBorder("Select Component"));
	component = new JComboBox();
	component.addItem("Get Method");
	component.addItem("Get Concept");
	component.addItem("Get Instance");
	component.addItem("Get Relation");
	component.addItem("Get PS node");
	component.addItem("Get EXE node");
	component.addItem("Get Agenda Item");
	component.addItem("Get Concept Tree");
	component.addItem("Get Relation Tree");
	component.addItem("Get PS Tree");
	component.addItem("Get EXE Tree");
	component.addItem("Get Goal Tree");
	component.addItem("Get Agenda Tree");

	compPane.add(component);

	compNameLabel = new JLabel(" name: ", JLabel.RIGHT);
 	compNameField = new JTextField("thing",15);

	compPane.add (compNameLabel);
	compPane.add (compNameField);

	selectButton = new JButton("Select");
	selectButton.addActionListener(new SelectListener()); 
	compPane.add(selectButton);

	closeButton = new JButton("Close");
	closeButton.addActionListener(new CloseListener()); 
	add(closeButton);

	queryTextArea = new JTextArea(" resulting XML string", 35, 25);
	queryTextArea.setLineWrap(true);
	queryAggregate = new JScrollPane(queryTextArea);
	//queryAggregate.setBorder(new BevelBorder(BevelBorder.LOWERED));

	paramPane = new JPanel(); 
	paramPane.setBorder(BorderFactory.createTitledBorder("Results"));
	//paramPane.setLayout(new GridLayout(0, 1));
	paramPane.setLayout(new BorderLayout());
	paramPane.add(queryAggregate);

	add(compPane);
        add(paramPane);

	setLayout(this); 
    }

    class SelectListener implements ActionListener {
	public void actionPerformed(ActionEvent e) {            
            select(); 
	}
    }
    public void select() {
      	setSearchPara();
	//table.setValueAtDataVector(data,null);
    }

    class CloseListener implements ActionListener {
	public void actionPerformed(ActionEvent e) {            
            try { 
	      close(); 
	    }
	    catch (Throwable ex) {
	      ex.printStackTrace();
	    }
	}
    }
    public void close()  throws Throwable {
      	super.finalize(); 
	System.exit(0);
    }


  public void setSearchPara() {
    String result="";
    String name = (String) component.getSelectedItem();
    if (name.equals("Get Concept")) 
      result = server.getConceptInfo(compNameField.getText());
    else if (name.equals("Get Method")) 
      result = server.getMethodInfo(compNameField.getText());
    else if (name.equals("Get Relation")) 
      result = server.getRelationInfo(compNameField.getText());
    queryTextArea.cut();
    queryTextArea.setText(result);
    
  }

  public Dimension preferredLayoutSize(Container c){return origin;}
    public Dimension minimumLayoutSize(Container c){return origin;}
    public void addLayoutComponent(String s, Component c) {}
    public void removeLayoutComponent(Component c) {}
    public void layoutContainer(Container c) {
        Rectangle b = c.getBounds(); 
        int inset = 4; 

	compPane.setBounds(inset,inset,b.width-2*inset,90);
	paramPane.setBounds(inset,inset+95,b.width-2*inset,145);
	closeButton.setBounds(b.width-2*inset-120, inset+240, 80, 25);

    }

    public static void main(String[] args) {
      PrintStream o = System.err;
      server = new ExpectServer();

      JFrame frame = new JFrame("AttrFrame");

      frame.addWindowListener(new WindowAdapter() {
	public void windowClosing(WindowEvent e) {
		  System.exit(0);
	}
      });
      
      frame.getContentPane().add("Center", new QueryFrame());
      frame.setSize(400, 300);
      frame.setVisible(true);
    }
}
