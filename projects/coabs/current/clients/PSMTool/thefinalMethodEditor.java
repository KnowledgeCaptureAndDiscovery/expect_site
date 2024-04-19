
//
// Top-level class for a method editor
//

// Jim, Dec 2000: made the highlighting colour blue, and added a style
// to the capability area for errors to be red.


import javax.swing.*;
import javax.swing.text.*;
import javax.swing.event.*;
import javax.swing.tree.*;
import java.awt.*;
import java.awt.event.*;

import java.io.*;
import java.util.*;

import Connection.*;

public class MethodEditor extends JFrame {

  public LispSocketAPI lc = null;
  
  // By default you can edit the capability as well as the method. Set
  // this false for a more constrained editor (see WizardMethodLine).
  public boolean editCapability = true;

  private StyleContext sc;
  private Style replaceHighlight, withHighlight;
  private ActiveText capArea = null; //, bodyArea = null;
  private AltNode altTop = null;
  private JTree bodyArea = null;
  private DefaultTreeModel treeModel;
  private JTextField oldField = null, newField = null, searchField = null;
  
  private LayedData treeNL = null, oldObj = null, newObj = null;
  private String methodName = null;
  // errorMessages is the vector of strings for the error messages
  private Vector errorMessages = null, 
    // errorCodeIndices is a vector that parallels errorMessages with
    // the layed data for the code fragment that the error refers to.
    errorCodeIndices = null;
  private int numErrors = 0;
  
  private MethodEditor self;
  
  private static final int SELECTING_OLD = 1;
  private static final int SELECTING_NEW = 2;
  private int state = SELECTING_OLD;
  
  // This added when I used the StylePad example.
  Hashtable runAttr;
  
  public MethodEditor(String passed_methodName, LispSocketAPI passed_lc) {
    super("Method Editor");
        
    lc = passed_lc;
    methodName = passed_methodName;

    makeEditor();
  }

    public MethodEditor(String passed_methodName, LispSocketAPI passed_lc, boolean mainWindow) {
        super("Method Editor");
        
        lc = passed_lc;
        methodName = passed_methodName;

        makeEditor();

        // Close up on window closing if this is the main window.
        if (mainWindow == true) {
	  addWindowListener(new WindowAdapter() {
	      public void windowClosing(WindowEvent e) {
		try {lc.close(); } catch (IOException ie) {}
		System.exit(0);
	      }
	  //}
	  
	  public void windowDeiconified(WindowEvent e) {
        //System.out.println("iconified");
        //System.exit(0);
        //donePane
        pack();
    }
    });
       //} 
        }
    }

    // I use this class to store the information at the nodes in the
    // alternatives tree.
    public class AltNode extends DefaultMutableTreeNode {
      public String text = null;  // English text
      public String path = null; // a string of numbers for the path.
      public boolean isHeader = false;  // A header is the title for a group.
      public boolean highlighted = false; //set by search, used in rendering.
      public boolean newRelation = false; // whether to create a new role.
      public boolean newObject = false;  // there's surely a more elegant way
      public boolean modList = false; // sigh.
      public boolean isErrorMessage = false;
      public LayedData errorSubject = null;
      public String newDomain = "";
      public String newRange = "";
      public String newObjectType = "";
      
      
      public AltNode (String ptext, String ppath, boolean pisHeader) {
        super(ptext);	  // make the text be the user object.
        text = ptext;
        path = ppath;
        isHeader = pisHeader;
      }
    }
  

