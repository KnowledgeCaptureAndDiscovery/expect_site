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
  public static final int NAME = 0;
  public static final int CAP = 1;
  public static final int RESULT = 2;
  public static final int BODY = 3;

  private ExpectServer es;
  static JFrame frame;
  Dimension   origin = new Dimension(0, 0); 
  public static final String HIGHLIGHT = "highlight";
  public static final String RESET = "reset";

  //JComponent mscrollPane;  

  private JPanel mainMethodPanel;
  private altPanel selPanel;

  private JPanel methodPanels[] = new JPanel[4];

  private JLabel nameLabel;

  private Vector methodButtons[] = new Vector[4];
  
  Vector listOfAltButtons;

  //JScrollPane ascrollPane;

  private JButton getDescButton = new JButton("get method description");
  private JButton undoButton = new JButton("undo");

  private Component selected = null;

  TitledBorder tborder;

  Stack actionStack = new Stack();
  public MEditor (ExpectServer theServer) {
    es = theServer;

    //setLayout(new BoxLayout(this, BoxLayout.Y_AXIS));

    selPanel  = new altPanel(this, es);
    
    mainMethodPanel = new JPanel();
    mainMethodPanel.setLayout(new BoxLayout(mainMethodPanel,BoxLayout.Y_AXIS));
    mainMethodPanel.setAlignmentX(LEFT_ALIGNMENT);
    initMethodPanel();
    mainMethodPanel.setBorder(new BevelBorder(BevelBorder.LOWERED));
    add(mainMethodPanel);


    tborder = new TitledBorder(new LineBorder(Color.black, 1),
			 "Alternatives",
			 TitledBorder.LEFT,
			 TitledBorder.TOP,
			 new Font("Courier", Font.BOLD, 16));
    //selPanel.setBorder(new BevelBorder(BevelBorder.LOWERED)); 
    selPanel.setBorder(BorderFactory.createTitledBorder(tborder));
    add (selPanel);

    getDescButton.addActionListener(new getDescListener());
    add(getDescButton);

    undoButton.addActionListener(new undoListener());
    add(undoButton);


    setLayout(this);
  }
  private void initMethodPanel () {
    eButton bt;

    
    methodPanels[NAME] = new JPanel();
    methodPanels[CAP] = new JPanel();
    methodPanels[RESULT] = new JPanel();
    methodPanels[BODY] = new JPanel();
    methodButtons[NAME] = new Vector();
    methodButtons[CAP] = new Vector();
    methodButtons[RESULT] = new Vector();
    methodButtons[BODY] = new Vector();

    methodPanels[NAME].setLayout(new FlowLayout(FlowLayout.LEFT));
    nameLabel= new JLabel(" ((name method2001)");
    methodPanels[NAME].add(nameLabel);
    mainMethodPanel.add (methodPanels[NAME]);
    methodButtons[CAP].addElement(new eButton("(capability ",true));
    bt = new eButton("",CAP);

    bt.setName("expect-var-goal-form");
    bt.addMouseListener(this);
    methodButtons[CAP].addElement(bt);

    methodButtons[CAP].addElement(new eButton("(",true));
    bt = new eButton("VERB",CAP);
    bt.setName("expect-goal-name");
    bt.addMouseListener(this);
    methodButtons[CAP].addElement(bt);

    bt = new eButton("PARAMS",CAP);
    bt.addMouseListener(this);
    bt.setName("expect-var-goal-argument");
    methodButtons[CAP].addElement(bt);

    methodButtons[CAP].addElement(new eButton("))",true));
    methodPanels[CAP].setLayout(new FlowLayout(FlowLayout.LEFT));
    for (int i=0; i< methodButtons[CAP].size(); i++) {
      methodPanels[CAP].add((eButton)methodButtons[CAP].elementAt(i));
    }
    mainMethodPanel.add(methodPanels[CAP]);
    methodPanels[RESULT].setLayout(new FlowLayout(FlowLayout.LEFT));
    methodButtons[RESULT].addElement(new eButton("(result-type ",true));
    bt = new eButton(" DATA-TYPE",RESULT);
    bt.addMouseListener(this);
    bt.setName("expect-complex-data");
    methodButtons[RESULT].addElement(bt);
    methodButtons[RESULT].addElement(new eButton(")",true));
    for (int i=0; i< methodButtons[RESULT].size(); i++) {
      methodPanels[RESULT].add((eButton)methodButtons[RESULT].elementAt(i));
    }
    mainMethodPanel.add(methodPanels[RESULT]); 

    methodPanels[BODY].setLayout(new FlowLayout(FlowLayout.LEFT));
    methodButtons[BODY].addElement(new eButton("(method ",true));
    bt = new eButton(" EXPR",BODY);
    bt.addMouseListener(this);
    bt.setName("expect-form");
    methodButtons[BODY].addElement(bt);
    methodButtons[BODY].addElement(new eButton(")",true));
    for (int i=0; i< methodButtons[BODY].size(); i++) {
      methodPanels[BODY].add((eButton)methodButtons[BODY].elementAt(i));
    }
    mainMethodPanel.add(methodPanels[BODY]);


  }

  // A method from the MouseListener interface.  Invoked when the
  // user presses a mouse button.
  public void mousePressed(MouseEvent e) {;  }

  // The other, unused methods of the MouseListener interface.
  public void mouseReleased(MouseEvent e) {;}
  public void mouseClicked(MouseEvent e) {
    Component c = e.getComponent();
    String name = c.getName();

    if (!(name.equals("") || name == null)) {
      c.setBackground(Color.white);
      c.repaint();
      selPanel.updateAlts(name);
      if (selected != null) {
        selected.setBackground(Color.lightGray);
        selected.repaint();
      }
      selected = c;
      selPanel.updateUI();
      updateUI();
      repaint();
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
    System.out.println("replace selection?");
    Vector newButtons = new Vector();
    eButton nt = (eButton) selected;
    int sIdx = nt.getSource();
    Vector v;
    eButton b;
    System.out.println("source:"+sIdx);
    if (sIdx >= CAP && sIdx <= BODY) 
      v = methodButtons[sIdx];
    else {
      System.out.println("invalid selection in method?");
      return;
    }
    int i = 0;
    while (i < v.size() && (nt != (eButton) v.elementAt(i))) {
      newButtons.addElement(v.elementAt(i));
      //System.out.println(" add:"+ ((eButton) v.elementAt(i)).getText());
      i++;
    }
    if (i == v.size()) { 
      System.out.println("invalid selection in method?: cannot find button");
      return;
    }
    for (int j = 0; j < buttons.size() ; j++) {
      eButton tb = (eButton)buttons.elementAt(j); 
      if (!tb.forDisplayOnly()) {
        tb.setSource(sIdx);
        tb.addMouseListener(this);
      }
      newButtons.addElement(buttons.elementAt(j));
      //System.out.println(" addb:"+ ((eButton) buttons.elementAt(j)).getText());

    }
    i++;
    while (i <v.size()) {
      newButtons.addElement(v.elementAt(i));
      //System.out.println(" add:"+ ((eButton) v.elementAt(i)).getText());
      i++;
    }
    actionStack.push(methodButtons[sIdx]);
    actionStack.push(sIdx);
    methodButtons[sIdx] = newButtons;
    methodPanels[sIdx].removeAll();
    for (i=0; i< methodButtons[sIdx].size(); i++) {
      methodPanels[sIdx].add((eButton)methodButtons[sIdx].elementAt(i));
    }
    methodPanels[sIdx].updateUI();
    updateUI();
    repaint();
    frame.show();
    selected = null;
  }


  private void displayAlts() {
    int numAlts = listOfAltButtons.size();

    selPanel.removeAll();
    
    //JScrollPane ascrollpane = new JScrollPane();

    for(int i=0; i < numAlts; i++){
      String desc = "";
      Vector buttons = (Vector)listOfAltButtons.elementAt(i);
      int numBtns = buttons.size();
      for (int j=0; j < numBtns; j++) {
        desc = desc +" "+ ((eButton)buttons.elementAt(j)).getText();
      }
      eButton bt = new eButton (desc);
      System.out.println(desc);
      Integer ii = new Integer(i);
      bt.setName (ii.toString());
      bt.addMouseListener(this);
      selPanel.add (bt);
      //ascrollpane.add(bt);
      System.out.println("n of component:"+selPanel.getComponentCount());
    }
    selPanel.updateUI();
    updateUI();

    frame.show();

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
        //System.out.println("invalid ID:"+ id);
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

  class undoListener implements ActionListener {
    public void actionPerformed (ActionEvent e) {
      undo();
    }
  }

  public void undo () {
    if (!actionStack.empty())
      int sIdx = (int) actionStack.pop();
    else return;
    if (!actionStack.empty())
      Vector oldButtons = (Vector) actionStack.pop();
    else return;
    selPanel.removeAll();
    methodButtons[sIdx] = oldButtons;
    methodPanels[sIdx].removeAll();
    for (int i=0; i< methodButtons[sIdx].size(); i++) {
      methodPanels[sIdx].add((eButton)methodButtons[sIdx].elementAt(i));
    }
    methodPanels[sIdx].updateUI();
    updateUI();
    repaint();
    frame.show();
    selected = null;
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
    for (int i = 0; i < methodButtons[CAP].size(); i++) {
      res = res + " "+ ((eButton)methodButtons[CAP].elementAt(i)).getText();
    }
    res = res + "\n";
    for (int i = 0; i < methodButtons[RESULT].size(); i++) {
      res = res + " "+ ((eButton)methodButtons[RESULT].elementAt(i)).getText();
    }
    res = res + "\n";
    for (int i = 0; i < methodButtons[BODY].size(); i++) {
      res = res + " "+((eButton)methodButtons[BODY].elementAt(i)).getText();
    }
    res = res + "\n";
    System.out.println(res);
    return res;
  }


  public boolean needParen (String expr) {
    return false;
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

    mainMethodPanel.setBounds(inset, inset, b.width-2*inset, 200); 
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
