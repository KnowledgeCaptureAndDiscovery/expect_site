// 
// Jihie Kim, 1999
// 
package editor;

import java.awt.*;
import java.util.*;
import java.awt.event.*;
import com.sun.java.swing.*;
import Connection.ExpectServer;
import com.sun.java.swing.border.*;
import ExpectWindowPanel;
import experiment.*;

public class MEditor extends JPanel
                 implements MouseListener, LayoutManager {
  public static final int NAME = 0;
  public static final int CAP = 1;
  public static final int RESULT = 2;
  public static final int BODY = 3;

  private ExpectServer es;
  static JFrame frame;
  Dimension   origin = new Dimension(0, 0); 

  private JPanel mainMethodPanel;
  private altPanel selPanel;
  //private JPanel methodPanels[] = new JPanel[4];

  private JPanel namePanel = new JPanel();
  private JPanel capPanel = new JPanel();
  private Vector capPanels = new Vector();
  private JPanel resPanel = new JPanel();
  private Vector bodyPanels = new Vector();

  private JLabel nameLabel;
  private JLabel capLabel = new JLabel("capability:");
  private JPanel capLabelPanel = new JPanel();
  private JLabel bodyLabel = new JLabel("method:");
  private JPanel bodyLabelPanel = new JPanel();
  private JLabel resultLabel = new JLabel("result-type:");
  private Vector methodButtons[] = new Vector[4];
  Vector listOfAltButtons;
  Vector mappedButtons = null;
  private JTextArea sketchArea;
  JScrollPane sketchPane;

  JScrollPane ascrollpane;

  private JButton getDescButton = new JButton("get method description");
  private JButton undoButton = new JButton("undo");
  private JButton quitButton = new JButton("quit");

  private Component selected = null;
  Vector mappedButtonsFromSelected = null;
  TitledBorder tborder;
  ImageIcon icon = new ImageIcon("square_blue.gif");
  Stack actionStack = new Stack();
  String initCap = null;
  String initRes = "";
  String methodName = null;

  ExpectWindowPanel thePanel;

  private Color backgroundColor = getBackground();
  private Color nonTerminalColor = new Color(255,222,173);
  public MEditor (String editType, ExpectServer theServer, 
	        JFrame theFrame, 
	        ExpectWindowPanel rootPanel,
	        String name,
	        String initCapability, String resultDesc) {
    es = theServer;
    frame = theFrame;
    thePanel = rootPanel;
    initCap = initCapability;
    initRes = resultDesc;
    methodName = name;
    //setLayout(new BoxLayout(this, BoxLayout.Y_AXIS));
    tborder = new TitledBorder(new LineBorder(Color.black, 1),
			 "Method Sketch in Text",
			 TitledBorder.LEFT,
			 TitledBorder.TOP,
			 new Font("Courier", Font.BOLD, 16));
    sketchArea = new JTextArea("To do what(Capability):\nDo(Method Body):\n\nThe result will be(Result Type):");
    sketchPane = new JScrollPane(sketchArea);
    sketchPane.setBorder(BorderFactory.createTitledBorder(tborder));
    add(sketchPane);

    mainMethodPanel = new JPanel();
    //mainMethodPanel.setLayout(new FlowLayout(FlowLayout.LEFT));
    mainMethodPanel.setLayout(new GridLayout(0,1));
    mainMethodPanel.setAlignmentX(LEFT_ALIGNMENT);

    methodButtons[NAME] = new Vector();
    methodButtons[CAP] = new Vector();
    methodButtons[RESULT] = new Vector();
    methodButtons[BODY] = new Vector();

    namePanel.setLayout(new FlowLayout(FlowLayout.LEFT));
    capPanel.setLayout(new FlowLayout(FlowLayout.LEFT));
    resPanel.setLayout(new FlowLayout(FlowLayout.LEFT));
    capLabelPanel.setLayout(new FlowLayout(FlowLayout.LEFT));
    capLabelPanel.add(capLabel);
    bodyLabelPanel.setLayout(new FlowLayout(FlowLayout.LEFT));
    bodyLabelPanel.add(bodyLabel);

    if (editType.equals("Create")) initMethodPanel(initCapability);
    else if (editType.equals("CopyAndCreate")) {  
      Calendar rightNow = Calendar.getInstance();
      copyAndInitMethodPanel(methodName,
		         "_method"+rightNow.get(Calendar.HOUR)+
		         rightNow.get(Calendar.MINUTE)+
		         rightNow.get(Calendar.SECOND));
    }
    else copyAndInitMethodPanel(methodName);

    mainMethodPanel.setBorder(new BevelBorder(BevelBorder.LOWERED));
    ascrollpane = new JScrollPane(mainMethodPanel);
    add(ascrollpane);
    tborder = new TitledBorder(new LineBorder(Color.black, 1),
			 "Possible Selections",
			 TitledBorder.LEFT,
			 TitledBorder.TOP,
			 new Font("Courier", Font.BOLD, 16));
    //selPanel.setBorder(new BevelBorder(BevelBorder.LOWERED)); 
    selPanel  = new altPanel(this, es);
    selPanel.setBorder(BorderFactory.createTitledBorder(tborder));
    add (selPanel);

    //getDescButton.addActionListener(new getDescListener());
    //add(getDescButton);

    undoButton.addActionListener(new undoListener());
    undoButton.setBackground(new Color(200,100,100));
    undoButton.setForeground(Color.white);
    add(undoButton);
    //quitButton.addActionListener(new quitListener());
    //add(quitButton);

    setLayout(this);
  }

  private void initMethodPanel (String initCapability) {
    eButton bt;

    JPanel bodyPanel = new JPanel();
    nameLabel= new JLabel("name: "+methodName);
    namePanel.add(nameLabel);
    //mainMethodPanel.add(icon);
    mainMethodPanel.add (namePanel);
    mainMethodPanel.add(capLabelPanel);
    if (initCapability == null){
      bt = new eButton(" ",CAP);
      bt.setName("expect-var-goal-form");
      bt.addMouseListener(this);
      methodButtons[CAP].addElement(bt);
      
      methodButtons[CAP].addElement(new eButton("(",true));
      bt = new eButton("VERB",CAP);
      bt.setName("expect-goal-name");
      bt.setBackground(nonTerminalColor);
      bt.addMouseListener(this);
      methodButtons[CAP].addElement(bt);
      
      bt = new eButton("PARAM1 PARAM2 ...",CAP);
      bt.addMouseListener(this);
      bt.setName("expect-first-var-goal-arguments");
      bt.setBackground(nonTerminalColor);
      methodButtons[CAP].addElement(bt);

      methodButtons[CAP].addElement(new eButton(")",true));
      for (int i=0; i< methodButtons[CAP].size(); i++) {
        capPanel.add((eButton)methodButtons[CAP].elementAt(i));
      }
      //mainMethodPanel.add(icon);
      capPanels.addElement(capPanel);
      mainMethodPanel.add(capPanel);
    }
    else {
      int i;
      JPanel p= new JPanel();
      p.setLayout(new FlowLayout(FlowLayout.LEFT));
      String xmlString = es.getEditCapOrBody(initCapability,"nil");
      methodDescRenderer mr = new methodDescRenderer(xmlString);
      Vector buttons = mr.getCapButtons();
      int indent = 0;
      for (i=0; i<buttons.size(); i++)
        methodButtons[CAP].addElement(buttons.elementAt(i));
      for (i=0; i<methodButtons[CAP].size(); i++) {
        bt = (eButton)methodButtons[CAP].elementAt(i);
        bt.addMouseListener(this);
        bt.setSource(CAP);
        if (bt.getText().equals(" ") && (p.getComponentCount() > 10)) {
	capPanels.addElement(p);
	mainMethodPanel.add(p);
	p = new JPanel();
	p.setLayout(new FlowLayout(FlowLayout.LEFT));
	for (int j=0; j <indent; j++)
	  p.add(new eButton(" ",true));
        }
        else if (bt.getText().equals("(")) indent = indent +3;
        else if (bt.getText().equals(")")) indent = indent -3;
        p.add(bt);
      }
      capPanels.addElement(p);
      mainMethodPanel.add(p);
    }
    //{
    //  bt = new eButton(initCapability, true);
    //  bt.setName("expect-null-arg");
    //  capPanel.add(bt);
    // }
    //mainMethodPanel.add(capPanel);

    mainMethodPanel.add(resultLabel);
    if (initRes.equals(""))
        bt = new eButton("DATA-TYPE",RESULT);
    else bt = new eButton(initRes,RESULT);
    bt.setBackground(nonTerminalColor);
    bt.addMouseListener(this);
    bt.setName("expect-complex-data");
    methodButtons[RESULT].addElement(bt);
    for (int i=0; i< methodButtons[RESULT].size(); i++) {
      resPanel.add((eButton)methodButtons[RESULT].elementAt(i));
    }
    mainMethodPanel.add(resPanel); 

    //mainMethodPanel.add(icon);
    mainMethodPanel.add(bodyLabelPanel);
    bodyPanel.setLayout(new FlowLayout(FlowLayout.LEFT));
    bt = new eButton("EXPRESSION",BODY);
    bt.setBackground(nonTerminalColor);
    bt.addMouseListener(this);
    bt.setName("expect-expression");
    methodButtons[BODY].addElement(bt);
    methodButtons[BODY].addElement(new eButton("",true));
    for (int i=0; i< methodButtons[BODY].size(); i++) {
      bodyPanel.add((eButton)methodButtons[BODY].elementAt(i));
    }
    mainMethodPanel.add(bodyPanel);
    bodyPanels.addElement(bodyPanel);
  }
  private void copyAndInitMethodPanel (String methodName,
			         String newName) {
    copyAndInitMethodPanel(methodName);
    nameLabel.setText("name: "+newName);
    System.out.println("copy and create:"+newName);
  }
  private void copyAndInitMethodPanel (String methodName) {
    int i;
    eButton bt;
    JPanel p= new JPanel();
    p.setLayout(new FlowLayout(FlowLayout.LEFT));
    String xmlString = es.getEditMethod(methodName);
    methodDescRenderer mr = new methodDescRenderer(xmlString);
    Vector buttons = mr.getCapButtons();
    if (buttons == null) {
      System.out.println(" Cannot find method:"+methodName);
      initMethodPanel(null);
      return;
    }

    nameLabel= new JLabel("name: "+methodName);
    namePanel.add(nameLabel);
    mainMethodPanel.add (namePanel);

    mainMethodPanel.add(capLabelPanel);
    int indent = 0;
    for (i=0; i<buttons.size(); i++)
      methodButtons[CAP].addElement(buttons.elementAt(i));
    for (i=0; i<methodButtons[CAP].size(); i++) {
      bt = (eButton)methodButtons[CAP].elementAt(i);
      bt.addMouseListener(this);
      bt.setSource(CAP);
      // when blank and there is more than one component in the current panel
      // add one more row
      if (bt.getText().equals(" ") && (p.getComponentCount() > 10)) {
        capPanels.addElement(p);
        mainMethodPanel.add(p);
        p = new JPanel();
        p.setLayout(new FlowLayout(FlowLayout.LEFT));
        for (int j=0; j <indent; j++)
	p.add(new eButton(" ",true));
      }
      else if (bt.getText().equals("(")) indent = indent +3;
      else if (bt.getText().equals(")")) indent = indent -3;
      p.add(bt);
    }
    capPanels.addElement(p);
    mainMethodPanel.add(p);
    
    buttons = mr.getResultButtons();
    mainMethodPanel.add(resultLabel);
    for (i=0; i<buttons.size(); i++) 
      methodButtons[RESULT].addElement(buttons.elementAt(i));
    for (i=0; i< methodButtons[RESULT].size(); i++) {
      bt = (eButton)methodButtons[RESULT].elementAt(i);
      bt.addMouseListener(this);
      bt.setSource(RESULT);
      resPanel.add(bt);
    }
    mainMethodPanel.add(resPanel); 

    indent = 0;
    p= new JPanel();
    p.setLayout(new FlowLayout(FlowLayout.LEFT));
    buttons = mr.getBodyButtons();
    mainMethodPanel.add(bodyLabelPanel);
    for (i=0; i<buttons.size(); i++)
      methodButtons[BODY].addElement(buttons.elementAt(i));
    for (i=0; i<methodButtons[BODY].size(); i++) {
      bt = (eButton)methodButtons[BODY].elementAt(i);
      bt.addMouseListener(this);
      bt.setSource(BODY);
      // when blank and there is more than one component in the current panel
      // add one more row
      if (bt.getText().equals(" ") && (p.getComponentCount() > 10)) {
        bodyPanels.addElement(p);
        mainMethodPanel.add(p);
        p = new JPanel();
        p.setLayout(new FlowLayout(FlowLayout.LEFT));
        for (int j=0; j <indent; j++)
	p.add(new eButton(" ",true));
      }
      else if (bt.getText().equals("(")) indent = indent +3;
      else if (bt.getText().equals(")")) indent = indent -3;
      p.add(bt);
    }
    ((eButton)methodButtons[BODY].elementAt(0)).setName("expect-expression");
    bodyPanels.addElement(p);
    mainMethodPanel.add(p);
  }

  // A method from the MouseListener interface.  Invoked when the
  // user presses a mouse button.
  public void mousePressed(MouseEvent e) {;  }

  // The other, unused methods of the MouseListener interface.
  public void mouseReleased(MouseEvent e) {;}
  public void mouseClicked(MouseEvent e) {
    Component c = e.getComponent();
    selectButton (c);
  }

  private void selectButton (Component c) {
    String name = c.getName();
    eButton sb = (eButton) c;
    String desc="";
    if (sb != null) desc= sb.getText();
    // %% needs to be fixed
    if (name == null || name.equals("") || desc.equals(""))
      return;
    
    c.setBackground(Color.white);
    c.repaint();
    //System.out.println(" before update alts");
    selPanel.updateAlts(name, c);
    //System.out.println(" after update alts");
      
    selected = c;
    resetColor(sb);
    if (desc.equals(" ")) 
      mappedButtonsFromSelected = mappedButtons;
    //System.out.println(" before update ui");
    selPanel.updateUI();
    updateUI();
    repaint();
    frame.show();
    
  }

  public void mouseEntered(MouseEvent e) {

    Component c = e.getComponent();
    //System.out.println("Entered component: "+c.getName());
    highlightSelections((eButton)c);
  }
  public void mouseExited(MouseEvent e) {
    Component c = e.getComponent();
    if (selected != c) resetColor((eButton)c);
    if (mappedButtons !=null)
      for (int i=0; i<mappedButtons.size(); i++)
        resetColor((eButton)mappedButtons.elementAt(i));
  }

  public void replaceSelection (Vector buttons) {
    //System.out.println("replace selection?");
    Vector newButtons = new Vector();
    eButton selectedButton = (eButton) selected;
    int sIdx = selectedButton.getSource();
    Vector v;
    String desc = "";
    eButton nb;
    eButton ob;

    //System.out.println("source:"+sIdx);
    //System.out.println("selected:"+selected.getName());

    if (sIdx >= CAP && sIdx <= BODY) 
      v = methodButtons[sIdx];
    else {
      System.out.println("invalid selection in method?");
      return;
    }
    int i = 0;
    /* add buttons before the selected button */
    while (i < v.size() && (selectedButton != (eButton) v.elementAt(i))) {
      ob = (eButton) v.elementAt(i);
      nb = new eButton(ob.getText(),ob.getSource());
      nb.setName(ob.getName());
      nb.setBorderPainted(ob.isBorderPainted());
      if (!nb.forDisplayOnly()) {
        nb.setSource(sIdx);
        nb.addMouseListener(this);
        resetColor(nb);
      }
      newButtons.addElement(nb);
      //newButtons.addElement(v.elementAt(i));
      //System.out.println(" add:"+ ((eButton) v.elementAt(i)).getText());
      //desc = desc + ((eButton) v.elementAt(i)).getText();
      //System.out.println("copy old button:"+ob.getText()+":"+ob.getName());
      //System.out.println("copy new button:"+nb.getText()+":"+nb.getName());
      i++;
    }
    //desc = desc.substring (desc.indexOf(":")+1);

    if (i == v.size()) { 
      System.out.println("invalid selection in method?: cannot find button");
      return;
    }
    /* add the replacement */
    
    for (int j = 0; j < buttons.size() ; j++) {
      eButton tb = (eButton)buttons.elementAt(j); 
      if (!tb.forDisplayOnly()) {
        tb.setSource(sIdx);
        tb.addMouseListener(this);
      }
      newButtons.addElement(tb);
      //desc = desc + tb.getText();
    }
    /* add the rest of the existing buttons */
    if (selectedButton.getText().equals(" ")) {
      for (int k = 0; k < mappedButtonsFromSelected.size(); k++)
        i++;
      
    }
    else i++; // skip current button

    while (i <v.size()) {
      ob = (eButton) v.elementAt(i);
      nb = new eButton(ob.getText(),ob.getSource());
      nb.setName(ob.getName());
      nb.setBorderPainted(ob.isBorderPainted());
      if (!nb.forDisplayOnly()) {
        nb.setSource(sIdx);
        nb.addMouseListener(this);
        resetColor(nb);
      }
      newButtons.addElement(nb);
      //newButtons.addElement(v.elementAt(i));
      //System.out.println(" add:"+ ((eButton) v.elementAt(i)).getText());
      //desc = desc + ((eButton) v.elementAt(i)).getText();
      i++;
    }

    actionStack.push(methodButtons[sIdx]);
    actionStack.push(new Integer(sIdx));

    methodButtons[sIdx] = newButtons;
    //methodPanels[sIdx].removeAll();
    mainMethodPanel.removeAll();
    
    updateButtons(sIdx,methodButtons[sIdx]);
    addAllPanels();
    /*
    methodPanels[sIdx].updateUI();
    */

    updateUI();
    repaint();

    frame.show();

    selected = null;
    if (buttons.size() == 1) {
      selectButton((Component)buttons.elementAt(0));
    }
    saveData.record("select Button:"+selectedButton.getName()+
		":"+selectedButton.getText()+
		"\n TO become:"+getDesc());
  }

  private void updateButtons (int sIdx, Vector buttons) {
    int i;
    int indent = 0;
    JPanel p = new JPanel();
    eButton bt;
    p.setLayout(new FlowLayout(FlowLayout.LEFT));
    if (sIdx == RESULT) {
      resPanel.removeAll();
      for (i=0; i< buttons.size(); i++) 
        resPanel.add((eButton) buttons.elementAt(i));
    }
    else if (sIdx == CAP) {
      for (i=0; i<capPanels.size(); i++)
        ((JPanel)capPanels.elementAt(i)).removeAll();
      capPanels.removeAllElements();
      for (i=0; i< buttons.size(); i++) {
        bt = (eButton)buttons.elementAt(i);
        // when blank and there is more than one component in the current panel
        // add one more row
        if (bt.getText().equals(" ") && (p.getComponentCount() > 10)) {
	capPanels.addElement(p);
	p = new JPanel();
	p.setLayout(new FlowLayout(FlowLayout.LEFT));
	
	for (int j=0; j <indent; j++)
	  p.add(new eButton(" ",true));
        }
        else if (bt.getText().equals("(")) indent = indent +3;
        else if (bt.getText().equals(")")) indent = indent -3;
        p.add(bt);
      }
      capPanels.addElement(p);
    }	
    else if (sIdx == BODY) {
      for (i=0; i<bodyPanels.size(); i++)
        ((JPanel)bodyPanels.elementAt(i)).removeAll();
      bodyPanels.removeAllElements();
      for (i=0; i< buttons.size(); i++) {
        bt = (eButton)buttons.elementAt(i);
        if (bt.getText().equals(" ") && bt.isBorderPainted()
	  && (p.getComponentCount() > 10)) {
	bodyPanels.addElement(p);
	p = new JPanel();
	p.setLayout(new FlowLayout(FlowLayout.LEFT));
	for (int j=0; j <indent; j++)
	  p.add(new eButton(" ",true));
        }
        if (bt.getText().equals("(")) indent = indent+3;
        else if (bt.getText().equals(")")) indent = indent-3;
        p.add(bt);
        //System.out.println("added:"+bt.getText()+":");
      }
      bodyPanels.addElement(p);
    }
    else System.out.println(" invalid selection in adding new buttons");

  }

  private void addAllPanels () {
    mainMethodPanel.add(namePanel);
    mainMethodPanel.add(capLabelPanel);
    //if (initCap == null) 
    for (int i = 0; i < capPanels.size(); i++)
      mainMethodPanel.add((JPanel) capPanels.elementAt(i));
    //else mainMethodPanel.add(capPanel);
    mainMethodPanel.add(resultLabel);
    mainMethodPanel.add(resPanel);
    mainMethodPanel.add(bodyLabelPanel);
    for (int i = 0; i < bodyPanels.size(); i++)
      mainMethodPanel.add((JPanel) bodyPanels.elementAt(i));
        
  }

  private void displayAlts() {
    int numAlts = listOfAltButtons.size();
    selPanel.removeAll();
    
    for(int i=0; i < numAlts; i++){
      String desc = "";
      Vector buttons = (Vector)listOfAltButtons.elementAt(i);
      int numBtns = buttons.size();
      for (int j=0; j < numBtns; j++) {
        desc = desc +" "+ ((eButton)buttons.elementAt(j)).getText();
      }
      eButton bt = new eButton (desc);
      //System.out.println(desc);
      Integer ii = new Integer(i);
      bt.setName (ii.toString());
      bt.addMouseListener(this);
      selPanel.add (bt);
      //ascrollpane.add(bt);
      //System.out.println("n of component:"+selPanel.getComponentCount());
    }
    selPanel.updateUI();
    updateUI();

    frame.show();

  }



  public Vector getMappedButtonsFromSelected () {
    return mappedButtonsFromSelected;
  }

  			
  public void highlightSelections (eButton selectedButton) {
    String label = selectedButton.getText();
    eButton bt;
    highlight(selectedButton);

    if (!(label.equals(" ") && selectedButton.isBorderPainted())) {
      //System.out.println("label:"+label+":");
      return;
    }

    mappedButtons= new Vector();
 
    int sIdx = selectedButton.getSource();
    int NOfNest=0;
    Vector v =methodButtons[sIdx];
    int i = 0;
    while (i < v.size() && (selectedButton != (eButton) v.elementAt(i))) {
      i++;
    }

    mappedButtons.addElement(selectedButton);
    i++; 
    bt = (eButton)v.elementAt(i);
    label = bt.getText();
    if (label.equals("(")) { // first button
      highlight(bt);
      mappedButtons.addElement(bt);
      NOfNest++;
      i++;
    }
    else return;
    while (NOfNest >0 && i < v.size()) {
      bt = (eButton)v.elementAt(i);
      label = bt.getText();
      if (label.equals("(")) NOfNest++;
      else if (label.equals(")")) NOfNest--;
      //System.out.println("neighbor:"+label);
      if (bt.isBorderPainted() || (! label.equals(" "))) { 
        highlight(bt);
      }
      mappedButtons.addElement(bt);      
      i++;
    }
  }

  public void highlight (eButton bt) {
    bt.setBackground(Color.red);
    bt.repaint();

  }

  public void resetColor (eButton bt) {
    String desc = bt.getText();
    if (bt.isBorderPainted() && 
        (!desc.equals(" ")) && (!desc.startsWith("?")) &&
        bt.getName().startsWith("expect-"))
      bt.setBackground(nonTerminalColor);
    else 
      bt.setBackground(backgroundColor);
    bt.repaint();
    
  }
  
  

  class getDescListener implements ActionListener {
    public void actionPerformed (ActionEvent e) {
      getDesc();
    }
  }

  class undoListener implements ActionListener {
    public void actionPerformed (ActionEvent e) {
      undo();
      saveData.record("undo to become:"+getDesc());
    }
  }
  class quitListener implements ActionListener {
    public void actionPerformed (ActionEvent e) {
      System.exit(0);
    }
  }

  public void undo () {
    int sIdx;
    Vector oldButtons;
    if (!actionStack.empty())
      sIdx = ((Integer) actionStack.pop()).intValue();
    else return;
    if (!actionStack.empty())
      oldButtons = (Vector) actionStack.pop();
    else return;
    selPanel.removeAll();
    methodButtons[sIdx] = oldButtons;
    mainMethodPanel.removeAll();
    updateButtons(sIdx,methodButtons[sIdx]);
    addAllPanels();
    updateUI();
    repaint();
    frame.show();
    selected = null;
  }

  
  public String getDesc () {
    String res = "((name ";
    res = res + nameLabel.getText().substring(6);
    res = res + ")\n(capability ";
    
    //if (initCap == null)
    for (int i = 0; i < capPanels.size(); i++) {
      JPanel p = (JPanel) capPanels.elementAt(i);
      for (int j = 0; j < p.getComponentCount(); j++)
        res = res + " "+ ((eButton)p.getComponent(j)).getText();
      res = res + "\n";
    }
    //else res = res + initCap;
    res = res + ")\n(result-type ";
    for (int i = 0; i < methodButtons[RESULT].size(); i++) {
      res = res + " "+ ((eButton)methodButtons[RESULT].elementAt(i)).getText();
    }
    res = res + ")\n(method ";
    for (int i = 0; i < bodyPanels.size(); i++) {
      JPanel p = (JPanel) bodyPanels.elementAt(i);
      for (int j = 0; j < p.getComponentCount(); j++)
        res = res + " "+ ((eButton)p.getComponent(j)).getText();
      res = res + "\n";
    }
    
    res = res + ")\n)";
    //System.out.println(res);
    return res;
  }


  public Vector getSearchedCapability () {
    if (thePanel == null) return null;
    String methodName = thePanel.getSearchedName();
    if (methodName.equals("")) return null;

    String xmlString = es.getSearchedCapability(methodName);
    methodDescRenderer mr = new methodDescRenderer(xmlString);
    return mr.getCapButtons();
  }
  public String getSketch () {
    return sketchArea.getText();
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
    sketchPane.setBounds (inset, inset, b.width-2*inset, 110);
    ascrollpane.setBounds(inset, inset*2+110, b.width-2*inset, 300); 
    selPanel.setBounds(inset,inset*3 + 410, b.width-2*inset-90, 200); 
    //getDescButton.setBounds (inset, inset*4+610, 200, 30);
    undoButton.setBounds (b.width-80, inset*3+510, 70, 30);
    //quitButton.setBounds (inset+410, inset*4+610, 100, 30);
  }

  
  
  public static void main(String[] args) {
    JFrame theframe = new JFrame("EXPECT Method Editor");
    ExpectServer es = new ExpectServer();
      theframe.addWindowListener(new WindowAdapter() {
        public void windowClosing(WindowEvent e) {
                  System.exit(0);
        }
      });
      //String name = "compute-combat-power";
      String name = "_method1";
      //String cap = "(capability (find (obj (inst-of avlb))))";
      String cap = null;
      theframe.getContentPane().add("Center", 
		 new MEditor("Create",es, theframe, 
			   null, name, cap,""));
      
      

      theframe.setLocation(50,50);
      theframe.setSize(700, 700); 
      theframe.setVisible(true);
    }
 

}