    public void makeEditor() {

        self = this;

        sc = new StyleContext();
        runAttr = new Hashtable();

        getContentPane().setLayout(new BoxLayout(getContentPane(), BoxLayout.Y_AXIS));
        
        JPanel donePane = new JPanel();
        //original //
        //donePane.setLayout(new FlowLayout(FlowLayout.LEFT));
        donePane.setLayout(null);
        
        
        
        
        //donePane.add(Box.createHorizontalGlue());
        JButton doneBut = new JButton("done");
        doneBut.setBounds(60,10,80,25);
        doneBut.addActionListener(new ActionListener() {
	    
	public void actionPerformed(ActionEvent e) {
	  Cursor oldCursor = getCursor();
	  setCursor(Cursor.getPredefinedCursor(Cursor.WAIT_CURSOR));
	  lc.sendLispCommand("(expect::english-editor-commit)");
	  lc.safeReadLine();
	  self.respondToDone();  // see comments with this method definition
	  setCursor(oldCursor);
	}
        });
        //add(doneBut);
        donePane.add(doneBut);
       
        JButton cancelBut = new JButton("cancel");
        cancelBut.setBounds(160,10,80,25);
        cancelBut.addActionListener(new ActionListener() {
	  
	  public void actionPerformed(ActionEvent e) {
	    self.dispose();
	  }
        });
        //donePane.add(Box.createRigidArea(new Dimension(5, 0)));
        donePane.add(cancelBut);
        //donePane.add(Box.createRigidArea(new Dimension(5, 0)));
        JButton applyBut = new JButton("apply");
        applyBut.setBounds(260,10,80,25);
        applyBut.addActionListener(new ActionListener() {
	
	public void actionPerformed(ActionEvent e) {
	  new MethodApplier(methodName, lc);
	}
        });
        // Leave this out of the delivery version until it is more stable.
        
        
        
        //donePane.add(Box.createRigidArea(new Dimension(5, 0)));
        donePane.add(applyBut);
        donePane.setPreferredSize(new Dimension(500, 40));
        donePane.setMaximumSize(new Dimension(500, 40));
        
        
        getContentPane().add(donePane);
        //donePane.setSize(100,100);
        
        capArea = new CapText(sc);
        JScrollPane capScrollPane = new JScrollPane(capArea);
        capScrollPane.setVerticalScrollBarPolicy(JScrollPane.VERTICAL_SCROLLBAR_ALWAYS);
        capScrollPane.setPreferredSize(new Dimension(1500,150));
        capScrollPane.setMaximumSize(new Dimension(1500,150));

        getContentPane().add(capScrollPane);

        JPanel oldTextPane = new JPanel();
        //oldTextPane.setLayout(new FlowLayout(FlowLayout.LEFT));
        oldTextPane.setLayout(null);
        JLabel oldLabel = new JLabel("Replace");
        oldLabel.setBounds(0,20,80,25);
        oldTextPane.add(oldLabel);
        
        oldField = new JTextField(40);
        oldField.setBounds(80,25,400,25);
        oldField.setForeground(Color.blue);
        oldTextPane.add(oldField);
        JLabel newLabel = new JLabel("With");
        newLabel.setSize(oldLabel.getSize());
        newLabel.setBounds(0,60,80,25);
        oldTextPane.add(newLabel);
        newField = new JTextField(40);
        newField.setBounds(80,60,400,25);
        newField.setForeground(Color.green);
        oldTextPane.add(newField);
        oldTextPane.setPreferredSize(new Dimension(500, 100));
        oldTextPane.setMaximumSize(new Dimension(500, 100));
        getContentPane().add(oldTextPane);
        
       JPanel newTextPane = new JPanel();
        //newTextPane.setLayout(new FlowLayout(FlowLayout.LEFT));
        /*newTextPane.setLayout(null);
        JLabel newLabel = new JLabel("With");
        newLabel.setSize(oldLabel.getSize());
        newLabel.setBounds(0,60,80,25);
        newTextPane.add(newLabel);
        
        newField = new JTextField(40);
        newField.setBounds(80,60,400,25);
        newField.setForeground(Color.green);
        newTextPane.add(newField);
        oldTextPane.setPreferredSize(new Dimension(500, 100));
        oldTextPane.setMaximumSize(new Dimension(500, 100));
        getContentPane().add(newTextPane);*/

        JPanel butPane = new JPanel();
        //butPane.setLayout(new FlowLayout(FlowLayout.LEFT));
        butPane.setLayout(null);
        JButton updateBut = new JButton("Update");
        updateBut.setBounds(0,40,80,25);
        updateBut.addActionListener(new ActionListener() {
	public void actionPerformed(ActionEvent e) {
	  System.out.println("Updating with " + newField.getText());
	  if (//bodyArea.selected != null &&
	      bodyArea.getSelectionPath() != null) {
	    AltNode dt = (AltNode)
	      bodyArea.getLastSelectedPathComponent();
	    if (//newField.getText().equals(bodyArea.selected.deepText()) == true
	        newField.getText().equals(dt.text) == true) {
	      readMethod("(let ((*package* \"EXPECT\")) (expect::tcl-update '" + oldObj.name + " nil '(" + // bodyArea.selected.name + " '" + bodyArea.selected.index + "))");
		       dt.path + ")))");
	    }
	  } else if (newObj != null && 
		   newField.getText().equals(newObj.deepText()) == true) {  
	    // perhaps the field comes from the body
	    readMethod("(let ((*package* \"EXPECT\")) (expect::tcl-update " 
+ oldObj.name + " " + newObj.name + " nil))");
	  } else if (newField.getText() != null) {
	    // Something was typed in the "with" field. Send it as a
	    // string in case lisp cannot parse it as an object.
	    readMethod("(let ((*package* \"EXPECT\")) (expect::tcl-update '" + oldObj.name + " nil nil \"" + newField.getText() + "\"))");
	  }
	  if (newField.getText() != null) {
	    setState(SELECTING_OLD);
	  }
	  displayMethod();
	}
        });
        JButton undoBut = new JButton("Undo");
        undoBut.setBounds(100,40,80,25);
        undoBut.addActionListener(new ActionListener() {
	  public void actionPerformed(ActionEvent e) {
	      readMethod("(let ((*package* \"EXPECT\")) (expect::tcl-undo))");
	      setState(SELECTING_OLD);
	      displayMethod();
	  }
        });
        butPane.add(undoBut);
        butPane.add(updateBut);
        JButton clearBut = new JButton("Clear");
        clearBut.setBounds(200,40,80,25);
        clearBut.addActionListener(new ActionListener() {
	  public void actionPerformed(ActionEvent e) {
	      setState(SELECTING_OLD);
	  }
        });
        butPane.add(clearBut);

        JLabel searchLabel = new JLabel("Search for:");
        searchLabel.setBounds(100,40,80,25);
        butPane.add(searchLabel);

        searchField = new JTextField(20);
        searchField.setBounds(420,40,150,25);
        
         searchField.addKeyListener(new KeyAdapter() {
	  public void keyTyped(KeyEvent e) {
	      if (e.getKeyChar() == '\n' || e.getKeyChar() == '\r') {
		// bodyAread.higlight..
		self.highlightMatches(searchField.getText());
		//self.searchForTerms(searchField.getText());
	      }
	  }
        });
        butPane.add(searchField);

        JButton searchBut = new JButton("Search");
        searchBut.setBounds(300,40,100,25); 
        searchBut.addActionListener(new ActionListener() {
	  public void actionPerformed(ActionEvent e) {
	      // bodyArea.highlight..
	      //self.highlightMatches(searchField.getText());
	      self.searchForTerms(searchField.getText());
	  }
        });
        butPane.add(searchBut);


        JButton nextBut = new JButton("Next");
        nextBut.setBounds(590,40,80,25);
        nextBut.addActionListener(new ActionListener() {
	  public void actionPerformed(ActionEvent e) {
	      AltNode selectedNode = null; // if a highlighted node is currently selected.
	      if (bodyArea.getSelectionPath() != null) {
		selectedNode = (AltNode)bodyArea.getLastSelectedPathComponent();
		if (selectedNode.highlighted == false)
		    selectedNode = null;
	      }
	      // First step past the current node, then look for the
	      // next highlighted node. If nothing found, after,
	      // return the first node found.
	      AltNode firstMatch = null;
	      boolean pastSelected = false, found = false;
	      AltNode currentNode = null;
	      for(Enumeration en = altTop.depthFirstEnumeration();
		found == false && en.hasMoreElements();) {
		currentNode = (AltNode)en.nextElement();
		if (currentNode.highlighted == true) {
		    if (firstMatch == null)
		        firstMatch = currentNode;
		    if (selectedNode == null || pastSelected == true)
		        found = true;
		}
		if (currentNode == selectedNode)
		    pastSelected = true;
	      }
	      if (found == false && firstMatch != null) {
		found = true;
		currentNode = firstMatch;
	      }
	      if (found == true) {
		TreePath currentPath = new TreePath(currentNode.getPath());
		bodyArea.setSelectionPath(currentPath);
		bodyArea.scrollPathToVisible(currentPath);
	      }
	  }
        });
        butPane.add(nextBut);
        butPane.setPreferredSize(new Dimension(700, 80));
        butPane.setMaximumSize(new Dimension(700, 80));
        getContentPane().add(butPane);

        /* bodyArea = new ActiveText(sc) {
	  public void actionPerformed(MouseEvent e) {
	      if (state == SELECTING_NEW) {
		newField.setText(selected.deepText());
	      }
	  }
        }; */
        altTop = new AltNode("Alternatives                              ", " ", true);
        treeModel = new DefaultTreeModel(altTop);
        bodyArea = new JTree(treeModel);
        bodyArea.getSelectionModel().setSelectionMode
	  (TreeSelectionModel.SINGLE_TREE_SELECTION);
        bodyArea.addTreeSelectionListener(new TreeSelectionListener() {
	  public void valueChanged(TreeSelectionEvent e) {
	      AltNode n = (AltNode) bodyArea.getLastSelectedPathComponent();
	      if (n == null) return;
	      if (n.newRelation == true) {
		// Need to make sure the relation gets added
		// automatically to the alternatives and selected.
		new RelationEditor(lc, n.newDomain, n.newRange) {
		    public void respondToDone() {
		        TreePath tp = bodyArea.getLeadSelectionPath();
		        AltNode top = (AltNode)tp.getParentPath().getParentPath().getLastPathComponent();
		        addAlternatives
			  (top, "(expect::print-alts-for-alternative '("
			   + top.path + "))");
		    }
		};
	      } else if (n.newObject == true) {
		new InstanceEditor(lc, n.newObjectType){
		    public void respondToDone() {
		        TreePath tp = bodyArea.getLeadSelectionPath();
		        AltNode top = (AltNode)tp.getParentPath().getParentPath().getLastPathComponent();
		        if (top != null)
			  addAlternatives
			      (top, "(expect::print-alts-for-alternative '("
			       + top.path + "))");
		    }
		};
	      } else if (n.modList == true) {
	        lc.sendLispCommand("(expect::send-possible-fillers-of-list "
                                     + oldObj.name + ")");
	        Vector choices = new Vector();
	        String line = lc.safeReadLine();
	        while (line != null && line.equals("done") == false) {
		choices.add(line);
		line = lc.safeReadLine();
	        }
	        lc.safeReadLine(); // consume the function return value.
	        lc.sendLispCommand("(expect::send-items-in-list "
                                     + oldObj.name + ")");
	        Vector items = new Vector();
	        line = lc.safeReadLine();
	        while (line != null && line.equals("done") == false) {
		items.add(line);
		line = lc.safeReadLine();
	        }
	        lc.safeReadLine(); // consume the function return value.
	        new ListBuilder(items, choices) {
		public void performDone() {
		  // unselect the node so that the editor will react as
		  // though the text was typed.
		  bodyArea.removeSelectionPath
		    (bodyArea.getSelectionPath());
		  newField.setText(listText.getText());
		}
	        };
	      } else if (n.isErrorMessage == true) {
	        // If the user clicks on an error message, start
	        // replacing the code that the message refers to.
	        oldField.setText(n.errorSubject.deepText());
	        oldObj = n.errorSubject;
	        addAlternatives(n, 
			    "(expect::print-alts-for-error-item "
                                  + n.path + ")");
	      } else if (n.isHeader == false) {
		newField.setText(n.text);
		String command = "(expect::print-alts-for-alternative '("
		    + n.path + "))";
		addAlternatives(n, command);
	      }
	  }
        });
        bodyArea.setCellRenderer(new AltCellRenderer());
        JScrollPane bodyScrollPane = new JScrollPane(bodyArea);
        bodyScrollPane.setVerticalScrollBarPolicy(JScrollPane.VERTICAL_SCROLLBAR_ALWAYS);
        bodyScrollPane.setPreferredSize(new Dimension(500,400));

        getContentPane().add(bodyScrollPane);

        // null and "" are probably the same, but I'm not sure.
        if (methodName == "" || methodName == null) {
	  JButton choose = new JButton("Choose method: ");
	  choose.addActionListener(new ActionListener() {
	      public void actionPerformed(ActionEvent e) {
		new planReader(lc, self);
	      }});
	  butPane.add(choose);
        } else {
	  readAndDisplayMethod();
        }

        // added on top of the normal and highlighted styles that come
        // with ActiveText.
        Style heading = sc.addStyle("bold", capArea.normalStyle);
        StyleConstants.setBold(heading, true);

        replaceHighlight = capArea.highlightStyle;

        // Highlighted to replace something with (secondary highlight style).
        withHighlight = sc.addStyle("with", capArea.highlightStyle);
        StyleConstants.setForeground(withHighlight, Color.green);
        setSize(1000,1000);
        donePane.revalidate();
        donePane.repaint();
        capScrollPane.revalidate();
        capScrollPane.repaint();
        oldTextPane.revalidate();
        oldTextPane.repaint();
        
        newTextPane.revalidate();
        newTextPane.repaint();
        butPane.revalidate();
        butPane.repaint();
        //revalidate();
        //repaint();
        setVisible(true);
    }

