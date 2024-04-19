// Copyright (C) 1998 by Jihie Kim
// All Rights Reserved
//

import javax.swing.*;
import javax.swing.border.*;
import javax.accessibility.*;

import java.awt.*;
import java.util.*;
import java.awt.event.*;

import Connection.*;

import Tree.methodListPanel;
import experiment.*;
import editor.*;


public class ExpectWindowPanel extends JPanel  {
  JInternalFrame maker;
  JLayeredPane lc;

  ExpectSocketAPI es;
  ExpectTabbedPanel eTabbedPanel;
  SmallTabbedPanel sTabbedPanel;
  private JComponent buttons;
  private JButton reloadButton;
  private JButton reloadEditorButton;
  private JButton quitButton;

  public Tree.methodListPanel listPanel;

  JPanel searchedListPanel = new JPanel();
  public String copiedGoalDesc ="";
  public String searchedMethodName="";
  public Vector searchedMethods = new Vector();
  public Vector copiedGoals = new Vector();
  JList listBox;

  String etype;  
  private JScrollPane savePane;
  private JTextArea saveArea = new JTextArea("");

  private Vector systemGoalsButtons; // cache system goals for editing

  public ExpectWindowPanel(String type) {
    etype = type;
    saveData.init("");
    es = new ExpectSocketAPI();

    cacheSystemGoals();

    setLayout(new BorderLayout());
    lc = new JDesktopPane();
    lc.setOpaque(false);
    //savePane = new JScrollPane(saveArea);
    System.out.println("before adding method list panel");
    listPanel = new Tree.methodListPanel(es,this,etype);
    System.out.println("added method list panel");
    maker = createMakerFrame(listPanel, "Method List");
    //maker.setBounds (2,2, 550, 700);  // paper mode
    //maker.setBounds (2,2, 460, 670); // demo mode
    maker.setBounds (2,2, 400, 830); // on Sun

    lc.add(maker, JLayeredPane.PALETTE_LAYER);  
    
    if (etype.equals("small")) {
      sTabbedPanel = new SmallTabbedPanel (es, this);
      maker = createMakerFrame(sTabbedPanel, "Views");
    }
    else {
      eTabbedPanel = new ExpectTabbedPanel(es, this);
      maker = createMakerFrame(eTabbedPanel, "Views");
    }
    maker.setBounds (605,2, 600, 830); // on Sun
    //maker.setBounds (555,2, 600, 700);  // paper mode
    //maker.setBounds (465,2, 520, 670); // demo mode
    lc.add(maker, JLayeredPane.PALETTE_LAYER);  
    
    add("Center", lc);

    buttons = new JPanel();
    reloadButton = new JButton("reload all");
    reloadButton.addActionListener (new reloadListener());
    reloadEditorButton = new JButton("reload editor");
    reloadEditorButton.addActionListener (new reloadEditorListener());
    quitButton = new JButton("quit");
    quitButton.addActionListener (new quitListener());
    buttons.add(reloadButton);
    buttons.add(reloadEditorButton);
    buttons.add(quitButton);
    add("South",buttons);
  }

  public void setCopiedGoal (String goalDesc) {
    //System.out.println ("set copied goal:" + goalDesc);
    copiedGoalDesc = goalDesc;
    saveArea.setText(goalDesc);
  }

  public String getCopiedGoal () {
    return copiedGoalDesc;
  }

  public JPanel getSaveArea () {
    return searchedListPanel;
  }
  public void setSearchedName (String methodName) {
    //System.out.println ("set copied goal:" + goalDesc);
    searchedMethodName = methodName;
  }

  public String getSearchedName() {
    return searchedMethodName;
  }

  public Vector getSearchedMethods() {
    return searchedMethods;
  }

  public int findStringInVector(String desc, Vector all) {
    int i = 0;
    while (i<all.size() && 
	 (!((String)all.elementAt(i)).equals(desc)))
      i++;
    if (i==all.size()) return -1; // not found
    else return i;
  }
  public void addSearchedMethod(String methodName) {
    if (searchedMethods.size() == 0) {
      eTabbedPanel.addSaveIcon();
    }    
    if (findStringInVector(methodName,searchedMethods) <0) // cannot find
    searchedMethods.addElement(methodName);
  }

  public void addCopiedGoal (String goalDesc) {
    //System.out.println ("set copied goal:" + goalDesc);
    if (findStringInVector(goalDesc,copiedGoals) <0) { // cannot find
      searchedListPanel.removeAll();
      copiedGoals.addElement(goalDesc);
      listBox = new JList(copiedGoals);
      savePane = new JScrollPane(listBox);
      searchedListPanel.add(savePane);
      savePane.updateUI();
    }
  }

