import java.awt.*;
import java.awt.event.*;
import java.io.*;
import javax.swing.*;
import javax.swing.text.*;
import javax.swing.filechooser.*;
import javax.swing.border.*;
import javax.accessibility.*;
import java.util.*;
import Connection.*;
import Tree.*;
import PSTree.*;
import HTML.*;

import xml2jtml.methodDefRenderer;
//import ExpectPanel;
import ExpectWindowPanel;
import MethodEditor;
//import experiment.*;
import editor.MEditor;
import experiment.*;
import editor.*;
import ExpectWindowPanel;
import CritiqueWizard;

public class MainWindow extends JFrame implements ActionListener 
{
    
    JScrollPane jsp = new JScrollPane();
    //ColoredAttributeSet stdoutSet;
    JMenuItem saveItem,saveasItem, openItem, quitItem, closeItem;
    JMenuItem resultItem, detailsItem, describeRunItem,describeWhatItem,changeItem;
    JMenuItem goalsItem, solveItem, conceptItem, methodItem, relationItem, instanceItem, searchItem;
    JMenuItem newItem, captogoalItem, meditItem, coneditItem, releditItem, insteditItem,errorItem;
    JMenuItem clipItem, histItem, loadItem, caporgItem;
    JFrame parent, caller;
    //JButton close;
    Container contentPane;
    MainWindow mw;
    public LispSocketAPI mainlc;
    private String hostName = "excalibur.isi.edu";
    private String port = "8700";
    ExpectSocketAPI es;
    ExpectWindowPanel thePanel; 
    JCheckBoxMenuItem englishItem,formalItem;
    boolean toggleFlg=true;
    Font f12 = new Font("TimesNewRoman",Font.BOLD,12);
    Font f14 = new Font("TimesNewRoman",Font.BOLD,14);
    Font f16 = new Font("TimesNewRoman",Font.BOLD,16);
    Font f18 = new Font("TimesNewRoman",Font.BOLD,18);
    Container cp;
    
