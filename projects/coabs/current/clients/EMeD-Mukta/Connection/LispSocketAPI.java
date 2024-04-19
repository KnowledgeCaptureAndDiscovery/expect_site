// Interface to Expect for PSMTool.
// Author: Jim Blythe (merged with ExpectSocketAPI from Hans and Jihie)

package Connection;

import java.io.*;
import java.net.*;
import java.util.*;
import javax.swing.*;
import java.awt.*;

public class LispSocketAPI {

    static boolean debug = false;

    Socket serverSocket = null;
    PrintWriter outStream = null;
    BufferedReader inStream = null;
    String hostname = "camelot.isi.edu";
    String defaultPort = "8000";
    int port;
    static String[] connectOptionNames = { "Connect" };
    static String connectTitle = "Connect to Expect";

    String defaultPackage = "EXPECT";
    String authData;

    static String beginner = " {", terminator = "}";

    // If started with no args or with string default hostname and
    // string default port, opens the connection dialog and creates the
    // socket.

    public LispSocketAPI() {
        runConnectionDialog(hostname, defaultPort);
        try {
	  openServerConnection(hostname, port);
        } catch (FactoryException e2) {
	  System.err.println("Problem: " + e2.getMessage() + "\n");
        }

    }

    public LispSocketAPI(String defaultHostname, String passedDefaultPort) {
        defaultPort = passedDefaultPort;
        runConnectionDialog(defaultHostname, defaultPort);
        /*
	try {
	serverSocket = new Socket(hostname, port);
	outStream = new PrintWriter(serverSocket.getOutputStream(), true);
	inStream = new BufferedReader(new InputStreamReader(serverSocket.getInputStream()));
	} catch (UnknownHostException e) {
	System.err.println("Don\'t know host " + hostname);
	} catch (IOException e) {
	System.err.println("Couldn\'t get connection to " + hostname + " on port " + port);
	}
        */
        try {
	  openServerConnection(hostname, port);
        } catch (FactoryException e2) {
	  System.err.println("Problem: " + e2.getMessage() + "\n");
        }

    }

    // Allow cloning, to make appropriate subclasses
    public LispSocketAPI(LispSocketAPI src) {
        serverSocket = src.serverSocket;
        outStream = src.outStream;
        inStream = src.inStream;
        
        // These aren't strictly necessary, but might be useful.
        port = src.port;
        hostname = src.hostname;
    }

    void runConnectionDialog(String defaultHostname, String defaultPort) {
        // Create the labels and text fields.
        JLabel machineNameLabel = new JLabel("Machine name: ", JLabel.RIGHT);
        JTextField machineNameField = new JTextField(defaultHostname);
	
        JLabel portNumberLabel = new JLabel("Port number: ", JLabel.RIGHT);
        JTextField portNumberField = new JTextField(defaultPort);
	
        JLabel userNameLabel = new JLabel("User name: ", JLabel.RIGHT);
        JTextField userNameField = new JTextField("demo");
	
        JLabel passwordLabel = new JLabel("Password: ", JLabel.RIGHT);
        JPasswordField passwordField = new JPasswordField("fundme");
	
        JPanel connectionPanel = new JPanel(false);
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
        JOptionPane.showOptionDialog(null, connectionPanel, connectTitle,
			       JOptionPane.DEFAULT_OPTION,
			       JOptionPane.INFORMATION_MESSAGE,
			       null, connectOptionNames,
			       connectOptionNames[0]);
        hostname = machineNameField.getText();
        try {
	  port = Integer.parseInt(portNumberField.getText());
        } catch (NumberFormatException e) {
	  port = -1;
        }
    }

    void openServerConnection(String serverHost, int serverPort) throws FactoryException {
        if (connected())
            return;
        try {
            serverSocket = new Socket(serverHost, serverPort);
            inStream = new BufferedReader
                (new InputStreamReader(serverSocket.getInputStream()));
            outStream = new PrintWriter(serverSocket.getOutputStream(), true);
        }
        catch ( UnknownHostException e ) {
            throw new FactoryException
                ("Unknown Lisp server host",
                 "Unknown Lisp server host `"
                 + serverHost + ":" + serverPort + "'");
	}
        catch ( IOException e ) {
            throw new FactoryException
                ("Lisp server host connection failure",
                 "Can't connect to Lisp server host `"
                 + serverHost + ":" + serverPort + "'");
	}
    }

    // Both these are provided for compatibility with EMeD and PSMTool
    public void closeServerConnection() {
        try { close(); } catch (IOException ioe) {}
    }

    public void close() throws IOException {
        if (serverSocket != null) {
	  outStream.close();
	  inStream.close();
	  serverSocket.close();
        }
    }

    public boolean connected() {
        if (serverSocket != null) 
	  return true;
        else
	  return false;
    }

    public void println(String line) {
        if (serverSocket != null) {
	  outStream.println(line);
        }
    }

    public String readLine() throws IOException {
        if (serverSocket != null)
	  return inStream.readLine();
        else
	  return "";
    }

