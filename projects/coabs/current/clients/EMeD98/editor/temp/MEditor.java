// 
// Jihie Kim, 1999
// 

import com.sun.java.swing.*;
import java.awt.*;
import java.util.*;
import java.awt.event.*;
import Connection.ExpectServer;
import com.sun.java.swing.border.*;

/** A simple applet that uses the Java 1.1 event handling model */
public class MEditor extends JPanel
                 implements MouseListener, LayoutManager {
  private ExpectServer es;
  static JFrame frame;
  Dimension   origin = new Dimension(0, 0); 
  public static final String HIGHLIGHT = "highlight";
  public static final String RESET = "reset";

  //JComponent mscrollPane;  

  private JPanel methodPanel;
  private JPanel selPanel;

  private JPanel namePanel;
  private JPanel capPanel;
  private JPanel resPanel;
  private JPanel bodyPanel;

  private JLabel nameLabel;
  private Vector capButtons= new Vector();
  private Vector resButtons = new Vector();
  private Vector bodyButtons= new Vector();

  //JScrollPane ascrollPane;

  private JButton altButtons[] = new JButton[100];

  private JButton getDescButton = new JButton("get method description");

  public MEditor (ExpectServer theServer) {
    es = theServer;

    //setLayout(new BoxLayout(this, BoxLayout.Y_AXIS));


    
    methodPanel = new JPanel();
    methodPanel.setLayout(new BoxLayout(methodPanel, BoxLayout.Y_AXIS));
    initMethodPanel();
    add(methodPanel);

    selPanel  = new altPanel(this,"",es);
    selPanel.setBorder(new BevelBorder(BevelBorder.LOWERED)); 
    add (selPanel);

    getDescButton.addActionListener(new getDescListener());
    add(getDescButton);
    setLayout(this);
  }

  private void initMethodPanel () {
    eButton bt;

    namePanel = new JPanel();
    capPanel = new JPanel();
    resPanel = new JPanel();
    bodyPanel = new JPanel();

    namePanel.setLayout(new BoxLayout(namePanel, BoxLayout.X_AXIS));
    namePanel.setAlignmentX(LEFT_ALIGNMENT);
    nameLabel= new JLabel(" ((name method2001)");
    namePanel.add(nameLabel);
    methodPanel.add (namePanel);
    capButtons.addElement(new eButton("(capability ",true));
    bt = new eButton("");

    bt.setName("expect-var-goal-form");
    bt.addMouseListener(this);
    capButtons.addElement(bt);

    capButtons.addElement(new eButton("(",true));
    bt = new eButton("VERB");
    bt.setName("expect-goal-name");
    bt.addMouseListener(this);
    capButtons.addElement(bt);

    bt = new eButton("PARAMS");
    bt.addMouseListener(this);
    bt.setName("expect-var-goal-argument");
    capButtons.addElement(bt);

    capButtons.addElement(new eButton("))",true));
    capPanel.setLayout(new BoxLayout(capPanel, BoxLayout.X_AXIS));
    capPanel.setAlignmentX(LEFT_ALIGNMENT);
    for (int i=0; i< capButtons.size(); i++) {
      capPanel.add((eButton)capButtons.elementAt(i));
    }
    methodPanel.add(capPanel);
    resPanel.setLayout(new BoxLayout(resPanel, BoxLayout.X_AXIS));
    resPanel.setAlignmentX(LEFT_ALIGNMENT);
    resButtons.addElement(new eButton("(result-type ",true));
    bt = new eButton(" DATA-TYPE");
    bt.addMouseListener(this);
    bt.setName("expect-complex-data");
    resButtons.addElement(bt);
    resButtons.addElement(new eButton(")",true));
    resPanel.setAlignmentX(LEFT_ALIGNMENT);
    resPanel.setAlignmentY(TOP_ALIGNMENT);
    for (int i=0; i< resButtons.size(); i++) {
      resPanel.add((eButton)resButtons.elementAt(i));
    }
    methodPanel.add(resPanel); 
    bodyPanel.setLayout(new BoxLayout(bodyPanel, BoxLayout.X_AXIS));
    bodyPanel.setAlignmentX(LEFT_ALIGNMENT);
    bodyButtons.addElement(new eButton("(method ",true));
    bt = new eButton(" EXPR");
    bt.addMouseListener(this);
    bt.setName("expect-form");
    bodyButtons.addElement(bt);
    bodyButtons.addElement(new eButton(")",true));
    for (int i=0; i< bodyButtons.size(); i++) {
      bodyPanel.add((eButton)bodyButtons.elementAt(i));
    }
    methodPanel.add(bodyPanel);


  }


  // A method from the MouseListener interface.  Invoked when the
  // user presses a mouse button.
  public void mousePressed(MouseEvent e) {;  }

  // The other, unused methods of the MouseListener interface.
  public void mouseReleased(MouseEvent e) {;}
  public void mouseClicked(MouseEvent e) {
    
    Component c = e.getComponent();
    String name = c.getName();
    if (!(name.equals("")|| name== null)) {
      selPanel.removeAll();
      selPanel = new altPanel(this,name,es);
      selPanel.updateUI();
      updateUI();
      
      frame.show();
    }
  }
  public void mouseEntered(MouseEvent e) {

    Component c = e.getComponent();
    System.out.println("Selected component: "+c.getName());
    mapSelections(c.getName(),HIGHLIGHT);
  }
  public void mouseExited(MouseEvent e) {
    mapSelections(((eButton)e.getComponent()).getIndex(),RESET);
    
  }

  public void replaceSelection (Vector buttons) {
    System.out.println("replace?");
  }

  public void reload () {
    removeAll();
    methodPanel = new JPanel();
    add (methodPanel);
    selPanel = new JPanel();
    add (selPanel);
  }


			
  public void mapSelections (String id, String op) {
    if (id.equals ("3")) {
      if (op.equals(HIGHLIGHT)) highlight (4);
      else resetColor (4);
      if (op.equals(HIGHLIGHT))	highlight (5);
      else resetColor(5);
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
    //buttons[id].setBackground(Color.red);
    //buttons[id].repaint();

  }

  public void resetColor (int id) {
    //buttons[id].setBackground(Color.lightGray);
    //buttons[id].repaint();
  }

  class getDescListener implements ActionListener {
    public void actionPerformed (ActionEvent e) {
      getDesc();
    }
  }
  public String getDesc () {
    String res = "";
    res = res + nameLabel.getText();
    res = res + "\n";
    for (int i = 1; i < capButtons.size(); i++) {
      res = res + " "+ ((eButton)capButtons.elementAt(i)).getText();
    }
    res = res + "\n";
    for (int i = 1; i <= resButtons.size(); i++) {
      res = res + " "+ ((eButton)resButtons.elementAt(i)).getText();
    }
    res = res + "\n";
    for (int i = 1; i <= bodyButtons.size(); i++) {
      res = res + " "+((eButton)bodyButtons.elementAt(i)).getText();
    }
    res = res + "\n";
    System.out.println(res);
    return res;
  }


  public Dimension preferredLayoutSize(Container c){return origin;}
  public Dimension minimumLayoutSize(Container c){return origin;}
  public void addLayoutComponent(String s, Component c) {}
  public void removeLayoutComponent(Component c) {}
  public void layoutContainer(Container c) {
    Rectangle b = c.getBounds(); 
    int topHeight = 90; 
    int inset = 4; 
    int paramHeight = 215;

    methodPanel.setBounds(inset, inset, b.width-2*inset, 200); 
    selPanel.setBounds(inset,inset*2 + 200, b.width-2*inset, 200); 
    getDescButton.setBounds (inset, inset*3+400, 200, 30);
    }


  
  public static void main(String[] args) {
    frame = new JFrame("Expect Editor");
    ExpectServer es = new ExpectServer();
      frame.addWindowListener(new WindowAdapter() {
        public void windowClosing(WindowEvent e) {
                  System.exit(0);
        }
      });
      
      frame.getContentPane().add("Center", new MEditor(es));
      frame.setLocation(50,50);
      frame.setSize(500, 500); // demo mode
      frame.setVisible(true);
    }
 

}