    public MainWindow() 
    {
    	super("MainWindow");
    	//lc = new LispSocketAPI(hostName, port);
    	es = new ExpectSocketAPI();
    	mw = this;
    	String user = es.getUserName();
    	System.out.println("User"+user);
    	System.out.println("Const demo called");
        caller = parent;
		contentPane = getContentPane();
		addWindowListener(new WindowAdapter() 
		{
        	public void windowClosing(WindowEvent e) 
        	{
				//saveData.end();
                //es.closeServerConnection();
   				System.exit(0);
 			}
 		});
 		
	 this.setSize(1000,750);
	 this.setVisible(true);
	 //cp = getContentPane();
	 contentPane.setLayout(null);
     JLabel l3 = new JLabel("Welcome to Expect Project: "+user);
     l3.setFont(f18);
     l3.setBounds(350,0,650,30);
	 l3.setForeground(Color.blue);
	 contentPane.add(l3);
	 //jtp.setCaretColor(Color.magenta);
	 
	 JPanel infoPanel = new JPanel();
	 infoPanel.setLayout(null);
     infoPanel.setBounds(0,50,800,800);
     /*infoPanel.setBackground(Color.lightGray);
        
     infoPanel.setBorder(BorderFactory.createCompoundBorder(
     BorderFactory.createLineBorder(Color.black,4),
     BorderFactory.createEmptyBorder(5,5,5,5)));*/
	 /*JLabel infoLabel = new JLabel ("Main Menu");
	 infoLabel.setBounds(350,20,300,30);
	 infoLabel.setFont(f16); 
	 infoLabel.setForeground((Color.blue).darker());
	 infoPanel.add(infoLabel);*/
	
	 JMenuBar jmb = new JMenuBar();
	 jmb.setBounds(100,100,800,800);
	 JMenu fileMenu = new JMenu("File");
	 //saveasItem = new JMenuItem("Save As");
	 //saveasItem.addActionListener(this);
	 saveItem=new JMenuItem("Save");
	 saveItem.addActionListener(this);
	 openItem = new JMenuItem("Open");
	 openItem.addActionListener(this);
	 quitItem = new JMenuItem("Exit");
	 quitItem.addActionListener(this);
	 
	 fileMenu.add(openItem);
	 //fileMenu.add(saveasItem);
	 fileMenu.add(saveItem);
	 //fileMenu.add(closeItem);
	 fileMenu.add(quitItem);
	 
	 
	 // OptionListener optL = new OptionListener();
	 JMenu runMenu = new JMenu("Run");
	 resultItem = new JMenuItem("Show Results");
	 resultItem.addActionListener(this);
	 
	 detailsItem = new JMenuItem("Show Details");
	 detailsItem.addActionListener(this);
	 
	 describeRunItem = new JMenuItem("Describe what I can run");
	 describeRunItem.addActionListener(this);
	 
	 describeWhatItem = new JMenuItem("Describe the kind of things I can Do");
	 describeWhatItem.addActionListener(this);
	 
	 changeItem = new JMenuItem("Change Goal");
	 changeItem.addActionListener(this);
	 newItem = new JMenuItem("New...");
	 newItem.addActionListener(this);
	 
	 runMenu.add(resultItem);
	 runMenu.add(detailsItem);
	 runMenu.add(describeRunItem);
	 runMenu.add(describeWhatItem);
	 runMenu.add(changeItem);
	 runMenu.add(newItem);
	 
	 JMenu browseMenu = new JMenu("Browse");
	 goalsItem = new JMenuItem("Goals");
	 goalsItem.addActionListener(this);
	 solveItem = new JMenuItem("How To Solve Goal");
	 solveItem.addActionListener(this);
	 
	 methodItem = new JMenuItem("Methods");
	 methodItem.addActionListener(this);
	 conceptItem = new JMenuItem("Concepts");
	 conceptItem.addActionListener(this);
	 relationItem = new JMenuItem("Relation");
	 relationItem.addActionListener(this);
	 instanceItem = new JMenuItem("Instance");
	 instanceItem.addActionListener(this);
	 searchItem = new JMenuItem("Search"); 
	 //searchItem.addActionListener(this);
	 
	 browseMenu.add(goalsItem);
	 browseMenu.add(solveItem); 
	 browseMenu.add(methodItem);
	 browseMenu.add(conceptItem);
	 browseMenu.add(relationItem);
	 browseMenu.add(instanceItem);
	 browseMenu.add(searchItem);
	 
	 JMenu editMenu = new JMenu("Edit");
	 
	 captogoalItem = new JMenuItem("Turn method capability into top level goal");
	 captogoalItem.setEnabled(false);
	 meditItem = new JMenuItem("Method");
	 meditItem.addActionListener(this);
	 coneditItem = new JMenuItem("Concept");
	 coneditItem.setEnabled(false);
	 releditItem = new JMenuItem("Relation");
	 releditItem.addActionListener(this);
	 insteditItem = new JMenuItem("Instance");
	 insteditItem.addActionListener(this);
	 
	 //editMenu.add(newItem); 
	 editMenu.add(captogoalItem); 
	 editMenu.add(meditItem); 
	 editMenu.add(coneditItem); 
	 editMenu.add(releditItem); 
	 editMenu.add(insteditItem); 
	 
	 JMenu helpMenu = new JMenu("Help");
	 
	 JMenu advMenu = new JMenu("Advanced");
	
	 JCheckBoxMenuItem englishItem = new JCheckBoxMenuItem("English");
	 englishItem.addActionListener(this);
	 //englishItem.setSelected(true);
	 
	 JCheckBoxMenuItem formalItem = new JCheckBoxMenuItem("Formal");
	 formalItem.addActionListener(this);
	 
	 clipItem = new JMenuItem("Clipboard");
	 
	 histItem = new JMenuItem("Show History");
	 histItem.setEnabled(false);
	 loadItem = new JMenuItem("Show Loaded Components");
	 loadItem.setEnabled(false);
	 caporgItem = new JMenuItem("Capibility Organizer");
	 caporgItem.addActionListener(this);
	 errorItem = new JMenuItem("Errors");
	 errorItem.addActionListener(this);
	 
	 advMenu.add(englishItem);
	 advMenu.add(formalItem);
	 advMenu.add(caporgItem);
	 advMenu.add(errorItem);
	 advMenu.add(clipItem);
	 advMenu.add(histItem);
	 advMenu.add(loadItem);
	 
	 
	 jmb.add(fileMenu);
	 jmb.add(runMenu);
	 jmb.add(browseMenu);
	 jmb.add(editMenu);
	 jmb.add(helpMenu);
	 jmb.add(advMenu);
	 
	 setJMenuBar(jmb);
	 /*if(englishItem.isSelected() == true)
	  toggle = true;
	 else 
	  toggle = false;*/
	 infoPanel.add(jmb);
	 contentPane.add(infoPanel);
	 contentPane.add(jsp);
	 
	 mw.setSize(1024,768);
	 this.setVisible(true);
	 
	 // set attribute style
	 //stdoutSet = new ColoredAttributeSet(Color.black);


	}  // contsructor ends
	
   
   public void open()
   {
   mainlc.sendLispCommand("(namestring expect::*domain-plan-directory*)");
        // Lisp's os-independent file structure should take care of us here..
        String planDir = mainlc.safeReadLine();
        // Note: source for ExtensionFileFilter can be found in the
        // SwingSet demo.
        JFileChooser chooser = new JFileChooser(planDir.substring(2,planDir.length() - 1));
        //ExtensionFileFilter filter = new ExtensionFileFilter(); 
        //filter.addExtension("xml"); 
        //filter.addExtension("gif");
        //filter.setDescription("JPG & GIF Images"); 
        //chooser.setFileFilter(filter); 
        chooser.setDialogTitle("File containing plan");
        int returnVal = chooser.showOpenDialog(this); 
        if(returnVal == JFileChooser.APPROVE_OPTION) {
	String fullName = chooser.getSelectedFile().getAbsolutePath();
	System.out.println("Loading constraints from " + fullName);
	mainlc.sendLispCommand("(expect::set-plan-from-xml-file \"" +
		         fullName.replace('\\','/') + "\")");
	System.out.println("Server says: " + mainlc.safeReadLine());
  
   }
   
  }
   
   
   public void showResult()
   {
   	
      //System.exit(0);
      //topexegoalPanel extop = new topexegoalPanel(es);
     
      JFrame frame = new JFrame("Show Results");
      //ExpectSocketAPI es = new ExpectSocketAPI();
      frame.addWindowListener(new WindowAdapter() {
        public void windowClosing(WindowEvent e) {
                  //System.exit(0);
        }
      });
      
      frame.getContentPane().add("Center", new topexegoalPanel(es));
      frame.setSize(800, 400);
      frame.setVisible(true);
      
   
   }	
   
  
  // show the execution tree
  public void showDetails()
  {
  	
  	//ExpectSocketAPI es = new ExpectSocketAPI();
    PSTree.exTreePanel tpanel = new PSTree.exTreePanel(es, null, null);
    //PSTreePanel tpanel = new PSTreePanel(es, null, null,"ps-an10");
    JFrame frame = new JFrame("Show Details");
     frame.addWindowListener(new WindowAdapter() {
        public void windowClosing(WindowEvent e) {
                  //System.exit(0);
        }
      });
     frame.getContentPane().add(tpanel);
     frame.setSize(700, 500);
     frame.setVisible(true);
    
  }
  	
