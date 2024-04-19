// EXPECT Backend

// Author: Jihie Kim

package Connection;
import javax.swing.*;
import java.awt.*;
import java.io.*;
import java.net.*;

public abstract class ExpectConnect {
  static boolean debug = false;
  static String defaultMachine="camelot.isi.edu";
  static String defaultPort="5000";

  static String[] ConnectOptionNames = { "Connect" };
  static String   ConnectTitle = "Connect EXPECT";
  static JPanel      connectionPanel;

  static JLabel      machineNameLabel; 
  static JTextField  machineNameField; 
  static JLabel      portNumberLabel; 
  static JTextField  portNumberField; 

  static JLabel      userNameLabel; 
  static JTextField  userNameField; 
  static JLabel      passwordLabel; 
  static JPasswordField  passwordField; 
  String userName;
  static void activateConnectionDialog() {
    PrintStream out = System.out;

    if (JOptionPane.showOptionDialog(null, connectionPanel, ConnectTitle,
		   JOptionPane.DEFAULT_OPTION, JOptionPane.INFORMATION_MESSAGE,
		   null, ConnectOptionNames, ConnectOptionNames[0]) == 0) {
      if (debug) out.println("option Dialog ok.");
    }
    else { if (debug) out.println("error in option Dialog.");
    }
     
  }

  static void createConnectionDialog() {
    // Create the labels and text fields.
    machineNameLabel = new JLabel("Machine name: ", JLabel.RIGHT);
    machineNameField = new JTextField(defaultMachine);
	
    portNumberLabel = new JLabel("Port number: ", JLabel.RIGHT);
    portNumberField = new JTextField(defaultPort);
	
    userNameLabel = new JLabel("User name: ", JLabel.RIGHT);
    userNameField = new JTextField("demo");
	
    passwordLabel = new JLabel("Password: ", JLabel.RIGHT);
    passwordField = new JPasswordField("fundme");
	
    connectionPanel = new JPanel(false);
    connectionPanel.setLayout(new BoxLayout(connectionPanel,
					    BoxLayout.X_AXIS));

    JPanel namePanel = new JPanel(false);
    namePanel.setLayout(new GridLayout(0, 1));
    namePanel.add(machineNameLabel);
    namePanel.add(portNumberLabel);
    namePanel.add(userNameLabel); 
    namePanel.add(passwordLabel);


    JPanel fieldPanel = new JPanel(false);
    fieldPanel.setLayout(new GridLayout(0, 1));
    fieldPanel.add(machineNameField);
    fieldPanel.add(portNumberField);
    fieldPanel.add(userNameField); 
    fieldPanel.add(passwordField);

    connectionPanel.add(namePanel);
    connectionPanel.add(fieldPanel);
  }

  public ExpectConnect () {}
}
