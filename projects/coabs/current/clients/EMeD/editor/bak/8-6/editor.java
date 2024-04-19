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
  public static final String HIGHLIGHT = "highlight";
  public static final String RESET = "reset";

  private int last_x, last_y;
  private JButton b1;
  private JButton b2;
  private JButton b3;
  private JButton b4;
  private JButton buttons[] = new JButton[100];			
  public editor () {

// Tell this applet what MouseListener and MouseMotionListener
    // objects to notify when mouse and mouse motion events occur.
    // Since we implement the interfaces ourself, our own methods are called.


    buttons[1] = new JButton("find");
    buttons[1].setName("1");
    buttons[1].addMouseListener(this);
    add (buttons[1]);
    buttons[2] = new JButton();
    buttons[2].setName("2");
    buttons[2].addMouseListener(this);
    add (buttons[2]);

    buttons[3] = new JButton("length");
    buttons[3].addMouseListener(this);
    buttons[3].setName("3");
    add (buttons[3]);
    buttons[4] = new JButton(" of object");
    buttons[4].addMouseListener(this);
    buttons[4].setName("4");
    add (buttons[4]);
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
    //System.out.println("Mouse Enter(" + e.getX() + "," + e.getY() + ")");
    Component c = e.getComponent();
    System.out.println("Selected component: "+c.getName());
    mapSelections(c.getName(),HIGHLIGHT);
  }
  public void mouseExited(MouseEvent e) {
    mapSelections(e.getComponent().getName(),RESET);
    
  }

  // The other method of the MouseMotionListener interface.
  public void mouseMoved(MouseEvent e) {;}
			
  public void mapSelections (String id, String op) {
    if (id.equals ("2")) {
      if (op.equals(HIGHLIGHT)) highlight (3);
      else resetColor (3);
      if (op.equals(HIGHLIGHT))	highlight (4);
      else resetColor(4);
    }
    else {
      int i=0;
      try {
	i= Integer.parseInt(id);
	if (op.equals(HIGHLIGHT))
	  highlight(i);
	else resetColor(i);
      }
      catch (Exception e) {
	System.out.println("invalid ID:"+ id);
      }
    }
  }

  public void highlight (int id) {
    //System.out.println("highlight " + id);
    buttons[id].setBackground(Color.red);
    buttons[id].repaint();
    //Graphics g = buttons[id].getGraphics();
    //g.setColor (Color.red);
  }

  public void resetColor (int id) {
    buttons[id].setBackground(Color.lightGray);
    buttons[id].repaint();
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
      frame.setSize(500, 500); // demo mode
      frame.setVisible(true);
    }
 

}