  // 
  
  public void showSystemDirectory()
  {
  	JFrame frame = new JFrame("Load Domain");
      //ExpectSocketAPI es = new ExpectSocketAPI();
      frame.addWindowListener(new WindowAdapter() {
        public void windowClosing(WindowEvent e) {
                  //System.exit(0);
        }
      });
      
      frame.getContentPane().add("Center", new domaindirectoryPanel(es, null, false));
      frame.setSize(400, 400);
      frame.setVisible(true);
    }
  	
  		
   	
  	
  	
  	
  	
  public void describeRun()
  {
  	
  	JFrame frame = new JFrame("Describe What I can run");
      //ExpectSocketAPI es = new ExpectSocketAPI();
      frame.addWindowListener(new WindowAdapter() {
        public void windowClosing(WindowEvent e) {
                  //System.exit(0);
        }
      });
      
      frame.getContentPane().add("Center", new topexegoalListPanel(es));
      frame.setSize(800, 400);
      frame.setVisible(true);
  
  
  }	
   
   public void describeWhat()
  {
  	
  	JFrame frame = new JFrame("Describe the kind of things I can Do");
      //ExpectSocketAPI es = new ExpectSocketAPI();
      frame.addWindowListener(new WindowAdapter() {
        public void windowClosing(WindowEvent e) {
                  //System.exit(0);
        }
      });
      
      frame.getContentPane().add("Center", new toppsgoalListPanel(es));
      frame.setSize(800, 400);
      frame.setVisible(true);
  
  
  }	
   
