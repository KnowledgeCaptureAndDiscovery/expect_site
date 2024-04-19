import com.icl.saxon.*;
import java.util.*;
import java.io.*;
import java.awt.*;
import java.awt.event.*;
import com.sun.java.swing.text.*;
import com.sun.java.swing.tree.*;
import com.sun.java.swing.*;
import org.xml.sax.SAXException;

public class TreeRenderer extends Renderer {

  DefaultMutableTreeNode top = new DefaultMutableTreeNode("Root"); 

    public static void main (String args[])
        throws java.lang.Exception
    {      

      // Check the command-line arguments.
      if (args.length != 1) {
	System.err.println("Usage: java TreeRenderer input-file >output-file");
	System.exit(1);
      } 

	// Instantiate and run the application
      TreeRenderer app = new TreeRenderer();
      app.prepare();
      app.run(new ExtendedInputSource(new File(args[0])));
      app.drawTree();

    }

    public void prepare ()
    {
        setHandler( "NODE", new nodeHandler());
        setHandler( "NAME", new nameHandler());
    }
  
    private class nameHandler extends ElementHandlerBase {

    /**
    * Handle the start of an element 
    */
      public void endElement (ElementInfo e)
      { 
	String att = e.getExtendedAttribute("*");
	e.setExtendedAttribute("NODE", "NAME",att);
      }
    }
    private class nodeHandler extends ElementHandlerBase {

    /**
    * Handle the start of an element 
    */
      public void endElement (ElementInfo e)
      { 
	DefaultMutableTreeNode currentNode = 
	  new DefaultMutableTreeNode(e.getExtendedAttribute("NAME"));
	if (!e.isRoot()) {
	  DefaultMutableTreeNode parentNode = 
	    (DefaultMutableTreeNode) e.getParent().getUserData();
	  parentNode.add(currentNode);
	}

      }
    }
  public void drawTree() {
          JFrame frame = new JFrame("Method Tree");
 
      frame.addWindowListener(new WindowAdapter() {
        public void windowClosing(WindowEvent e) {
                  System.exit(0);
        }
      });
      JTree tree = new JTree(top);
      frame.getContentPane().add("Center", new JScrollPane(tree));
      frame.setSize(400, 300);
      frame.setVisible(true);

  }

}
  
