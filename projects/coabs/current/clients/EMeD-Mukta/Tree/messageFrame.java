//File: messageFrame.java
//
// Copyright (C) 2000 by Jihie Kim
// All Rights Reserved
//

package Tree;
import javax.swing.*;
import java.awt.event.*;
import Connection.*;
import MethodEditor;
import CritiqueWizard;

public class messageFrame extends JFrame {
  messagePanel p;
  public messageFrame(ExpectSocketAPI theServer,
		      CritiqueWizard w,
		      boolean useNL) {
    addWindowListener(new WindowAdapter() {
      public void windowClosing(WindowEvent e) {
	System.exit(0);
      }
    });
    p = new messagePanel(theServer, w, useNL);
    getContentPane().add("Center",p);
    setSize(500, 400);
    setVisible(true);
  }
  public void refresh () {
    p.refresh();
  }
}