  public JInternalFrame createMakerFrame(JPanel panel, String title) {
    JInternalFrame w;
    JPanel tp;
    Container contentPane;

    w = new JInternalFrame(title);
    contentPane = w.getContentPane();
    //contentPane.setLayout(new GridLayout(0, 1));
    System.out.println("internal methodlist");
    tp = panel;
    contentPane.add(tp);
    w.setResizable(true);            
    w.setMaximizable(true);
    w.setIconifiable(true);
    w.setVisible(true);
    return w;
  }

   class reloadListener implements ActionListener {
    public void actionPerformed (ActionEvent e) {
      reloadAll();
    }
  }
  class reloadEditorListener implements ActionListener {
    public void actionPerformed (ActionEvent e) {
      reloadEditor();
    }
  }
  class quitListener implements ActionListener {
    public void actionPerformed (ActionEvent e) {
      quit();
    }
  }

  public void quit() {
    saveData.end();
    es.closeServerConnection();
    System.exit(0);
  }

  public void reloadTabs () {
    System.out.println ("Reload Tabs");
    if (etype.equals("small")) 
      sTabbedPanel.reload();
    else eTabbedPanel.reload();

  }
  
  public void reloadEditor () {
    System.out.println ("Refresh");
    lc.removeAll(); 

    listPanel = new Tree.methodListPanel(es,this,etype);
    maker = createMakerFrame(listPanel, "Method List");
    maker.setBounds (2,2, 600, 830); // on sun
    //maker.setBounds (5,10, 550, 700);  // paper mode
    //maker.setBounds (2,2, 460, 670); // demo mode
    lc.add(maker, JLayeredPane.PALETTE_LAYER);  
    
    if (etype.equals("small"))
      maker = createMakerFrame(sTabbedPanel, "Views");
    else maker = createMakerFrame(eTabbedPanel, "Views");
    maker.setBounds (605,2, 600, 830); // sun
    //maker.setBounds (560,10, 600, 700); // paper mode
    //maker.setBounds (465,2, 520, 670); // demo mode
    lc.add(maker, JLayeredPane.PALETTE_LAYER);  
  }

  private void reloadAll () {
    System.out.println ("Reload All");
    lc.removeAll(); 
    listPanel = new Tree.methodListPanel(es,this,etype);
    maker = createMakerFrame(listPanel, "Method List");
    //maker.setBounds (2,2, 450, 580);
    maker.setBounds (2,2, 600, 830); // sun
    //maker.setBounds (5,10, 550, 700);
    //maker.setBounds (2,2, 460, 670); // demo mode
    lc.add(maker, JLayeredPane.PALETTE_LAYER);  
    
    if (etype.equals("small")) {
      sTabbedPanel = new SmallTabbedPanel (es, this);
      maker = createMakerFrame(sTabbedPanel, "Views");
    }
    else {
      eTabbedPanel = new ExpectTabbedPanel(es,this);
      maker = createMakerFrame(eTabbedPanel, "Views");
    }
    //maker.setBounds (455,2, 500, 580);
    maker.setBounds (605,2, 600, 830); //sun
    //maker.setBounds (560,10, 600, 700);
    //maker.setBounds (465,2, 520, 670); // demo mode
    lc.add(maker, JLayeredPane.PALETTE_LAYER);  
  }

  public void cacheSystemGoals () {
    String xmlInput = es.getEditAlts("expect-system-goals");
    altListRenderer ar = new altListRenderer(xmlInput);
    systemGoalsButtons = ar.getAlts();
    //for (int i=0; i<systemGoalsButtons.size(); i++)
    //  System.out.println(getDescriptionFromButtons((Vector)systemGoalsButtons.elementAt(i)));
  }
  public Vector getSystemGoalsButtons () {
    return systemGoalsButtons;
  }

  public static void main(String[] args) {
    JFrame frame = new JFrame("Expect Window Panel");
 
      frame.addWindowListener(new WindowAdapter() {
        public void windowClosing(WindowEvent e) {
                  System.exit(0);
        }
      });
      //System.out.println("args[0]:"+args[0]);
      frame.getContentPane().add("Center", new ExpectWindowPanel(args[0]));
      frame.setSize(1220, 900);//sun
      frame.setLocation(50,50);
      //frame.setSize(1000, 750); // demo mode
      frame.setVisible(true);
    }


}
