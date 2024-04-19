// This example is from _Java Examples in a Nutshell_. (http://www.oreilly.com)
// Copyright (c) 1997 by David Flanagan
// This example is provided WITHOUT ANY WARRANTY either expressed or implied.
// You may study, use, modify, and distribute it for non-commercial purposes.
// For any commercial use, see http://www.davidflanagan.com/javaexamples

import com.sun.java.swing.*;
import java.awt.*;
import java.awt.event.*;

/** A simple applet that uses the Java 1.1 event handling model */
public class editor extends JPanel
                      implements MouseListener,  MouseMotionListener {
  private int last_x, last_y;
  private JButton b1;
  private JButton b2;
  private JButton b3;
  private JButton b4;
  private JButton buttons[];			
  public editor () {

// Tell this applet what MouseListener and MouseMotionListener
    // objects to notify when mouse and mouse motion events occur.
    // Since we implement the interfaces ourself, our own methods are called.

    //this.addMouseListener(this);
    //this.addMouseMotionListener(this);
    b1 = new JButton("find");
    b1.setName("i1");
    //b1.addActionListener(new b1Listener());
    b1.addMouseListener(this);
    add (b1);
    b2 = new JButton(" ");
    b2.setName("i2");
    b2.addMouseListener(this);
    //b2.addActionListener(new b2Listener());
    add (b2);

    b3 = new JButton("length");
    b3.addMouseListener(this);
    b3.setName("i3");
    add (b3);
    b4 = new JButton(" of object");
    b4.addMouseListener(this);
    b4.setName("i4");
    add (b4);
  }

  // A method from the MouseListener interface.  Invoked when the
  // user presses a mouse button.
  public void mousePressed(MouseEvent e) {
    last_x = e.getX();
    last_y = e.getY();
    System.out.println("Mouse Down(" + e.getX() + "," + e.getY() + ")");
  }

  // A method from the MouseMotionListener interface.  Invoked when the
  // user drags the mouse with a button pressed.
  public void mouseDragged(MouseEvent e) {;  }

  // The other, unused methods of the MouseListener interface.
  public void mouseReleased(MouseEvent e) {;}
  public void mouseClicked(MouseEvent e) {         
    System.out.println("Mouse Clicked(" + e.getX() + "," + e.getY() + ")");
  }
  public void mouseEntered(MouseEvent e) {
    System.out.println("Mouse Enter(" + e.getX() + "," + e.getY() + ")");
    Component c = e.getComponent();
    System.out.println("Selected component: "+c.getName());
  }
  public void mouseExited(MouseEvent e) {;}

  // The other method of the MouseMotionListener interface.
  public void mouseMoved(MouseEvent e) {;}
			
  public void mapSelections (String id) {
    if (id.equals ("i2")) {
      highlight ("i3");
      highlight ("i4");
    }
    else highlight(id);
  }

  public void highlight (String id) {
  }

  public static void main(String[] args) {
    JFrame frame = new JFrame("Expect Editor");
 
      frame.addWindowListener(new WindowAdapter() {
        public void windowClosing(WindowEvent e) {
                  System.exit(0);
        }
      });
      
      frame.getContentPane().add("Center", new editor());
      frame.setLocation(50,50);
      frame.setSize(200, 500); // demo mode
      frame.setVisible(true);
    }
 

}
