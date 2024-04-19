package Tree;

import java.awt.BorderLayout;
import java.awt.event.*;
import java.awt.GridLayout;
import java.awt.BorderLayout;
import javax.swing.JFrame;
import javax.swing.JPanel;
import javax.swing.JButton;
import javax.swing.JComponent;
import Connection.*;
import javax.swing.JOptionPane;
import experiment.*;
import editor.*;
import ExpectWindowPanel;
public class NLEditMethodFrame extends JFrame 
implements WindowListener, KeyListener{
  JButton doneButton;
  JButton cancelButton;
  JPanel buttons;
  ExpectSocketAPI thisServer;
  String type;
  String methodName;
  JComponent parent;
  String interfaceType;
  MethodEditor meditor;
  ExpectWindowPanel thePanel;
  public static void main(String[] args) {
    //ExpectSocketAPI server = new ExpectSocketAPI();
    //JFrame frame = new NLEditMethodFrame("Concept", "jjj", "(Defconcept jjj)");
  }


  public NLEditMethodFrame(String editType, String name, 
			   ExpectSocketAPI theServer,
			   JComponent caller,
			   ExpectWindowPanel rootPanel,
			   String itype, MethodEditor editorUsed) {
    
    super("Show - " + editType);
    thePanel = rootPanel;
    interfaceType = itype;
    methodName = name;
    parent = caller;
    type = editType;
    thisServer = theServer;
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
    else meditor = new MethodEditor(name,thisServer);
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
      String newDefinition = thisServer.postProcessNLEdit(methodName);
      //saveData.record(" done editing:"+newDefinition);
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

      //System.out.println("definition:"+newDefinition);
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
	  MethodEditor editorUsed = null;
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