  public void setState (int newState) {
    if (newState == SELECTING_OLD) {
      capArea.removeSelection();
      //bodyArea.removeSelection();
      //bodyArea.setText("");
      //bodyArea.lData = null;
      altTop.removeAllChildren();// seems to work here, but not for other nodes
      newObj = null;
      treeModel.reload();
      AltNode e = null;
      for (int i = 0; i < numErrors; i++) {
        LayedData subject = (LayedData)errorCodeIndices.elementAt(i);
        e = new AltNode((String)errorMessages.elementAt(i), 
		    subject.name, true);
        e.isErrorMessage = true;
        e.errorSubject = subject;
        treeModel.insertNodeInto(e, altTop, altTop.getChildCount());
      }
      if (numErrors == 0) {
        altTop.setUserObject("There are no problems with this definition");
      } else {
        //altTop.setUserObject("Problems:                                 ");
        altTop.setUserObject("Suggestions for what to do next:          ");
        bodyArea.scrollPathToVisible(new TreePath(e.getPath()));
      }
      oldField.setText("");
      newField.setText("");
      capArea.highlightStyle = replaceHighlight;
      //bodyArea.highlightStyle = replaceHighlight;
      state = SELECTING_OLD;
    } else if (newState == SELECTING_NEW) {
      //bodyArea.highlightStyle = withHighlight;
      altTop.setUserObject("Alternatives");
      capArea.highlightStyle = withHighlight;
      state = SELECTING_NEW;
    }
  }

