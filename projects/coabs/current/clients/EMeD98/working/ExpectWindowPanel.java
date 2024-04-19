// Copyright (C) 1998 by Jihie Kim
// All Rights Reserved
//

import com.sun.java.swing.*;
import com.sun.java.swing.border.*;
import com.sun.java.accessibility.*;

import java.awt.Panel;
import java.awt.Color;
import java.awt.BorderLayout;
import java.awt.GridLayout;
import java.awt.Font;
import java.awt.event.*;
import java.awt.Dimension;
import java.awt.Graphics;
import java.awt.Color;
import java.awt.Rectangle;
import java.awt.Container;

import Connection.ExpectServer;
import Tree.methodListPanel;

public class ExpectWindowPanel extends JPanel  {
  JInternalFrame maker;
  JLayeredPane lc;
  ExpectServer es;
  ExpectTabbedPanel eTabbedPanel;
  private JComponent buttons;
  private JButton reloadButton;
  private JButton reloadEditorButton;
  private JButton quitButton;

  public methodListPanel listPanel;
  public String copiedGoalDesc ="";

  public ExpectWindowPanel()    {
    es = new ExpectServer();
    setLayout(new BorderLayout());
    lc = new JDesktopPane();
    lc.setOpaque(false);
    listPanel = new methodListPanel(es,this);
    maker = createMakerFrame(listPanel, "Method List");
    //maker.setBounds (5,10, 550, 700);
    //maker.setBounds (2,2, 460, 670); // demo mode
    maker.setBounds (2,2, 600, 830);
    lc.add(maker, JLayeredPane.PALETTE_LAYER);  
    
    eTabbedPanel = new ExpectTabbedPanel(es, this);
    maker = createMakerFrame(eTabbedPanel, "Views");
    maker.setBounds (605,2, 600, 830);
    //maker.setBounds (560,10, 600, 700);
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
    System.out.println ("set copied goal:" + goalDesc);
    copiedGoalDesc = goalDesc;
  }

  public String getCopiedGoal () {
    return copiedGoalDesc;
  }


  public JInternalFrame createMakerFrame(JPanel panel, String title) {
    JInternalFrame w;
    JPanel tp;
    Container contentPane;

    w = new JInternalFrame(title);
    contentPane = w.getContentPane();
    //contentPane.setLayout(new GridLayout(0, 1));

    tp = panel;
    contentPane.add(tp);
    w.setResizable(true);            
    w.setMaximizable(true);
    w.setIconifiable(true);

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
    System.exit(0);
  }

  public void reloadTabs () {
    System.out.println ("Reload Tabs");
    eTabbedPanel.reload();

  }
  
  public void reloadEditor () {
    System.out.println ("Refresh");
    lc.removeAll(); 

    listPanel = new methodListPanel(es,this);
    maker = createMakerFrame(listPanel, "Method List");
    maker.setBounds (2,2, 600, 830);
    //maker.setBounds (5,10, 550, 700);
    //maker.setBounds (2,2, 460, 670); // demo mode
    lc.add(maker, JLayeredPane.PALETTE_LAYER);  
    
    maker = createMakerFrame(eTabbedPanel, "Views");
    maker.setBounds (605,2, 600, 830);
    //maker.setBounds (560,10, 600, 700);
    //maker.setBounds (465,2, 520, 670); // demo mode
    lc.add(maker, JLayeredPane.PALETTE_LAYER);  
  }

  private void reloadAll () {
    System.out.println ("Reload All");
    lc.removeAll(); 
    listPanel = new methodListPanel(es,this);
    maker = createMakerFrame(listPanel, "Method List");
    //maker.setBounds (2,2, 450, 580);
    maker.setBounds (2,2, 600, 830);
    //maker.setBounds (5,10, 550, 700);
    //maker.setBounds (2,2, 460, 670); // demo mode
    lc.add(maker, JLayeredPane.PALETTE_LAYER);  
    
    eTabbedPanel = new ExpectTabbedPanel(es,this);
    maker = createMakerFrame(eTabbedPanel, "Views");
    //maker.setBounds (455,2, 500, 580);
    maker.setBounds (605,2, 600, 830);
    //maker.setBounds (560,10, 600, 700);
    //maker.setBounds (465,2, 520, 670); // demo mode
    lc.add(maker, JLayeredPane.PALETTE_LAYER);  
  }
 
  public static void main(String[] args) {
    JFrame frame = new JFrame("Expect Window Panel");
 
      frame.addWindowListener(new WindowAdapter() {
        public void windowClosing(WindowEvent e) {
                  System.exit(0);
        }
      });
      
      frame.getContentPane().add("Center", new ExpectWindowPanel());
      frame.setSize(1220, 900);
      //frame.setSize(1000, 750); // demo mode
      frame.setVisible(true);
    }


}
