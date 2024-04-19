import javax.swing.*;
import java.awt.*;
import java.awt.event.*;
import java.io.*;
import java.util.*;

import java.io.*;
import java.lang.*;

import java.util.Vector;

import Connection.*;

public class EXPECTMAINAgentWeb extends JApplet implements ActionListener
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
	//LispSocketAPI mainlc = new LispSocketAPI("localhost", "5005");		
	public EXPECTMAINAgentWeb()
	{
		//super("Agent Window");
		//db = this;
		/*es = new ExpectSocketAPI();
		String user = es.getUserName();
        System.out.println("User"+user);*/
		//LispSocketAPI mainlc = new LispSocketAPI("localhost", "5005");		
		/*addWindowListener(new WindowAdapter() 
		{
        	public void windowClosing(WindowEvent e) 
        	{
				System.exit(0);
 			}
 		});
 		
	   this.setSize(1000,750);
	   this.setVisible(true);*/
		
		//cp = getContentPane();
		cp.setLayout(null);
		JLabel l3 = new JLabel("Main Menu");
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
	


	JLabel infoLabel = new JLabel ("Welcome to Expect");
	infoLabel.setBounds(300,5,300,30);
	infoLabel.setFont(f16); 
	infoLabel.setForeground((Color.blue).darker());
	infoPanel.add(infoLabel);
     
     
	 relation = new JButton("Math Wizard");
	 relation.setBounds(300,100,150,25);
      relation.setForeground(Color.white);
      relation.setBackground(((Color.blue).darker().darker()));
      relation.setMnemonic('P');
	  //relation.addActionListener(new addListener());
      infoPanel.add(relation);
      
      instance = new JButton("Meet the Elves");
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
		
		
	  //EXPECTAgentWeb sng = new EXPECTAgent();
		
		//intro.addWindowListener(new WindowCloser1());
		/*sng.setSize(1000,750);
		sng.setVisible(true);
		sng.setBackground(Color.lightGray);
			
		sng.addWindowListener(new WindowAdapter(){
			
			public void windowClosed(WindowEvent e){
				System.exit(0);
			}
 		});*/
	} 		
      //ExpectSocketAPI es = new ExpectSocketAPI();
      
        
    }
	
	class instanceListener implements ActionListener
	{
	public void actionPerformed(ActionEvent e)
	{
		
		
        EXPECTFlightAgentWeb sng = new EXPECTFlightAgentWeb();
		
		//intro.addWindowListener(new WindowCloser1());
		/*sng.setSize(1000,750);
		sng.setVisible(true);
		sng.setBackground(Color.lightGray);
			
		sng.addWindowListener(new WindowAdapter(){
			
			public void windowClosed(WindowEvent e){
				System.exit(0);
			}
 		});*/
	} 		
	
    }
	
	public void actionPerformed(ActionEvent e)
	{
		  System.exit(0);
	}	  
	
	public void init()
	{
		EXPECTMAINAgentWeb sng = new EXPECTMAINAgentWeb();
		
		//intro.addWindowListener(new WindowCloser1());
		/*sng.setSize(1000,750);
		sng.setVisible(true);
		sng.setBackground(Color.lightGray);*/
			
		/*(sng.addWindowListener(new WindowAdapter(){
			
			public void windowClosed(WindowEvent e){
				System.exit(0);
			}
 		});*/
	} 		
	
	
}
		// main ends