    class planReader extends JFrame implements ListSelectionListener {
        private MethodEditor superEd;
        private Vector plans;
        public planReader(LispSocketAPI lc, MethodEditor me) {
	  superEd = me;
	  lc.sendLispCommand("(expect::tcl-show-methods)");
	  plans = lc.readList();
	  JList methods = new JList(plans);
	  methods.setSelectionMode(ListSelectionModel.SINGLE_SELECTION);
	  CBRenderer renderer = new CBRenderer();
	  methods.setCellRenderer(renderer);
	  methods.addListSelectionListener(this);
	  getContentPane().add(methods);
	  pack();
	  setVisible(true);
        }

        public void valueChanged(ListSelectionEvent e) {
	  JList jl = (JList) e.getSource();
	  Vector plan = (Vector) plans.elementAt(jl.getSelectedIndex());
	  methodName = (String) plan.elementAt(2);
	  superEd.readAndDisplayMethod();
        }
    }
	
    class CBRenderer extends JLabel
        implements ListCellRenderer {
        public CBRenderer() {
	  setOpaque(true);
	  setHorizontalAlignment(CENTER);
	  setVerticalAlignment(CENTER);
        }
        public Component getListCellRendererComponent(
					    JList list,
					    Object value,
					    int index,
					    boolean isSelected,
					    boolean cellHasFocus)
        {
	  if (isSelected) {
	      setBackground(list.getSelectionBackground());
	      setForeground(list.getSelectionForeground());
	  } else {
	      setBackground(list.getBackground());
	      setForeground(list.getForeground());
	  }
	  setText((String)((Vector)value).elementAt(2));
	  return this;
        }
    }   

