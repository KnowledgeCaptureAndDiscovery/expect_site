/*
 * ServerStatus.java 
 */

package edu.isi.dasher.administrator;

import java.awt.*;
import java.awt.event.*;
import java.io.*;
import java.rmi.*;
import java.text.*;
import java.util.*;

import javax.swing.*;
import javax.swing.event.*;
import javax.swing.table.*;


import edu.isi.dasher.*;
import edu.isi.dasher.directory.*;
import edu.isi.dasher.core.*;
import edu.isi.remotedatatransfer.*;
import edu.isi.remotedatatransfer.server.*;

/**
 * The ServerStatus queries and displays the status of DASHER servers
 *
 * @author Ke-Thia Yao
 * @version 0.1, 6/3/99
 */

public class ServerStatus extends JFrame {
  
  static String propFile;
  static DasherProperties properties;
  static Vector serverNames, serverPrefix;
  static Vector columnNames;

  static Vector rmiServerStatus;
  static Vector clipbookStatus;

  static JTable clipbookTable;
  static JTable rmiServerTable;
  static DefaultTableModel rmiServerTableModel, clipbookTableModel;
  static JLabel dateLabel;

  public ServerStatus() {
    super("DASHER Server Status");

    properties = new DasherProperties();
    propFile = "rmiServers.properties";
    try {
      DasherSystem.clientInit();
    } catch (SettingsException setting) {
      System.err.println("Not able to load system properties: "+setting);
      return;
    }

    try {
      System.out.println("\n\n\n\n\n\nServer Status\n=============");
      properties.load(DasherSystem.propertyFileInputStream(propFile));
    } catch (IOException io) {
      System.err.println("Not able to load "+propFile+" file: "+io);
    } catch (SettingsException setting) {
      System.err.println("Not able to load "+propFile+" file: "+setting);
    }

    serverNames = (Vector)DasherSystem.getProperty("dasher.rmiservers.displayName");
    serverPrefix = (Vector)DasherSystem.getProperty("dasher.rmiservers.prefix");

    columnNames = new Vector();
    columnNames.addElement("Server");
    columnNames.addElement("Host");
    columnNames.addElement("Port");
    columnNames.addElement("Connection");

    rmiServerStatus = new Vector();
    clipbookStatus = new Vector();
    clipbookStatus.addElement(defaultEntry("Initializing..."));
    rmiServerStatus.addElement(defaultEntry("Initializing..."));

    getContentPane().setLayout(new BoxLayout(getContentPane(), BoxLayout.Y_AXIS));

    rmiServerTable = new JTable(new DefaultTableModel(rmiServerStatus,columnNames));
    rmiServerTableModel = (DefaultTableModel) rmiServerTable.getModel();
    rmiServerTable.setRowSelectionAllowed(true);
    rmiServerTable.setSelectionMode(ListSelectionModel.SINGLE_SELECTION);
    rmiServerTable.setColumnSelectionAllowed(false);


    rmiServerTable.setPreferredScrollableViewportSize(new Dimension(500, 100));
    JScrollPane serverScrollPane = new JScrollPane(rmiServerTable);

    clipbookTable = new JTable(new DefaultTableModel(clipbookStatus,columnNames));
    clipbookTableModel = (DefaultTableModel) clipbookTable.getModel();
    clipbookTable.setPreferredScrollableViewportSize(new Dimension(500, 75));
    JScrollPane clipbookScrollPane = new JScrollPane(clipbookTable);

    JPanel buttonPane = new JPanel();
    JButton exitButton = new JButton("Exit");
    exitButton.setToolTipText("Click to exit Server Status");
    exitButton.addActionListener(new ActionListener() {
      public void actionPerformed(ActionEvent e) {
	System.exit(0);
      }});

    JButton refreshButton = new JButton("Refresh");
    refreshButton.setToolTipText("Check the server status again");
    refreshButton.addActionListener(new ActionListener() {
      public void actionPerformed(ActionEvent e) {
	refresh();
      }});
    

    buttonPane.add(refreshButton);
    buttonPane.add(exitButton);

    JLabel label1 = new JLabel("DASHER RMI servers");
    JLabel label2 = new JLabel("Clipbook servers");
    label1.setAlignmentX(CENTER_ALIGNMENT);
    label2.setAlignmentX(CENTER_ALIGNMENT);
    label1.setMinimumSize(new Dimension(500, 25));
    label2.setMinimumSize(new Dimension(500, 25));

    
    dateLabel = 
      new JLabel(DateFormat.getDateTimeInstance(DateFormat.SHORT,DateFormat.MEDIUM).format(new Date()),
		 JLabel.RIGHT);
    dateLabel.setAlignmentX(LEFT_ALIGNMENT);
    dateLabel.setMinimumSize(new Dimension(250, 25));
    dateLabel.setPreferredSize(new Dimension(250, 25));
    dateLabel.setMaximumSize(new Dimension(Integer.MAX_VALUE, 25));

    getContentPane().add(dateLabel);
    getContentPane().add(label1);
    getContentPane().add(serverScrollPane);
    getContentPane().add(Box.createRigidArea(new Dimension(0,5)));
    getContentPane().add(label2);
    getContentPane().add(clipbookScrollPane);
    getContentPane().add(Box.createRigidArea(new Dimension(0,10)));
    getContentPane().add(buttonPane);
    
    pack();
    setVisible(true);


    refresh();
  }

