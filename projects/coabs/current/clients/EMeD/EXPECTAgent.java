import javax.swing.*;
import java.awt.*;
import java.awt.event.*;
import java.io.*;
import java.util.*;

import java.io.*;
import java.lang.*;

import java.util.Vector;

import Connection.*;

public class EXPECTAgent extends JFrame implements ActionListener
{
        Font f12 = new Font("TimesNewRoman",Font.BOLD,12);
        Font f14 = new Font("TimesNewRoman",Font.BOLD,14);
        Font f16 = new Font("TimesNewRoman",Font.BOLD,16);
        Font f18 = new Font("TimesNewRoman",Font.BOLD,18);
	JLabel dateLabel,timeLabel,time,date,rslt;
	JButton relation,instance,close;
	JTextField tfname,tlname,taddress,temail;
	JComboBox cb,cb1;
	JFrame f;
	JFrame parent, caller;
	MySwing db;
	String fname,lname,address,email,software,paymode;
    Container cp = getContentPane();
	JFrame frame = new JFrame("Number Panel");
	//public LispSocketAPI mainlc;
    private String hostName = "excalibur.isi.edu";
    private String port = "8700";
    ExpectSocketAPI es;
	JPanel numPanel = new JPanel();
	JTextArea inputArea1 = new JTextArea(2,15);
	JTextArea inputArea2 = new JTextArea(2,15);
	JTextField txtnum1 = new JTextField();
	JTextField txtnum2 = new JTextField(); 
	String text1,text2,result="";
	LispSocketAPI mainlc = new LispSocketAPI("localhost", "5005");		
	public EXPECTAgent()
	{
		super("Agent Window");
		//db = this;
		/*es = new ExpectSocketAPI();
		String user = es.getUserName();
        System.out.println("User"+user);*/
		//LispSocketAPI mainlc = new LispSocketAPI("localhost", "5005");		
		addWindowListener(new WindowAdapter() 
		{
        	public void windowClosing(WindowEvent e) 
        	{
				System.exit(0);
 			}
 		});
 		
	   this.setSize(1000,750);
	   this.setVisible(true);
		
		//cp = getContentPane();
		cp.setLayout(null);
		JLabel l3 = new JLabel("Aritmetic Functions");
		l3.setFont(f18);
		l3.setBounds(300,30,650,30);
		l3.setForeground(Color.red);
		cp.add(l3);

		

	JPanel infoPanel = new JPanel();
	infoPanel.setLayout(null);
    infoPanel.setBounds(100,100,800,250);
    infoPanel.setBackground(Color.lightGray);
        
        infoPanel.setBorder(BorderFactory.createCompoundBorder(
        BorderFactory.createLineBorder(Color.black,4),
        BorderFactory.createEmptyBorder(5,5,5,5)));
	


	JLabel infoLabel = new JLabel ("Welcome to Expect Math Wizard");
	infoLabel.setBounds(300,5,300,30);
	infoLabel.setFont(f16); 
	infoLabel.setForeground((Color.blue).darker());
	infoPanel.add(infoLabel);
     
     
	 relation = new JButton("Perform Addition Of Numbers");
	 relation.setBounds(300,100,150,25);
      relation.setForeground(Color.white);
      relation.setBackground(((Color.blue).darker().darker()));
      relation.setMnemonic('P');
	  relation.addActionListener(new addListener());
      infoPanel.add(relation);
      
      instance = new JButton("Subtract Numbers");
      instance.setBounds(300,150,150,25);
      instance.setForeground(Color.white);
      instance.setBackground(((Color.blue).darker().darker()));
      instance.setMnemonic('S');
	  instance.addActionListener(new instanceListener());
      infoPanel.add(instance);
	    
	  close = new JButton("Close");
      close.setBounds(300,200,150,25);
      close.setForeground(Color.white);
      close.setBackground(((Color.blue).darker().darker()));
      close.setMnemonic('C');
	  close.addActionListener(this);
      infoPanel.add(close);
		
	cp.add( infoPanel);
		
		
	} // constructor ends

