import java.awt.*;
import java.awt.event.*;
import javax.swing.*;

/** @author ges */

public class tPanel extends JPanel 
implements MouseListener {
  boolean selectPopUp;
  JPopupMenu pm;
  public tPanel() {
 
    //addMouseMotionListener(this);
    addMouseListener(this);
    pm = new JPopupMenu("ttt");
    pm.setLayout(new BoxLayout(pm, BoxLayout.Y_AXIS));
    add(pm);
    JMenuItem item1 = pm.add("menu 1");
    JMenuItem item2 = pm.add("menu 2");
    item1.addActionListener(new ActionListener() {
      public void actionPerformed(ActionEvent e) {
	System.out.println(" selected 1");
      }
    });

    item2.addActionListener(new ActionListener() {
      public void actionPerformed(ActionEvent e) {
	System.out.println(" selected 2");
      }
    });
       
  }  
  /*  public void mouseDragged(MouseEvent e)  {}
  public void mouseMoved(MouseEvent e)  {}*/
  public void mousePressed(MouseEvent e)  {}
  public void mouseClicked(MouseEvent e)
  { 
    if (selectPopUp == true) {
      selectPopUp = false;
    }
    else {
      int x = e.getX();
      int y = e.getY();
      JMenuItem item = (JMenuItem) e.getComponent();
      System.out.println(item.getText());
    }
  }
  public void mouseReleased(MouseEvent e)
  {
  }
  
  public void mouseEntered(MouseEvent e)
  {
  }
  
  public void mouseExited(MouseEvent e)
  {  } 

  public void processMouseEvent(MouseEvent e) {
    if (e.isPopupTrigger()) { 
      int x = e.getX();
      int y = e.getY();
      pm.show(e.getComponent(), x, y);
      selectPopUp = true;
    }
  }
    
  public static void main(String args[]) {
    JFrame f = new JFrame("test Frame");
    f.addWindowListener(new WindowAdapter() {
      public void windowClosing(WindowEvent e) {
	System.exit(0);
      }
    });
    f.getContentPane().add("Center", new tPanel());
    f.setSize(300, 200);
    //f.pack();
    f.setVisible(true);
  }

}
