//File: messagePanel.java
//
// Copyright (C) 1998 by Jihie Kim
// All Rights Reserved
//

package Tree;
import Connection.*;
import javax.swing.*;
import java.awt.event.*;
import java.awt.*;
import javax.swing.event.TreeSelectionListener;
import javax.swing.event.TreeSelectionEvent;
import experiment.*;
import MethodEditor;
import CritiqueWizard;
import InstanceEditor;
public class messagePanel extends JPanel {
  ExpectSocketAPI es;
  expandableTree tree;
  expandableTreeNode root;
  expandableTreeModel treeModel;
  JPanel mainPanel;
  
  JPanel buttons;
  private JButton MethodRelationErrorsButton;
  private JButton refreshButton;
  private JButton dismissButton;
  private String expectMessages = "";
  private String MethodRelationMessages = "";
  private JPanel MethodRelationPanel;
  private JTextArea ta;

  boolean useNLEditor = false;
  CritiqueWizard wizard = null;  
  String source;
  private messagePanel mp;
  public messagePanel(ExpectSocketAPI theServer,
		      CritiqueWizard w,
		      boolean useNL) {
    es = theServer;
    mp = this;
    useNLEditor = useNL;wizard = w;

    setLayout(new BorderLayout());
    //String xmlInput = es.getAllMessages();
    String xmlInput = es.getOrganizedErrorMessages();
    //System.out.println("xml message input:"+xmlInput+":");
    messageListRenderer mr = new messageListRenderer(xmlInput);
    root = mr.getMessagesAsTreeNode();
    treeModel = new expandableTreeModel(root);
    tree = new expandableTree(treeModel);
    tree.setCellRenderer(new messageListCellRenderer());
    expectMessages = mr.getMessagesAsString();
    //saveData.record("Agenda:"+expectMessages);

    JScrollPane scrollPane = new JScrollPane(tree);
    scrollPane.setPreferredSize(new Dimension(600,600));
    tree.expandTree();
    tree.addTreeSelectionListener(new messageNodeSelectListener());
    
    
    add("Center",scrollPane);
    
    buttons = new JPanel();
    dismissButton = new JButton ("Dismiss warning");
    dismissButton.addActionListener(new dismissListener());
    buttons.add(dismissButton);
    

    refreshButton = new JButton ("Refresh");
    refreshButton.addActionListener(new refreshListener());
    buttons.add(refreshButton);
    add("South",buttons);

  }

  /*  to separate method-relation errors from others
  public messagePanel(ExpectSocketAPI theServer) {
    es = theServer;
    mainPanel = new JPanel();
    String xmlInput = es.getOtherMessages();
    messageListRenderer mr = new messageListRenderer(xmlInput);

    expectMessages = mr.getMessagesAsString();
    saveData.record("Agenda:"+expectMessages);
    ta = new JTextArea(expectMessages,20,50);
    JScrollPane scrollPane = new JScrollPane(ta);
    
    mainPanel.add(scrollPane);
    add(mainPanel,BorderLayout.CENTER);
    
    MethodRelationErrorsButton = new JButton ("Show MethodRelation Errors");
    MethodRelationErrorsButton.addActionListener(new MethodRelationErrorsListener());
    add(MethodRelationErrorsButton,BorderLayout.SOUTH);
  }
  */

  class MethodRelationErrorsListener implements ActionListener {
    public void actionPerformed (ActionEvent e) {
      showMethodRelationErrors();
    }
  }

  private void showMethodRelationErrors() {
    String xmlInput = es.getMethodRelationMessages();
    messageListRenderer mr = new messageListRenderer(xmlInput);
    MethodRelationMessages = mr.getMessagesAsString();
    //ta.setText(MethodRelationMessages);
    JOptionPane.showMessageDialog(null, MethodRelationMessages);
  }
  class dismissListener implements ActionListener {
    public void actionPerformed (ActionEvent e) {
      dismiss();
    }
  }

  private void dismiss () {
    expandableTreeNode current = tree.getSelectedNode();
    if (current == null) {
      JOptionPane.showMessageDialog(null, "Please select a node first");
      return;
    }
    es.dismissAgendaItem((String) current.getID());
    refresh();
  }