  /**
   * check all servers
   */
  public void refresh() {

    resetModel(rmiServerTableModel);
    checkServers();
    rmiServerTable.updateUI();

    resetModel(clipbookTableModel);
    checkClipbooks();
    clipbookTable.updateUI();

    dateLabel.setText(DateFormat.getDateTimeInstance(DateFormat.SHORT,DateFormat.MEDIUM).format(new Date()));
    System.out.println(rmiServerStatus);
    System.out.println(clipbookStatus);
  }

  /**
   * Check all RMI servers
   */
  public static Vector checkServers() {
    for (int i = 0; i < serverNames.size(); i++) {
      rmiServerTableModel.addRow((checkOneServer((String)serverNames.elementAt(i),
						 (String)serverPrefix.elementAt(i))));
    }
    return rmiServerStatus;
  }

  /**
   * Check one RMI servers
   */
  public static Vector checkOneServer(String displayName, String prefix) {
    Vector status = new Vector();
    String server= (String) DasherSystem.getProperty(prefix+".host");
    Integer port= (Integer) DasherSystem.getProperty(prefix+".port");
    String name= (String) DasherSystem.getProperty(prefix+".name");
    String rmi = "rmi://"+server+":"+port+"/"+name;
    Remote remoteObj;

    status.addElement(displayName);
    status.addElement(server);
    status.addElement(port);
    
    try {
      remoteObj=(Remote)Naming.lookup(rmi);
      System.out.println(displayName+" ("+server+":"+port+") is alive");
      status.addElement("established");
    } catch (Exception e) {
      System.out.println(displayName+" ("+server+":"+port+") connection failed. "+e);
      status.addElement("FAILED");
    } 
    return status;
  }

  /**
   * check all clipbooks
   */
  public static void checkClipbooks() {
    Vector oneStatus;
    com.sun.java.util.collections.Iterator servers;
    try {
      DirectoryServer directory = DasherSystem.getDirectoryServer();
      if (directory == null) {
	clipbookTableModel.addRow(defaultEntry("Directory server down"));
	return;
      }
      com.sun.java.util.collections.Set set = (com.sun.java.util.collections.Set)
	directory.getProperty("ClipboardServers");
      servers = set.iterator();
    } catch (java.rmi.ConnectException e) {
      e.printStackTrace();
      clipbookTableModel.addRow(defaultEntry("Directory server down"));
      return;
    }catch (Exception e) {
      e.printStackTrace();
      clipbookTableModel.addRow(defaultEntry("None found"));
      return;
    }
    if (servers == null) {
      System.out.println("No available clipbook server.");
    } else {
      while (servers.hasNext()) {
	ClipboardServerData svr = (ClipboardServerData)servers.next();
	String displayName = svr.getName();
	String server = svr.getServer();
	int port = svr.getPort();
	String rmi = svr.getRMIURL();
	Remote remoteObj;
	oneStatus = new Vector();
	oneStatus.addElement(displayName);
	oneStatus.addElement(server);
	oneStatus.addElement(new Integer(port));
	try {
	  remoteObj=(Remote)Naming.lookup(rmi);
	  System.out.println("Clipbook: "+displayName+" ("+server+":"+port
			     + ") is alive");
	  oneStatus.addElement("established");
	} catch (Exception e) {
	  System.out.println("Clipbook: "+displayName+" ("+server+":"+port
			     + ") connection failed. "+e);
	  oneStatus.addElement("FAILED");
	}
	clipbookTableModel.addRow(oneStatus);
      }
    }
  }

  public void resetModel(DefaultTableModel model) {
    for (int i = model.getRowCount()-1; i>=0 ; i--) {
      model.removeRow(i);
    }
  }

  public static Vector defaultEntry(String text) {
    Vector status = new Vector();
    status.addElement(text);
    status.addElement("");
    status.addElement("");
    status.addElement("");
    return status;
  }

  public static void main (String args[]) {
    ServerStatus frame = new ServerStatus();
    frame.pack();
    frame.setVisible(true);
  }
}