  public void readMethod(String command) {
    lc.sendLispCommand(command);
    Vector indexedNL = lc.readList();
    
    numErrors = 0;
    errorMessages = new Vector();
    errorCodeIndices = new Vector();

    // Currently all lists have length 1, extra nesting added by the
    // new server.
    indexedNL = (Vector)indexedNL.elementAt(0);
    System.out.println("Read: " + indexedNL);
    
    // Hack to make treeNL an overall object that points to both
    // pieces of linked text.
    treeNL = new LayedData(0);
    treeNL.children = new Vector();
    Vector subNL = (Vector) indexedNL.elementAt(1);
    LayedData capabilityData = makeTreeNL((Vector)subNL.elementAt(1),
				  capArea.normalStyle);
    // Make it impossible to change the capability if this is specified
    // in the method editor.
    capabilityData.setActive(editCapability);
    treeNL.children.addElement(capabilityData);
    subNL = (Vector) indexedNL.elementAt(2);
    LayedData bodyData = makeTreeNL((Vector)subNL.elementAt(1),
			      capArea.normalStyle);
    treeNL.children.addElement(bodyData);
    subNL = (Vector) indexedNL.elementAt(3);
    // If the result type is a constant, the list has an extra
    // element indicating this. If not, add the result type as a child.
    if (subNL.size() == 2) {
      LayedData resultData = makeTreeNL((Vector)subNL.elementAt(1),
				capArea.normalStyle);
      resultData.setActive(false);
      treeNL.children.addElement(resultData);
    }
    
    // install the LayedData in the capability active text object
    capArea.lData = treeNL;
  }
  