    public String safeReadLine() {
        try {
	  return readLine();
        } catch (IOException e) {
	  return "";
        }
    }


    //**************************************
    // API for reading strings that parse as XML
    //**************************************

    public void sendLispCommand(String command) {
        //System.out.println("send command:"+command + "eOl");
        if (serverSocket != null)
	  outStream.println(command + "eOl");
        //outStream.println("(:eval " + command + ")");
    }

    StringBuffer delete (StringBuffer in, int i1, int i2) {
        String input = in.toString();
        String current = input.substring(0,i1)+input.substring(i2);
        return new StringBuffer(current);
    }
    StringBuffer deleteCharAt (StringBuffer in, int i1) {
        String input = in.toString();
        String current = input.substring(0,i1)+input.substring(i1+1);
        return new StringBuffer(current);
    }

    public String readLispResult() throws FactoryException {
        StringBuffer result = new StringBuffer();
        String line;
        boolean isError = false;
        boolean firstLine = true, lastLine = false;
        try {
	  line = inStream.readLine();
	  //System.out.println("<< |" + line+"|");
           
	                                    
	  //line = inStream.readLine();
	  //System.out.println("<< " + line+"|");

	  // Jim: This used to throw away the first line. Now it tests
	  // for the starting string and removes it if it's there.
	  if (line.startsWith(beginner))
	      line = line.substring(beginner.length());

	  while (lastLine == false) { // !line.equals(terminator)) { - Jim
	      if (line.equals("")) {
		line = inStream.readLine(); // skip blank lines
		continue;
	      } else if (line.endsWith(terminator)) {  // Jim
		line = line.substring(0, line.length() - terminator.length());
		lastLine = true;
	      }
	      if (!firstLine) 
		result.append("\n");
	      else firstLine = false;
	      result.append(line);
	      //System.out.println("new result:"+result.toString());
	      if (lastLine == false)   // Jim
		line = inStream.readLine();
	      //System.out.println("<< |" + line+"|");
	  }
        }
        catch ( IOException e ) {
	  throw new FactoryException
	      ("Lisp result read error",
	       "Error reading Lisp evaluation result.");
        }
       
        return(result.toString());
        
    }
 

    public String evaluateLispCommand (String command) throws FactoryException {
        return evaluateLispCommand(command, "CL-USER");
    }

    public String evaluateLispCommand (String command, String lispPackage) {
        String result = null;

        if (serverSocket != null) {
	  //System.out.println("Command: " + command);
	  try {
	      //sendLispCommand("(CL:IN-PACKAGE \"" + lispPackage + "\")");
	      //readLispResult();
	      sendLispCommand(command);
	      result = readLispResult();
	  }
	  catch (FactoryException e2) {
	      System.err.println("Error in evaluating command:"+command);
	      System.err.println("Problem: " + e2.getMessage() + "\n");
	  }
        }
        return result;
    }

    //**************************************
    // API for reading structured data: lists and "layedData"
    //**************************************

    // Gets the next chunk of a string, delimited by " or {,}, skipping
    // the delimiters.
    public static String getPiece(String line) {
        int i = 0;

        if (line == null) return null;

        while (i < line.length() && Character.isSpaceChar(line.charAt(i)))
	  i++;

        if (i == line.length()) {
	  return null;
        } else if ("\"{}".indexOf(line.charAt(i)) == -1) {
	  // If there's no list delimiter, read until the next space.
	  if (line.indexOf(" ", i+1) == -1) {
	      return(line.substring(i));
	  } else {
	      return(line.substring(i,line.indexOf(" ", i+1)));
	  } 
        }
        else if ("{".indexOf(line.charAt(i)) == 0) {
	  // The block starts with "{". Read until the corresponding
	  // "}", respecting nesting.
	  int depth = 1, j = i+1;
	  while (j < line.length() && depth > 0) {
	      if ("{".indexOf(line.charAt(j)) == 0) {
		depth++;
	      } else if ("}".indexOf(line.charAt(j)) == 0) {
		depth--;
	      }
	      j++;
	  }
	  return(line.substring(i+1,j-1));
        } else if (line.indexOf("\"", i+1) != -1) {
	  // There's no nesting for "".
	  return (line.substring(i+1,line.indexOf("\"", i+1)));
        } else if (line.indexOf("}", i+1) != -1) {
	  return (line.substring(i+1, line.indexOf("}", i+1)));
        } else {
	  return (line.substring(i+1));
        }
    }

    public Vector readList() {
        // The recursive method doesn't read a list unless the string
        // starts with "{", but the tcl server doesn't automatically add
        // that.
        return readList(safeReadLine());
    }

    public LayedData readLayedData() {
        // The recursive method doesn't read a list unless the string
        // starts with "{", but the tcl server doesn't automatically add
        // that.
        return readLayedData(safeReadLine());
    }