  public void showPSTree()
  {
  	
     //ExpectSocketAPI es = new ExpectSocketAPI();
    GRPanel tpanel = new GRPanel("allRfml",es, null, null);
    //GRPanel tpanel = new GRPanel("method-relation",es, null, null);
    
    JFrame frame = new JFrame("How To Solve Goal");
     frame.addWindowListener(new WindowAdapter() {
        public void windowClosing(WindowEvent e) {
                  //System.exit(0);
        }
      });
     frame.getContentPane().add(tpanel);
     frame.setSize(700, 500);
     frame.setVisible(true);

  }
  
  
  public void showMethodList()
  {
  	
  	
  	JFrame frame = new JFrame("Methods");
      //ExpectSocketAPI es = new ExpectSocketAPI();
      frame.addWindowListener(new WindowAdapter() {
        public void windowClosing(WindowEvent e) {
                  //System.exit(0);
        }
      });
      
      frame.getContentPane().add("Center", new Tree.browseMethodList(es,null,"normal"));
      frame.setSize(500, 800);
      frame.setVisible(true);
  
  
  
}
  	
  public void editMethodList()
  {
  	
  	//System.out.println(englishItem.getState());
  	/*Boolean flag = new Boolean(true);
  	
  	//flag = englishItem.isSelected();
  	System.out.println(flag.toString());
  	System.out.println("true");*/
  	Boolean flag = new Boolean(toggleFlg);
  	System.out.println(flag.toString());
  	if(toggleFlg == true)
  	{
  	JFrame frame = new JFrame("Methods");
      //ExpectSocketAPI es = new ExpectSocketAPI();
      frame.addWindowListener(new WindowAdapter() {
        public void windowClosing(WindowEvent e) {
                  //System.exit(0);
        }
      });
      
      frame.getContentPane().add("Center", new methodListPanelEnglish(es,null,"normal"));
      frame.setSize(500, 800);
      frame.setVisible(true);
      //formalItem.setSelected(false);
      toggleFlg = false;
    }

  	
  	else
  	{
  	JFrame frame = new JFrame("Methods");
      //ExpectSocketAPI es = new ExpectSocketAPI();
      frame.addWindowListener(new WindowAdapter() {
        public void windowClosing(WindowEvent e) {
                  //System.exit(0);
        }
      });
      
      frame.getContentPane().add("Center", new Tree.methodListPanel(es,null,"normal"));
      frame.setSize(500, 800);
      frame.setVisible(true);
      //englishItem.setSelected(false);
      toggleFlg = true;
     }
  }
  
  
  