  public void readAndDisplayMethod(String name) {
    methodName = name;
    readAndDisplayMethod();
  }
  
  public void readAndDisplayMethod() {
    readMethod("(let ((*package* (find-package \"EXPECT\"))) (expect::tcl-display-method-text '" + methodName + "))");
    displayMethod();
  }

  public void displayMethod() {
    Document doc = capArea.getDocument();
    
    try {
      Vector kids = treeNL.children;
      doc.remove(0, doc.getLength());
      doc.insertString(doc.getLength(), "In order to",
		   capArea.sc.getStyle("bold"));
      capArea.displayLayedData((LayedData)kids.elementAt(0));
      doc.insertString(doc.getLength(), "\n\n", capArea.normalStyle);
      capArea.displayLayedData((LayedData)kids.elementAt(1));
      // readMethod only adds this element if it is not a constant.
      if (kids.size() > 2) {
        //doc.insertString(doc.getLength(), "\n\n(Returning ",
		     //capArea.normalStyle);
        doc.insertString(doc.getLength(), "\n\n(Returning ",
		     capArea.sc.getStyle("bold"));
        capArea.displayLayedData((LayedData)kids.elementAt(2));
        doc.insertString(doc.getLength(), ")",
		     capArea.normalStyle);
      }
    } catch (BadLocationException ble) {
      System.err.println("Couldn't display initial text in method editor");
    }
  }
  