  class refreshListener implements ActionListener {
    public void actionPerformed (ActionEvent e) {
      refresh();
    }
  }
  public void refresh() {
    removeAll();
    //String xmlInput = es.getOtherMessages();
    //String xmlInput = es.getAllMessages();
    String xmlInput = es.getOrganizedErrorMessages();
    messageListRenderer mr = new messageListRenderer(xmlInput);
    root = mr.getMessagesAsTreeNode();
    treeModel = new expandableTreeModel(root);
    tree = new expandableTree(treeModel);
    tree.setCellRenderer(new messageListCellRenderer());
    JScrollPane scrollPane = new JScrollPane(tree);
    tree.expandTree();
    tree.addTreeSelectionListener(new messageNodeSelectListener());

    //System.out.println(" new messages:"+mr.getMessagesAsString());
    //JTextArea ta = new JTextArea(mr.getMessagesAsString(),20,50);
    //JScrollPane scrollPane = new JScrollPane(ta);
    add("Center",scrollPane);
    add("South",buttons);
    updateUI();
    repaint();
  }

  class messageNodeSelectListener implements TreeSelectionListener {
    public void valueChanged(TreeSelectionEvent e) {
      expandableTreeNode current = tree.getSelectedNode();
      String content = (String) current.getUserObject();

      if (!content.startsWith("== ")) return;
      String id = (String) current.getID();
      String type = (String) current.getType();

      int result;
      if (type.equals("EDIT-METHOD"))
	result = JOptionPane.showConfirmDialog(null, "Do you want to modify the method?");
      else if (type.equals("CREATE-METHOD"))
	result = JOptionPane.showConfirmDialog(null, "Do you want to specify how?");
      else if (type.equals("EDIT-INSTANCE"))
	result = JOptionPane.showConfirmDialog(null, "Do you want to modify object:"+id+"?");
      else 
	result = -100;
      
      source = id;

      if (result == JOptionPane.YES_OPTION) {
	//System.out.println(" selected node:"+id);
	//System.out.println(" Edit "+ id+ " \n type:"+type);
	
	//commented by Mukta
	//if (type.equals("EDIT-METHOD") && useNLEditor) {
	
	//added by Mukta
	if (type.equals("EDIT-METHOD")){
	
	/*new MethodEditor(id, es) {
      public void respondToDone() {
	//wizard.editedMethod(currentName);
	dispose();
	es.postProcessNLEdit(id);
	NLEditPostProcess(this);

      }*/  
	  
	  
	  // commented by Mukta
	  new MethodEditor(id, es) {
	    public void respondToDone() {
	      if (wizard != null) {
		 wizard.editedMethod(source);
		 wizard.refreshPSTree();
	      }
	      dispose();
	      es.postProcessNLEdit(source);
	      mp.refresh();
	      
	    }
	  };
	  
	}
	else if (type.equals("EDIT-INSTANCE")) {
	  new InstanceEditor (es, id) {
	    public void respondToDone() {
	      mp.refresh();
	      if (wizard != null) wizard.refreshPSTree();
	    }
	  };
	}
	
	//commented by Mukta
	//else if (type.equals("CREATE-METHOD") && useNLEditor) {
	  
	  else if (type.equals("CREATE-METHOD")) {
	  String response = null;
	  response = es.createTemplateMethod(source);
	  if (response.indexOf("<response") >= 0) {
	    editResponseRenderer er = new editResponseRenderer (response);
	    String messages = er.getMessages();
	    source = er.getMethodName();
	    if (er.processedP()) {
	      new MethodEditor(id, es) {
		public void respondToDone() {
		  if (wizard != null) {
		    wizard.editedMethod(source);
		    wizard.refreshPSTree();
		    
		  }
		  dispose();
		  es.postProcessNLEdit(source);
		  mp.refresh();
		}
	      };
	    }
	  }
	  
	}
      }
      else if(result == JOptionPane.NO_OPTION)
	JOptionPane.showMessageDialog(null, "well, you may want to modify/add others then.");
    
    }
  }
  
  public static void main(String[] args) {
      JFrame frame = new JFrame("Acquisition Analyzer");
      ExpectSocketAPI es = new ExpectSocketAPI();
      frame.addWindowListener(new WindowAdapter() {
        public void windowClosing(WindowEvent e) {
                  System.exit(0);
        }
      });
      
      frame.getContentPane().add("Center", new messagePanel(es, null, false));
      frame.setSize(400, 400);
      frame.setVisible(true);
    }
 
}