  public void showOntologyBrowser()
  {
  	
  	//ExpectSocketAPI es = new ExpectSocketAPI();
    //commented by Mukta
   //JPanel tpanel = new HtmlPanel(es,"http://www.yahoo.com/","");
    //added by Mukta
    //JPanel tpanel = new HtmlPanel(es,"file:///C:\\Mukta\\current\\clients\\EMeD\\HTML\\","TOP-DOMAIN-CONCEPT.CONCEPT");
    //JPanel tpanel = new HtmlPanel(es,"file:///C:/Mukta/current/clients/EMeD/HTML/","TOP-DOMAIN-CONCEPT.concept");
    
    JPanel tpanel = new HtmlPanel(es,"file:///C:/Mukta/current/clients/EMeD/","TOP-DOMAIN-CONCEPT.concept");
    //JPanel tpanel = new HtmlPanel(es,"file:/nfs/v2/jihie/expect/EMeD/Client2/HTML/","");

    //JPanel tpanel = new HtmlPanel(es,"http://www.alphatech.com/protected/hpkb/ikd/sources/Knowledge_Fragments/","KF_7.html");

    JFrame frame = new JFrame("Browser");
     frame.addWindowListener(new WindowAdapter() {
        public void windowClosing(WindowEvent e) {
                  //System.exit(0);
        }
      });
     frame.getContentPane().add(tpanel);
     frame.setSize(700, 500);
     frame.setVisible(true);

  }
  