  // Parse the 4-element list structure of lisp's linked text into LayedData.
  public LayedData makeTreeNL(Vector linkedNL, Style style) {
    LayedData res = new LayedData();
    
    res.normalStyle = style;
    Vector english = (Vector)linkedNL.elementAt(0);
    if (english.size() > 0) {
      res.text = (String)english.elementAt(0);
    }
    res.name = (String)linkedNL.elementAt(2);
    // Process any error info.
    if (linkedNL.size() > 4) {
      System.out.println("Errors for " + res.name + ": " 
		     + linkedNL.elementAt(4));
      // If there is a problem other than with the children, make the
      // default style for this piece of text be the error style.
      Vector problems = (Vector)linkedNL.elementAt(4);
      for (int i = 0; i < problems.size(); i++) {
        Vector problem = (Vector)problems.elementAt(i);
        String pname = (String)problem.elementAt(0);
        if (pname.equals(":BAD-CHILDREN") == false) {
	res.normalStyle = capArea.errorStyle;  // red.
	Vector probEng = (Vector)problem.elementAt(1);
	errorMessages.addElement((String)probEng.elementAt(0));
	errorCodeIndices.addElement(res);
	numErrors++;
        }
      }
    }
    // build the children
    if (linkedNL.elementAt(3).equals("NIL") == false) {	// always true now
      Vector lkids = (Vector)linkedNL.elementAt(3);
      res.children = new Vector();
      for(int i = 0; i < lkids.size(); i++) {
        res.children.addElement(makeTreeNL((Vector)lkids.elementAt(i),
				   res.normalStyle));
      }
    }
    return res;
  }

  // Specialise action in the active text for the capability.
  public class CapText extends ActiveText {
    
    public CapText(StyleContext sc) {
      super(sc);
    }

    public void actionPerformed(MouseEvent e) {
      if (state == SELECTING_OLD) {
        oldField.setText(selected.deepText());
        oldObj = selected;
        addAlternatives(altTop,
		    "(expect::print-alts-for-index " + selected.name + ")");
      } else if (state == SELECTING_NEW) {
        newField.setText(selected.deepText());
        newObj = selected;
      }
    }
  }
  
  public void addAlternatives(AltNode topNode, String command) {
    String line;
    //Document doc = bodyArea.getDocument();
    //bodyArea.lData = new LayedData();
    //Style boldStyle = bodyArea.sc.getStyle("bold");
    AltNode category = null;
    int group, alt;

    // The path needs to be annotated if this node is an error message
    String topPath = topNode.path;
    if (topNode.isErrorMessage == true)
      topPath = "(:error " + topNode.path + ")";
    
    while (treeModel.getChildCount(topNode) > 0)
      treeModel.removeNodeFromParent((AltNode)treeModel.getChild(topNode, 0));
    Cursor oldCursor = getCursor();
    setCursor(Cursor.getPredefinedCursor(Cursor.WAIT_CURSOR));
    lc.sendLispCommand(command);
    // try {
    // doc.remove(0, doc.getLength());
    line = lc.safeReadLine();
    group = -1; alt = 0;
    while(line.equals("done") == false) {
      Vector data = lc.readList(line);
      if (data.elementAt(0).equals("ALT-TYPE") == true) {
        /* LayedData header = 
	 new LayedData("\n" + (String) data.elementAt(1) + "\n");
	 header.normalStyle = boldStyle;
	 header.active = false;
	 bodyArea.lData.addChild(header);
	 */
        // First, make the children of the previous category
        // visible if there are four or fewer (somewhat arbitrary)
        if (group > -1 && category.getChildCount() < 5 &&
	  category.getChildCount() > 0) {
	bodyArea.scrollPathToVisible(new TreePath(((AltNode)category.getFirstChild()).getPath()));
        }
        // Then move on to the new category.
        group++;
        alt = 0;
        category = new AltNode((String)data.elementAt(1), 
			 topPath + " " + group + " ",
			 true);
        treeModel.insertNodeInto(category, topNode, 
			   topNode.getChildCount());
        if (group == 0) 
	bodyArea.scrollPathToVisible(new TreePath(category.getPath()));
      } else {
        if (data.elementAt(0).equals("NIL") == false &&
	  ((Vector)data.elementAt(0)).size() > 0) {
	//LayedData child = bodyArea.lData.addChild((String)((Vector)data.elementAt(0)).elementAt(0));
	//child.index = alt++;
	//child.name = "" + group;
	AltNode child =
	  new AltNode((String)((Vector)data.elementAt(0)).elementAt(0), 
		    category.path + " " + alt++ + " ",
		    false);
	try {
	  if (data.size() > 1 &&
	      ((Vector)data.elementAt(1)).size() > 0) {
	    String token = (String)((Vector)data.elementAt(1)).elementAt(0);
	    if (token.equals(":NEW-RELATION") == true) {
	      child.newRelation = true;
	      child.newDomain = (String)((Vector)data.elementAt(1)).elementAt(2);
	      child.newRange = (String)((Vector)data.elementAt(1)).elementAt(3);
	    } else if (token.equals(":NEW-OBJECT") == true) {
	      child.newObject = true;
	      child.newObjectType = (String)((Vector)data.elementAt(1)).elementAt(2);
	    } else if (token.equals(":MODIFY-LIST") == true) {
	      child.modList = true;
	    }
	  }
	} catch (ClassCastException cce) {} // if it's not a vector
	treeModel.insertNodeInto(child, category, 
			     category.getChildCount());
        }
      }
      line = lc.safeReadLine();
    }
    lc.safeReadLine();   // Consume the function return.
    setCursor(oldCursor);
    // bodyArea.displayLayedData();
    // } catch (BadLocationException ble) {}
    // Make the children visible if there is only one cateogory
    if (topNode.getChildCount() == 1)
      bodyArea.expandPath(new TreePath(((AltNode)topNode.getFirstChild()).getPath()));
    setState(SELECTING_NEW);
  }

