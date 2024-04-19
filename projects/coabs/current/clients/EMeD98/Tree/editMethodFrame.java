package Tree;

import java.awt.BorderLayout;
import java.awt.TextArea;
import java.awt.event.ActionListener;
import java.awt.event.ActionEvent;
import java.awt.event.KeyListener;
import java.awt.event.KeyEvent;
import java.awt.event.WindowListener;
import java.awt.event.WindowEvent;
import java.awt.GridLayout;
import java.awt.BorderLayout;
import com.sun.java.swing.JFrame;
import com.sun.java.swing.JPanel;
import com.sun.java.swing.JButton;
import com.sun.java.swing.JComponent;
import Connection.ExpectServer;
import com.sun.java.swing.JOptionPane;
import experiment.*;
import editor.*;
import ExpectWindowPanel;
public class editMethodFrame extends JFrame 
implements WindowListener, KeyListener{
  TextArea textArea = new TextArea();
  JButton doneButton;
  JButton cancelButton;
  JPanel buttons;
  ExpectServer thisServer;
  String type;
  String[]      confirm = {"OK"};
  JComponent parent;
  String interfaceType;
  MEditor meditor;
  ExpectWindowPanel thePanel;
  public static void main(String[] args) {
    //ExpectServer server = new ExpectServer();
    //JFrame frame = new editMethodFrame("Concept", "jjj", "(Defconcept jjj)");
  }


  public editMethodFrame(String editType, String name, 
		     String initText, ExpectServer theServer,
		     JComponent caller,
		     ExpectWindowPanel rootPanel,
		     String itype, MEditor editorUsed,
		     String result) {

    super("Show - " + editType);
    thePanel = rootPanel;
    System.out.println("edit :"+initText);
    interfaceType = itype;
    parent = caller;
    type = editType;
    thisServer = theServer;
    textArea.setText(initText);
    textArea.addKeyListener(this);
    doneButton = new JButton("done editing");
    cancelButton = new JButton("cancel");
    
    doneButton.addActionListener(new doneEditListener());
    cancelButton.addActionListener(new cancelListener());
    buttons = new JPanel();//new GridLayout(1,0));
    buttons.add(cancelButton);
    buttons.add(doneButton);

    getContentPane().setLayout(new BorderLayout());
    if (editType.equals("Modify and Create")) {
      meditor = editorUsed;
      if (meditor == null) {
	System.out.println("*** CRITICAL ERROR::cannot find edited method window");
	return;
      }
    }
    else meditor = new MEditor(editType,thisServer, this, 
			 thePanel, name, initText, result);
    getContentPane().add("Center", meditor);
    getContentPane().add("South",buttons);
    addWindowListener(this);
    setSize(700,700);
    setLocation(150,0);
    setVisible(true);
    
  }
  
  class doneEditListener implements ActionListener {
    public void actionPerformed(ActionEvent e) {   
      setVisible(false);
      String response = null;
      String newDefinition = meditor.getDesc();
      saveData.record(" From sketch:"+meditor.getSketch());
      saveData.record(" done editing:"+newDefinition);
      if (interfaceType.equals("small")) {
	response = thisServer.editMethod(newDefinition);
      }
      else if (type.equals("Create") || 
	     type.equals("Modify and Create"))
	response = thisServer.checkAndCreateMethod(newDefinition);
      else if (type.equals("CopyAndCreate")) 
	response = thisServer.checkAndCreateMethod(newDefinition);
      else if (type.equals("Modify")) 
	response = thisServer.checkAndModifyMethod(newDefinition);

      System.out.println("definition:"+newDefinition);
      System.out.println("edit response:"+response);


      if (parent != null) {
	
	if (interfaceType.equals("small")) {
	  if (response.startsWith("OK")) {
	    String mname = response.substring(3).trim();
	     System.out.println(" method name:"+mname);
	    ((methodListPanel) parent).editPostProcess(mname,
					       newDefinition,
					       true,
					       "", null);
	  }
	}
	else if (response.indexOf("<response") >= 0) {
	  editResponseRenderer er = new editResponseRenderer (response);
	  String methodName = er.getMethodName();
	  String messages = er.getMessages();
	  MEditor editorUsed = null;
	  if (!er.processedP()) editorUsed = meditor;
	  ((methodListPanel) parent).editPostProcess(methodName, 
					     newDefinition, 
					     er.processedP(),
					     messages,
					     editorUsed);
	
	}
	else ((methodListPanel) parent).showMessage(response);
	  
      }
      

    }
  }

  class cancelListener implements ActionListener {
    public void actionPerformed(ActionEvent e) {   
      setVisible(false);
      dispose();
    }
  }


  public void windowClosed(WindowEvent event){}
  public void windowDeiconified(WindowEvent event){}
  public void windowIconified(WindowEvent event){}
  public void windowActivated(WindowEvent event){}
  public void windowDeactivated(WindowEvent event){}
  public void windowOpened(WindowEvent event){}
  
  public void windowClosing(WindowEvent event)
  {  
    setVisible(false);
    dispose();
  }

  public void keyTyped(KeyEvent e)
  {
  }

  public void keyPressed(KeyEvent e)
  {
  }

  public void keyReleased(KeyEvent e)
  {
  }
}