  /*public void showMethodEditor()
  {
  	
  	LispSocketAPI mainlc = new LispSocketAPI("camelot.isi.edu", "5679");
        String methodName = "";
        System.out.println(args.length + " args:");
        for(int i = 0; i < args.length; i++)
	  System.out.println(i + ": " + args[i]);
        if (args.length > 0) {
	  methodName = args[0];
        }
        MethodEditor me = new MethodEditor(methodName, mainlc, true);
    //}

  }	*/ 
   
   
   public void showRelationEditor()
   {
   	//LispSocketAPI mainlc = new LispSocketAPI("camelot.isi.edu", "5679");
    RelationEditor re = new RelationEditor(es, "", "");
   	
   }	
   
   
   public void showInstanceEditor()
   {
   	//LispSocketAPI mainlc = new LispSocketAPI("camelot.isi.edu", "5950");
        String type;
        /*if (args.length > 0) {
	  type = args[0];
        } else {
	  type = "ship";
        }*/
        type = "los-angeles";
        try{
	  InstanceEditor iE = new InstanceEditor(es, type, true);
        } catch (Connection.FactoryException f) {
	  System.err.println("Error creating instance editor, while evaluating Lisp command:");
	  System.err.println(f.toString());
        }
   	
   }
   	
   
   public void changeGoal()
   {
   	JFrame frame = new JFrame("Change the  Goal");
      //ExpectSocketAPI es = new ExpectSocketAPI();
      frame.addWindowListener(new WindowAdapter() {
        public void windowClosing(WindowEvent e) {
                  //System.out.println("closing");
                  //setVisible(false);
                  //System.exit(0);
        }
      });
      
      frame.getContentPane().add("Center", new exegoalListEditPanel(es));
      frame.setSize(800, 400);
      frame.setVisible(true);
    }
   	
   	
   public void showCapability()
   {
   	treePanel tpanel = new treePanel("method-capability",es,null);
    JFrame frame = new JFrame("Capability Organizer");
     frame.addWindowListener(new WindowAdapter() {
        public void windowClosing(WindowEvent e) {
                  //System.exit(0);
        }
      });
     frame.getContentPane().add(tpanel);
     frame.setSize(700, 500);
     frame.setVisible(true);

  }

	
	public void showErrors()
	{
		
		
	  JFrame frame = new JFrame("Errors");
      //ExpectSocketAPI es = new ExpectSocketAPI();
      frame.addWindowListener(new WindowAdapter() {
        public void windowClosing(WindowEvent e) {
                  //System.exit(0);
        }
      });
      
      frame.getContentPane().add("Center", new errorPanel(es, null, false));
      frame.setSize(400, 400);
      frame.setVisible(true);
    }
	
	
	
	
	public void changePSGoal()
	{
	
	JFrame frame = new JFrame("Apply Problem Solving Goal");
      //ExpectSocketAPI es = new ExpectSocketAPI();
      frame.addWindowListener(new WindowAdapter() {
        public void windowClosing(WindowEvent e) {
                  //System.exit(0);
        }
      });
      
      frame.getContentPane().add("Center", new psgoalListEditPanel(es));
      frame.setSize(800, 400);
      frame.setVisible(true);
	
	
	}
   
   
   public void save()
   {
   	JFrame frame = new JFrame("Save");
      //ExpectSocketAPI es = new ExpectSocketAPI();
      frame.addWindowListener(new WindowAdapter() {
        public void windowClosing(WindowEvent e) {
                  //System.exit(0);
        }
      });
      
      frame.getContentPane().add("Center", new savedirectoryPanel(es, null, false));
      frame.setSize(400, 400);
      frame.setVisible(true);
    
   }
   
   
   public void actionPerformed(ActionEvent e) {
       
       
        Object src = e.getSource();
        if(src == openItem)
        //System.exit(0);
        {
          //open();
          showSystemDirectory();
        }
       else if(src == saveItem)
       {
        	save();
       	
       }	
       else if(src==quitItem)
       {
       	        //saveData.end();
                es.closeServerConnection();
   				System.exit(0);
       
       }
       
       
       else if(src == resultItem)
       
       {
          	System.out.println("result");
         	showResult();
       }
        
       else if(src == detailsItem)
       {
       	
           System.out.println("show details");
           showDetails();
       }	
       
       else if(src == describeRunItem)
       {
       	
           System.out.println("describe Run");
           describeRun();
       }	
       else if(src == describeWhatItem)
       {
       	
           describeWhat();
       }	 
      
       else if(src == changeItem)
       {
       	  changeGoal();	
       }
       
       else if(src == goalsItem)
       {
       	
           describeWhat();
       }	 
      
      else if(src == solveItem)
       {
       	
           showPSTree();
       }	 
      
      else if(src == methodItem)
       {
       	
           showMethodList();
       }	 
      
      else if(src== conceptItem)
      {
           showOntologyBrowser();   
      
       }
      
	 else if(src == relationItem)
      {
           showOntologyBrowser();   
      
       }
      else if(src == instanceItem)
      {
           showOntologyBrowser();   
      
       }

      else if(src == newItem)
      {
           //describeWhat();   
           changePSGoal();
       }

      else if(src == meditItem)
      {
      	
      	editMethodList();
      	
      }	
 
      else if(src == releditItem)
      {
      	System.out.println("relation");
      	showRelationEditor();
      }
      else if(src == insteditItem)
      {
      	System.out.println("Instance");
      	showInstanceEditor();
      }		

      else if(src==caporgItem)
      {
      	showCapability();
      }	
     
     else if(src==errorItem)
      {
      	showErrors();
      }	
     
     else if(src==englishItem)
     {
     	englishItem.setSelected(true);
     	if(formalItem.isSelected()== true)
     	 System.out.println("formal selected");
     	formalItem.setSelected(false);
     	toggleFlg = true;
     }
     
     else if(src==formalItem)
     {
     	
     	formalItem.setSelected(true);
     	englishItem.setSelected(false);
     	toggleFlg = false;
     }		
     
     
          

      }
     
     //}    
      
   
   
   public static void main(String args[] )
	{
		MainWindow mwnd = new MainWindow();
		
		//intro.addWindowListener(new WindowCloser1());
		mwnd.setSize(1000,750);
		mwnd.setVisible(true);
		mwnd.setBackground(Color.lightGray);
			
		
		mwnd.addWindowListener(new WindowAdapter(){
			
			public void windowClosed(WindowEvent e){
				System.exit(0);
			}
 		});
			
	
	
}
     
 }


