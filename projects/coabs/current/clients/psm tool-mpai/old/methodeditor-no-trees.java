//
// Top-level class for a method editor
//


import javax.swing.*;
import javax.swing.text.*;
import javax.swing.event.*;
import java.awt.*;
import java.awt.event.*;

import java.io.*;
import java.util.*;

import Connection.*;

public class MethodEditor extends JFrame {

    public LispSocketAPI lc = null;

    private StyleContext sc;
    private Style replaceHighlight, withHighlight;
    private ActiveText capArea = null, bodyArea = null;
    private JTextField oldField = null, newField = null, searchField = null;

    private LayedData treeNL = null;
    private String methodName = null;

    private MethodEditor self;

    private static final int SELECTING_OLD = 1;
    private static final int SELECTING_NEW = 2;
    private int state = SELECTING_OLD;

    // This added when I used the StylePad example.
    Hashtable runAttr;

    public MethodEditor(String passed_methodName, LispSocketAPI passed_lc) {
        
        lc = passed_lc;
        methodName = passed_methodName;

        makeEditor();
    }

    public MethodEditor(String passed_methodName, LispSocketAPI passed_lc, boolean mainWindow) {
        
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
	  });
        }
    }

    public void makeEditor() {

        self = this;

        sc = new StyleContext();
        runAttr = new Hashtable();

        getContentPane().setLayout(new BoxLayout(getContentPane(), BoxLayout.Y_AXIS));
        
        JPanel donePane = new JPanel();
        donePane.setLayout(new FlowLayout(FlowLayout.LEFT));
        JButton doneBut = new JButton("done");
        doneBut.addActionListener(new ActionListener() {
	  public void actionPerformed(ActionEvent e) {
	      lc.sendLispCommand("(expect::tcl-nl-commit-notify)");
	      lc.safeReadLine();
	      lc.sendLispCommand("(expect::update-local-errors-in-existing-plan-after-modif expect::*edited-method*)");
	      lc.safeReadLine();
	      self.respondToDone();  // see comments with this method definition
	  }
        });
        donePane.add(doneBut);
        getContentPane().add(donePane);

        capArea = new CapText(sc);
        JScrollPane capScrollPane = new JScrollPane(capArea);
        capScrollPane.setVerticalScrollBarPolicy(JScrollPane.VERTICAL_SCROLLBAR_ALWAYS);
        capScrollPane.setPreferredSize(new Dimension(500,100));

        getContentPane().add(capScrollPane);

        JPanel oldTextPane = new JPanel();
        oldTextPane.setLayout(new FlowLayout(FlowLayout.LEFT));
        JLabel oldLabel = new JLabel("Replace");
        oldTextPane.add(oldLabel);
        oldField = new JTextField(40);
        oldField.setForeground(Color.red);
        oldTextPane.add(oldField);
        getContentPane().add(oldTextPane);

        JPanel newTextPane = new JPanel();
        newTextPane.setLayout(new FlowLayout(FlowLayout.LEFT));
        JLabel newLabel = new JLabel("With");
        newLabel.setSize(oldLabel.getSize());
        newTextPane.add(newLabel);
        newField = new JTextField(40);
        newField.setForeground(Color.green);
        newTextPane.add(newField);
        getContentPane().add(newTextPane);

        JPanel butPane = new JPanel();
        butPane.setLayout(new FlowLayout(FlowLayout.LEFT));
        JButton updateBut = new JButton("Update");
        updateBut.addActionListener(new ActionListener() {
	  public void actionPerformed(ActionEvent e) {
	      if (bodyArea.selected != null &&
		newField.getText().equals(bodyArea.selected.deepText()) == true) {
		readMethod("(let ((*package* \"EXPECT\")) (expect::tcl-update '" + capArea.selected.name + " '" + bodyArea.selected.name + " '" + bodyArea.selected.index + "))");
	      } else if (newField.getText() != null) {
		// Something was typed in the "with" field.
		readMethod("(let ((*package* \"EXPECT\")) (expect::tcl-update '" + capArea.selected.name + " nil nil '" + newField.getText() + "))");
	      }
	      if (newField.getText() != null) {
		setState(SELECTING_OLD);
	      }
	      displayMethod();
	  }
        });
        JButton undoBut = new JButton("Undo");
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
        clearBut.addActionListener(new ActionListener() {
	  public void actionPerformed(ActionEvent e) {
	      setState(SELECTING_OLD);
	  }
        });
        butPane.add(clearBut);

        JLabel searchLabel = new JLabel("Search for:");
        butPane.add(searchLabel);

        searchField = new JTextField(20);
        searchField.addKeyListener(new KeyAdapter() {
	  public void keyTyped(KeyEvent e) {
	      if (e.getKeyChar() == '\n' || e.getKeyChar() == '\r')
		bodyArea.highlightMatches(searchField.getText());
	  }
        });
        butPane.add(searchField);

        JButton searchBut = new JButton("Search");
        searchBut.addActionListener(new ActionListener() {
	  public void actionPerformed(ActionEvent e) {
	      bodyArea.highlightMatches(searchField.getText());
	  }
        });
        butPane.add(searchBut);

        getContentPane().add(butPane);

        bodyArea = new ActiveText(sc) {
	  public void actionPerformed(MouseEvent e) {
	      if (state == SELECTING_NEW) {
		newField.setText(selected.deepText());
	      }
	  }
        };
        JScrollPane bodyScrollPane = new JScrollPane(bodyArea);
        bodyScrollPane.setVerticalScrollBarPolicy(JScrollPane.VERTICAL_SCROLLBAR_ALWAYS);
        bodyScrollPane.setPreferredSize(new Dimension(500,500));

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

        pack();
        setVisible(true);
    }

    public void setState (int newState) {
        if (newState == SELECTING_OLD) {
	  capArea.removeSelection();
	  bodyArea.removeSelection();
	  bodyArea.setText("");
	  bodyArea.lData = null;
	  oldField.setText("");
	  newField.setText("");
	  capArea.highlightStyle = replaceHighlight;
	  bodyArea.highlightStyle = replaceHighlight;
	  state = SELECTING_OLD;
        } else if (newState == SELECTING_NEW) {
	  bodyArea.highlightStyle = withHighlight;
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

        // Currently all lists have length 1, extra nesting added by the
        // new server.
        indexedNL = (Vector)indexedNL.elementAt(0);
        //System.out.println("Read: " + indexedNL);

        // Hack to make treeNL an overall object that points to both
        // pieces of linked text.
        treeNL = new LayedData(0);
        treeNL.children = new Vector();
        Vector subNL = (Vector) indexedNL.elementAt(1);
        treeNL.children.addElement(makeTreeNL((Vector)subNL.elementAt(1)));
        subNL = (Vector) indexedNL.elementAt(2);
        treeNL.children.addElement(makeTreeNL((Vector)subNL.elementAt(1)));

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
	  doc.remove(0, doc.getLength());
	  doc.insertString(doc.getLength(), "In order to",
		         capArea.sc.getStyle("bold"));
	  capArea.displayLayedData((LayedData)treeNL.children.elementAt(0));
	  doc.insertString(doc.getLength(), "\n\n", capArea.normalStyle);
	  capArea.displayLayedData((LayedData)treeNL.children.elementAt(1));
        } catch (BadLocationException ble) {
	  System.err.println("Couldn't display initial text in method editor");
        }
    }

    // Parse the 4-element list structure of lisp's linked text into LayedData.
    public LayedData makeTreeNL(Vector linkedNL) {
        LayedData res = new LayedData();

        Vector english = (Vector)linkedNL.elementAt(0);
        if (english.size() > 0) {
	  res.text = (String)english.elementAt(0);
        }
        res.name = (String)linkedNL.elementAt(2);
        if (linkedNL.elementAt(3).equals("NIL") == false) {
	  Vector lkids = (Vector)linkedNL.elementAt(3);
	  res.children = new Vector();
	  for(int i = 0; i < lkids.size(); i++) {
	      res.children.addElement(makeTreeNL((Vector)lkids.elementAt(i)));
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
	      setOldSelection(selected);
	  } else if (state == SELECTING_NEW) {
	      newField.setText(selected.deepText());
	  }
        }
    }

    public void setOldSelection(LayedData ld) {
        String line;
        Document doc = bodyArea.getDocument();
        bodyArea.lData = new LayedData();
        Style boldStyle = bodyArea.sc.getStyle("bold");
        int group, alt;
        
        oldField.setText(ld.deepText());

        lc.sendLispCommand("(expect::print-alts-for-index " + ld.name + ")");
        try {
	  doc.remove(0, doc.getLength());
	  line = lc.safeReadLine();
	  group = -1; alt = 1;
	  while(line.equals("done") == false) {
	      Vector data = lc.readList(line);
	      if (data.elementAt(0).equals("ALT-TYPE") == true) {
		LayedData header = 
		    new LayedData("\n" + (String) data.elementAt(1) + "\n");
		header.normalStyle = boldStyle;
		header.active = false;
		bodyArea.lData.addChild(header);
		group++;
		alt = 1;
	      } else {
		if (data.elementAt(0).equals("NIL") == false) {
		    LayedData child = bodyArea.lData.addChild((String)((Vector)data.elementAt(0)).elementAt(0));
		    child.index = alt++;
		    child.name = "" + group;
		}
	      }
	      line = lc.safeReadLine();
	  }
	  lc.safeReadLine();   // Consume the function return.
	  bodyArea.displayLayedData();
        } catch (BadLocationException ble) {}
        setState(SELECTING_NEW);
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
        MethodEditor me = new MethodEditor("", mainlc, true);
    }

}
