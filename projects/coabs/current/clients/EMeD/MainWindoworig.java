import java.awt.*;
import java.awt.event.*;
import java.io.*;
import javax.swing.*;
import javax.swing.text.*;
import javax.swing.filechooser.*;
import Connection.*;
import Tree.*;

public class MainWindow extends JFrame implements ActionListener 
{
    
    JScrollPane jsp = new JScrollPane();
    //ColoredAttributeSet stdoutSet;
    JMenuItem saveItem,saveasItem, openItem, quitItem, closeItem;
    JMenuItem resultItem, detailsItem, describeItem;
    JMenuItem goalsItem, solveItem, conceptItem, methodItem, relationItem, instanceItem, searchItem;
    JMenuItem newItem, captogoalItem, meditItem, coneditItem, releditItem, insteditItem;
    JMenuItem clipItem, histItem, loadItem, caporgItem;
    JFrame parent, caller;
    //JButton close;
    Container contentPane;
    MainWindow mw;
    public LispSocketAPI lc = null;
    private String hostName = "excalibur.isi.edu";
    private String port = "8700";
    ExpectSocketAPI es;
    
    public MainWindow() 
    {
    	super("MainWindow");
    	//lc = new LispSocketAPI(hostName, port);
    	mw = this;
    	System.out.println("Const demo called");
        caller = parent;
		contentPane = getContentPane();
		addWindowListener(new WindowAdapter() 
		{
        	public void windowClosing(WindowEvent e) 
        	{
				System.exit(0);
 			}
 		});
 		
	 this.setSize(1000,750);
	 this.setVisible(true);
	 
	 //jtp.setCaretColor(Color.magenta);
	 
	 JMenuBar jmb = new JMenuBar();
	 JMenu fileMenu = new JMenu("File");
	 saveasItem = new JMenuItem("Save As");
	 //saveasItem.addActionListener(this);
	 saveItem=new JMenuItem("Save");
	 openItem = new JMenuItem("Open");
	 openItem.addActionListener(this);
	 quitItem = new JMenuItem("Exit");
	 //quitItem.addActionListener(this);
	 
	 fileMenu.add(openItem);
	 fileMenu.add(saveasItem);
	 fileMenu.add(saveItem);
	 //fileMenu.add(closeItem);
	 fileMenu.add(quitItem);
	 
	 
	 // OptionListener optL = new OptionListener();
	 JMenu runMenu = new JMenu("Run");
	 resultItem = new JMenuItem("Show Results");
	 //resultItem.addActionListener(this);
	 detailsItem = new JMenuItem("Show Details");
	 //detailsItem.addActionListener(this);
	 describeItem = new JMenuItem("Describe what I can run");
	 //copyItem.addActionListener(this);
	 runMenu.add(resultItem);
	 runMenu.add(detailsItem);
	 runMenu.add(describeItem);
	 
	 
	 
	 
	 JMenu browseMenu = new JMenu("Browse");
	 goalsItem = new JMenuItem("Goals");
	 //resultItem.addActionListener(this);
	 solveItem = new JMenuItem("Solve Goal");
	 methodItem = new JMenuItem("Methods");
	 //detailsItem.addActionListener(this);
	 conceptItem = new JMenuItem("Concepts");
	 //copyItem.addActionListener(this);
	 relationItem = new JMenuItem("Relation");
	 instanceItem = new JMenuItem("Instance");
	 searchItem = new JMenuItem("Search"); 
	 
	 
	 browseMenu.add(goalsItem);
	 browseMenu.add(methodItem);
	 browseMenu.add(conceptItem);
	 browseMenu.add(relationItem);
	 browseMenu.add(instanceItem);
	 browseMenu.add(searchItem);
	 
	 JMenu editMenu = new JMenu("Edit");
	 newItem = new JMenuItem("New...");
	 captogoalItem = new JMenuItem("Turn method capability into top level goal");
	 meditItem = new JMenuItem("Method");
	 coneditItem = new JMenuItem("Concept");
	 releditItem = new JMenuItem("Relation");
	 insteditItem = new JMenuItem("Instance");
	 editMenu.add(newItem); 
	 editMenu.add(captogoalItem); 
	 editMenu.add(meditItem); 
	 editMenu.add(coneditItem); 
	 editMenu.add(releditItem); 
	 editMenu.add(insteditItem); 
	 
	 JMenu helpMenu = new JMenu("Help");
	 
	 JMenu advMenu = new JMenu("Advanced");
	
	 clipItem = new JMenuItem("Clipboard");
	 histItem = new JMenuItem("Show History");
	 loadItem = new JMenuItem("Show Loaded Components");
	 caporgItem = new JMenuItem("Capibility Organizer");
	 advMenu.add(caporgItem);
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
	 
	 contentPane.add(jsp);
	 mw.setSize(1024,768);
	 this.setVisible(true);
	 
	 // set attribute style
	 //stdoutSet = new ColoredAttributeSet(Color.black);


	}  // contsructor ends
	
   
   public void open()
   {
   lc.sendLispCommand("(namestring expect::*domain-plan-directory*)");
        // Lisp's os-independent file structure should take care of us here..
        String planDir = lc.safeReadLine();
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
	lc.sendLispCommand("(expect::set-plan-from-xml-file \"" +
		         fullName.replace('\\','/') + "\")");
	System.out.println("Server says: " + lc.safeReadLine());
  
   }
   
  }
   
   
   public void showResult()
   {
   	
      System.exit(0);
      JFrame frame = new JFrame("Top Level Execution Goal");
      ExpectSocketAPI es = new ExpectSocketAPI();
      frame.addWindowListener(new WindowAdapter() {
        public void windowClosing(WindowEvent e) {
                  System.exit(0);
        }
      });
      
      frame.getContentPane().add("Center", new topexegoalPanel(es));
      frame.setSize(800, 400);
      frame.setVisible(true);
      //topexegoalPanel res = new topexegoalPanel(es); 	
   
   
   }	
   
   
   
   
   public void actionPerformed(ActionEvent e) {
       JMenuItem myMenuItem = new JMenuItem(); 
       Object src = e.getSource();
       System.out.println(src);
       
        
       if(myMenuItem.getText().equals("Show Results"))
       {
          	System.out.println("using get text");
         	
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