	class addListener implements ActionListener
	{
	public void actionPerformed(ActionEvent e)
	{
		
		
	  
      //ExpectSocketAPI es = new ExpectSocketAPI();
      frame.addWindowListener(new WindowAdapter() {
        public void windowClosing(WindowEvent e) {
                  System.exit(0);
        }
      });
      
      frame.setSize(1000, 750);
      frame.setVisible(true);
      Container cp = frame.getContentPane();
      cp.setLayout(null);
      //JPanel numPanel = new JPanel();
      numPanel.setLayout(null);
      numPanel.setBounds(100,100,800,250);
      numPanel.setBackground(Color.lightGray);
        
      numPanel.setBorder(BorderFactory.createCompoundBorder(
      BorderFactory.createLineBorder(Color.black,4),
      BorderFactory.createEmptyBorder(5,5,5,5)));
      JLabel addnum = new JLabel("Addition Of Two Numbers");
      addnum.setBounds(300,5,300,30);
	  addnum.setFont(f16); 
	  addnum.setForeground((Color.blue).darker());
	  
      numPanel.add(addnum);
      JLabel number1 = new JLabel ("Enter the first number");
	  number1.setBounds(20,50,120,25);
	  number1.setFont(f12); 
	  number1.setForeground((Color.black).darker());
	  numPanel.add(number1);	

	  
	  inputArea1.setBounds(200,50,120,25);
	  numPanel.add(inputArea1);
	  
	  
	  JLabel number2 = new JLabel ("Enter the second number");
	  number2.setBounds(20,95,200,25);
	  number2.setFont(f12); 
	  number2.setForeground((Color.black).darker());
	  numPanel.add(number2);	

	  //txtnum2 = new JTextField();
	  text1 = inputArea1.getText();
	  System.out.println("get the text no " +text1);
	  
	  inputArea2.setBounds(200,95,120,25);  /// here
	  
	  numPanel.add(inputArea2);	
	  
      text2 = txtnum2.getText();
	  JButton rsltbtn = new JButton("Click here for the sum");
	  rsltbtn.setBounds(410,170,150,25);
      rsltbtn.setForeground(Color.white);
      rsltbtn.setBackground(((Color.blue).darker().darker()));
      rsltbtn.setMnemonic('R');
	  
	  JButton histbtn = new JButton("Show Previous Use Of The Function");
	  histbtn.setBounds(300,200,250,25);
      histbtn.setForeground(Color.white);
      histbtn.setBackground(((Color.blue).darker().darker()));
      histbtn.setMnemonic('H');
	  numPanel.add(rsltbtn);
	  numPanel.add(histbtn);
	  
	  histbtn.addActionListener(new ActionListener() {
      	
      public void actionPerformed(ActionEvent e)
      {
      	
      	try
      	{
      		FileReader fileIn = new FileReader("C:\\Mukta\\current\\clients\\EMeD\\functionlog");
      		BufferedReader rd = new BufferedReader(fileIn);
      		String line;
      		JTextArea inputArea1 = new JTextArea(300,300);
      		inputArea1.setBounds(400,95,100,100);  /// here
	  	  	//numPanel.add(inputArea1);	
      		String str="";
      		while((line = rd.readLine())!= null)
      		{
      			
	            str = str + line +"\n\n"; 		
      			System.out.println(line);
      		}
      System.out.println("new string"+str);
      inputArea1.setText(str);
      inputArea1.setLineWrap(true);
      JScrollPane areaScrollPane = new JScrollPane(inputArea1);
	  areaScrollPane.setVerticalScrollBarPolicy(
	  JScrollPane.VERTICAL_SCROLLBAR_ALWAYS);
	  areaScrollPane.setPreferredSize(new Dimension(300, 300));
      areaScrollPane.setBounds(100,400,300,300);
      //numPanel.add(areaScrollPane);
      frame.getContentPane().add(areaScrollPane);
      //
      
      }
      
      catch(IOException ie)
      {
      	System.out.println(ie.toString());
      }
     }}); 	
      			
	  
	  
	  System.out.println("check text");
	  System.out.println("text1:"+text1);
	  System.out.println(text2);
	  
	  rsltbtn.addActionListener(new ActionListener() {
      
      public void actionPerformed(ActionEvent e) {
        text1 = inputArea1.getText();
        text2 = inputArea2.getText();
        System.out.println("text1 chk here :"+text1);
        System.out.println("text1 chk here :"+text2);
        //LispSocketAPI mainlc = new LispSocketAPI("camelot.isi.edu", "5679");
        mainlc.sendLispCommand("<compute><goal><action>add</action>"
		     + "<param><name>obj</name><value>" + text1  
		     + "</value></param>"
		     + "<param><name>to</name><value>" + text2
		     + "</value></param>"
		     + "</goal></compute>");
      result = mainlc.safeReadLine();
      System.out.println("Result : "+result); 
      System.out.println("text1 :"+text1); 
      // write to a file 
      try{
			FileWriter fileOut = new FileWriter("functionlog",true);
            System.out.println("log file");   
			fileOut.write("Addition Examples \n\n");
			fileOut.write("Input1 : "+text1+"\n");
			fileOut.write("Input2 : "+text2+"\n");
			fileOut.write("Output : "+result+"\n");
			fileOut.close();
		}

	catch(IOException ie)
  	{
   	System.out.println(ie.toString());
  	}
      rslt = new JLabel ("Result of addition"+result);
	  rslt.setBounds(20,120,200,25);
	  rslt.setFont(f12); 
	  rslt.setForeground((Color.black).darker());
	  numPanel.add(rslt); 
	  numPanel.revalidate();
	  numPanel.repaint();
	  
       
        
      }});
      
      
      			
      	
     

      
      
      
      //frame.getContentPane().add("Center", new numberPanel(es, null, false));
      //frame.add(cp);
      //getContentpane().add(numPanel);
      
     // numPanel.add(rslt);
             
      cp.add(numPanel);
      //revalidate();
	  repaint();
		
	 /* LispSocketAPI mainlc = new LispSocketAPI("camelot.isi.edu", "5679");
      //mainlc = es;
      mainlc.sendLispCommand("<compute><goal><action>add</action>"
		     + "<param><name>obj</name><value>" + text  
		     + "</value></param>"
		     + "<param><name>to</name><value>" + "2"
		     + "</value></param>"
		     + "</goal></compute>");
      String result = mainlc.safeReadLine();
         
      System.out.println("Result"+result);*/
         
     }    
    }
	
	class instanceListener implements ActionListener
	{
	public void actionPerformed(ActionEvent e)
	{
		
		
        String type;
        /*if (args.length > 0) {
	  type = args[0];
        } else {
	  type = "ship";
        }*/
        type = "ship";
        try{
	  InstanceEditor iE = new InstanceEditor(mainlc, type, true);
        } catch (Connection.FactoryException f) {
	  System.err.println("Error creating instance editor, while evaluating Lisp command:");
	  System.err.println(f.toString());
        }
		 //System.exit(0);
		 
    }		 
	
    }
	
	public void actionPerformed(ActionEvent e)
	{
		  System.exit(0);
	}	  
	
	public static void main(String args[] )
	{
		EXPECTAgent sng = new EXPECTAgent();
		
		//intro.addWindowListener(new WindowCloser1());
		sng.setSize(1000,750);
		sng.setVisible(true);
		sng.setBackground(Color.lightGray);
			
		sng.addWindowListener(new WindowAdapter(){
			
			public void windowClosed(WindowEvent e){
				System.exit(0);
			}
 		});
	} 		
	
	
}
		// main ends