    public void highlightMatches(String matchText) {
        boolean found = false;
        matchText = matchText.toLowerCase();  // use lower case for search
        for(Enumeration e = altTop.depthFirstEnumeration(); 
	  e.hasMoreElements();) {
	  AltNode dt = (AltNode)e.nextElement();
	  if (dt.text.toLowerCase().indexOf(matchText) > -1) {
	      dt.highlighted = true;
	      // make the first match visible.
	      if (found == false) {
		found = true;
		bodyArea.scrollPathToVisible(new TreePath(dt.getPath()));
	      }
	  } else {
	      dt.highlighted = false;
	  }
        }
        bodyArea.repaint(bodyArea.getBounds(null));
    }

    public void searchForTerms(String matchText) {
        addAlternatives(altTop, 
		    "(expect::print-alts-matching-string \"" + matchText + "\")");
    }

    private class AltCellRenderer extends DefaultTreeCellRenderer {
        public Component getTreeCellRendererComponent(
		        JTree tree, Object value, boolean sel,
                            boolean expanded, boolean leaf, int row,
                            boolean hasFocus) {
            super.getTreeCellRendererComponent(
                            tree, value, sel,
                            expanded, leaf, row,
                            hasFocus);
	  AltNode dt = (AltNode)value;
	  // Make the font red if this node should be highlighted.
            if (dt.highlighted == true) {
                setForeground(Color.blue);
            }
            return this;
        }
    }

  // If the user clicks on a field and the PlanView knows about this
  // editor, this method gets called.
  public void setNameFieldPanel(NameFieldPanel sel) {
    newField.setText("Info element: " + sel.longName);
  }

    // This method can be specialized to alter the behaviour of the
    // method editor when the user clicks "done". Note that the normal
    // behavour still happens as well if you specialize this, you just
    // get to add more actions. See the critique wizard's
    // WizardMethodLine for an example of using this.
    public void respondToDone() {
    }

    public static void main(String[] args) {
        LispSocketAPI mainlc = new LispSocketAPI("camelot.isi.edu", "5679");
        String methodName = "";
        System.out.println(args.length + " args:");
        for(int i = 0; i < args.length; i++)
	  System.out.println(i + ": " + args[i]);
        if (args.length > 0) {
	  methodName = args[0];
        }
        MethodEditor me = new MethodEditor(methodName, mainlc, true);
    }

}

