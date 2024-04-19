import com.icl.saxon.*;

import java.net.URL;
import java.io.*;
 
import java.awt.*;
import java.awt.event.*;
import java.util.*;
import com.sun.java.swing.text.*;
import com.sun.java.swing.tree.*;
import com.sun.java.swing.*;

public class TreeGenerator extends Renderer {

  DefaultMutableTreeNode top;
  //  DefaultMutableTreeNode currentNode;
  //  DefaultMutableTreeNode parentNode;

    public static void main (String args[])
        throws java.lang.Exception
    {      

      // Check the command-line arguments.
      if (args.length != 1) {
	System.err.println("Usage: java TreeGenerator input-file >output-file");
	System.exit(1);
      } 

	// Instantiate and run the application
      TreeGenerator app = new TreeGenerator();
      app.prepare();
      app.run(new ExtendedInputSource(new File(args[0])));
      app.drawTree();

    }

    public TreeGenerator () 
    {
      top = new DefaultMutableTreeNode("Root");

    }

    private void prepare ()
    {
        setHandler( "NODE", new nodeHandler());
    }
  
    private class nodeHandler extends ElementHandlerBase {

    /**
    * Handle the start of an element 
    */
      public void startElement (ElementInfo e)
      { 
	DefaultMutableTreeNode currentNode = 
	  new DefaultMutableTreeNode(e.getAttribute("*"));
	if (!e.isRoot()) {
	  DefaultMutableTreeNode parentNode = 
	    (DefaultMutableTreeNode) e.getParent().getUserData();
	  parentNode.add(currentNode);
	}

      }
    }

  public class TreePanel extends JPanel {
    public TreePanel() {
      JTree tree = new JTree (top);
      add(new JScrollPane(tree), BorderLayout.CENTER);
    }
  }

  private void drawTree () {
    JFrame frame = new JFrame(" XML to Tree");
    frame.addWindowListener(new WindowAdapter() {
      public void windowClosing(WindowEvent e) {
	System.exit(0);
      }

    frame.getContentPane.add("Center", new TreePanel());
    frame.setSize(400, 300);
    frame.setVisible(true);
  }
}
  