    // returns a LayedData object read by interpreting the next single
    // line as a list, recursively building sublists.  Use this in
    // preference to readList, because other classes can lay this data
    // in textPanes and attach actions to its elements. I want to
    // generalise this to keep reading lines until the list ends. If the
    // line has no brackets, it is returned as the one-element list
    // containing the string. (So that can't be distinguished from the
    // same line with brackets around it).
    public static LayedData readLayedData(String line) {
        LayedData res = new LayedData();
        int i = 0;
        int depth = 1, j = 0, k = 0;
        boolean readingSublist = false, readingElement = false,
	  readingString = false;;
        
        while (j < line.length() && depth > 0) {
	  if (Character.isSpaceChar(line.charAt(j))) {
	      // a space marks the end of a normal element.
	      if (readingElement == true && readingSublist == false
		&& readingString == false) {
		readingElement = false;
		if (j > k) {
		    res.addChild(line.substring(k,j));
		}
	      }
	  } else if (line.charAt(j) == '"' && readingSublist == false) {
	      if (readingElement == false) {
		readingElement = true;
		readingString = true;
		k = j;
	      } else if (readingString == true) {
		readingElement = false;
		readingString = false;
		res.addChild(line.substring(k+1,j));
	      }
	  } else if (line.charAt(j) == '{' && readingString == false) {
	      // Can be the start of a sublist element or just nesting.
	      if (readingElement == false) {
		k = j;
	      }
	      readingSublist = true;
	      readingElement = true;
	      depth++;
	  } else if (line.charAt(j) == '}') {
	      depth--;
	      if (depth == 1 && readingSublist == true) {
		readingSublist = false;
		readingElement = false;
		// just got to the end of a sublist, so make the
		// recursive call to read it.
		if (line.length() > j+1) {
		    res.addChild(readLayedData(line.substring(k+1,j)));
		} else {
		    res.addChild(readLayedData(line.substring(k+1)));
		}
	      } else if (depth == 0) {
		// just reached the end of the list.
		if (readingElement == true) {
		    readingElement = false;
		    res.addChild(line.substring(k,j));
		}
	      }
	  } else if (readingElement == false) {
	      // This is not a space, so start reading from here.
	      readingElement = true;
	      k = j;
	  }
	  j++;
        }
        if (readingElement == true) {
	  // Even if we were reading a sublist, add as a string
	  // because the line ended prematurely.
	  res.addChild(line.substring(k));
        }
        return res;
    }

    // returns an Vector read by interpreting the next single line as
    // a list, recursively building sublists. I want to generalise this
    // to keep reading lines until the list ends. If the line has no
    // brackets, it is returned as the one-element list containing the
    // string. (So that can't be distinguished from the same line with
    // brackets around it).
    public static Vector readList(String line) {
        Vector res = new Vector();
        int i = 0;
        int depth = 1, j = 0, k = 0;
        boolean readingSublist = false, readingElement = false,
	  readingString = false;;
        
        while (j < line.length() && depth > 0) {
	  if (Character.isSpaceChar(line.charAt(j))) {
	      // a space marks the end of a normal element.
	      if (readingElement == true && readingSublist == false
		&& readingString == false) {
		readingElement = false;
		if (j > k) {
		    res.addElement(line.substring(k,j));
		}
	      }
	  } else if (line.charAt(j) == '"' && readingSublist == false) {
	      if (readingElement == false) {
		readingElement = true;
		readingString = true;
		k = j;
	      } else if (readingString == true) {
		readingElement = false;
		readingString = false;
		res.addElement(line.substring(k+1,j));
	      }
	  } else if (line.charAt(j) == '{' && readingString == false) {
	      // Can be the start of a sublist element or just nesting.
	      if (readingElement == false) {
		k = j;
	      }
	      readingSublist = true;
	      readingElement = true;
	      depth++;
	  } else if (line.charAt(j) == '}') {
	      depth--;
	      if (depth == 1 && readingSublist == true) {
		readingSublist = false;
		readingElement = false;
		// just got to the end of a sublist, so make the
		// recursive call to read it.
		if (line.length() > j+1) {
		    res.addElement(readList(line.substring(k+1,j)));
		} else {
		    res.addElement(readList(line.substring(k+1)));
		}
	      } else if (depth == 0) {
		// just reached the end of the list.
		if (readingElement == true) {
		    readingElement = false;
		    res.addElement(line.substring(k,j));
		}
	      }
	  } else if (readingElement == false) {
	      // This is not a space, so start reading from here.
	      readingElement = true;
	      k = j;
	  }
	  j++;
        }
        if (readingElement == true) {
	  // Even if we were reading a sublist, add as a string
	  // because the line ended prematurely.
	  res.addElement(line.substring(k));
        }
        return res;
    }

    public static void main(String[] args) throws IOException {
        
        String userInput;
        BufferedReader stdIn = new BufferedReader(new InputStreamReader(System.in));
        LispSocketAPI lc = new LispSocketAPI("camelot.isi.edu", "5679");

        System.out.println("Ok:");

        lc.println("(print 5)");
        System.out.println("(print 5) -> " + lc.readLine());

        while ((userInput = stdIn.readLine()) != null) {
	  System.out.println("User: " + userInput);
	  lc.println(userInput);
	  System.out.println("Lisp: " + lc.readLine());
        }

        stdIn.close();
        lc.close();
    }
}
