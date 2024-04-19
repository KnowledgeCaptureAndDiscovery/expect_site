//
// Top-level class to start the PSMTool client
//

import javax.swing.*;
import javax.swing.text.*;
import java.awt.*;
import java.awt.event.*;

import java.io.*;
import java.util.*;

import Connection.*;

/* I need to break this into two separate classes, with their own
controls. This way it will be clearer how to use pieces of this stuff in
other systems.
 */

public class PSMTool extends JFrame {

  private JPanel buttonPanel = null;
  private PlanView planView = null;
  private CritiqueView critiqueView = null;
  public LispSocketAPI lc = null;

  private String hostName = "localhost";
  private String port = "5005";
  
  public PSMTool() {
    super("Plan evaluator");
    // The third argument being false skips the port dialog.
    lc = new LispSocketAPI(hostName, port);
    buildApp();
  }

  public PSMTool(String newPort) {
    super("Plan evaluator");
    port = newPort;
    // The third argument being false skips the port dialog.
    lc = new LispSocketAPI(hostName, port, false);
    buildApp();
  }

  void buildApp() {

    setFont(new Font("SansSerif", Font.PLAIN, 12));

    // Two panels arranged horizontally.
    //getContentPane().setLayout(new GridLayout(1,0));
    getContentPane().setLayout(new BoxLayout(getContentPane(), BoxLayout.X_AXIS));

    planView = new PlanView(lc);

    critiqueView = new CritiqueView(lc);

    // let the planview know about the critiqueView to send it commands.
    planView.critiqueView = critiqueView;  

    JSplitPane jsp = new JSplitPane();
    jsp.setLeftComponent(planView);
    jsp.setRightComponent(critiqueView);
    getContentPane().add(jsp);

    pack();
    setVisible(true);

    // Close up the main window nicely
    addWindowListener(new WindowAdapter() {
      public void windowClosing(WindowEvent e) {
        try {lc.close(); } catch (IOException ie) {}
        System.exit(0);
      }
    });

    // Compute the fields, values and whether any constraints are violated.
    planView.showPlan();

    // Run the critiquer to start off with some information.  This is
    // not done in the critiqueView panel startup itself since it can
    // take a while, so it should happen after the window is displayed.
    // critiqueView.run_critiquer();

  }

  public static void main(String[] args) {
    if (args.length > 0) {
      System.out.println("Port is " + args[0]);
      new PSMTool(args[0]);
    } else 
      new PSMTool();
  }
}
