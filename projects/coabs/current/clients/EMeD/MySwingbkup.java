import javax.swing.*;
import java.awt.*;
import java.awt.event.*;
import java.io.*;
import java.util.*;
//import java.net.*;
import java.io.*;
import java.lang.*;

import java.util.Vector;

import Connection.*;

public class MySwing extends JFrame //implements ActionListener
{
        Font f12 = new Font("TimesNewRoman",Font.BOLD,12);
        Font f14 = new Font("TimesNewRoman",Font.BOLD,14);
        Font f16 = new Font("TimesNewRoman",Font.BOLD,16);
        Font f18 = new Font("TimesNewRoman",Font.BOLD,18);
	JLabel dateLabel,timeLabel,time,date;
	JButton relation,instance,close;
	JTextField tfname,tlname,taddress,temail;
	JComboBox cb,cb1;
	JFrame f;
	JFrame parent, caller;
	MySwing db;
	String fname,lname,address,email,software,paymode;
    Container cp;
	
	
	
	
	 
	public MySwing()
	{
		super("Main Window");
		//db = this;
		
		
		addWindowListener(new WindowAdapter() 
		{
        	public void windowClosing(WindowEvent e) 
        	{
				System.exit(0);
 			}
 		});
 		
	   this.setSize(1000,750);
	   this.setVisible(true);
		
		cp = getContentPane();
		cp.setLayout(null);
		JLabel l3 = new JLabel("Relation And Instance Editor");
		l3.setFont(f18);
		l3.setBounds(250,30,650,30);
		l3.setForeground(Color.red);
		cp.add(l3);

		/*dateLabel = new JLabel("Date:");
		dateLabel.setBounds(20,25,50,25);
      	dateLabel.setForeground(Color.black);
        	dateLabel.setFont(f12);
        	cp.add(dateLabel);

	      timeLabel = new JLabel("Time:");
      	timeLabel.setBounds(20,55,50,25);
	      timeLabel.setForeground(Color.black);
      	timeLabel.setFont(f12);
	      cp.add(timeLabel);

      	date = new JLabel(" ");
   		date.setBounds(55,25,70,25);
     		date.setForeground(Color.black);
      	date.setFont(f12);

      	time = new JLabel("Time:");
	      time.setBounds(55,55,70,25);
       	time.setForeground(Color.black);
        	time.setFont(f12);

       	 DateTime d = new DateTime();
        	d.setlabel(date,time);
		
		cp.add(date);
		cp.add(time);*/

	JPanel infoPanel = new JPanel();
	 infoPanel.setLayout(null);
       	  infoPanel.setBounds(100,100,800,250);
         	infoPanel.setBackground(Color.lightGray);
        
        infoPanel.setBorder(BorderFactory.createCompoundBorder(
        BorderFactory.createLineBorder(Color.black,4),
        BorderFactory.createEmptyBorder(5,5,5,5)));
	


	JLabel infoLabel = new JLabel ("Main Menu");
	infoLabel.setBounds(250,5,300,30);
	infoLabel.setFont(f14); 
	infoLabel.setForeground((Color.blue).darker());
	infoPanel.add(infoLabel);


	 relation = new JButton("Relation Editor");
	 relation.setBounds(250,100,150,25);
      relation.setForeground(Color.white);
      relation.setBackground(((Color.blue).darker().darker()));
      relation.setMnemonic('R');
	  relation.addActionListener(new relationListener());
      infoPanel.add(relation);
      
      instance = new JButton("Instance Editor");
      instance.setBounds(250,150,150,25);
      instance.setForeground(Color.white);
      instance.setBackground(((Color.blue).darker().darker()));
      instance.setMnemonic('I');
	  instance.addActionListener(new instanceListener());
      infoPanel.add(instance);
		
	cp.add( infoPanel);
		
		
	} // constructor ends

	class relationListener implements ActionListener
	{
	public void actionPerformed(ActionEvent e)
	{
		
		 LispSocketAPI mainlc = new LispSocketAPI("camelot.isi.edu", "5679");
         RelationEditor re = new RelationEditor(mainlc, "", "");
		 //System.exit(0);
		 
    }		 
	
    }
	
	class instanceListener implements ActionListener
	{
	public void actionPerformed(ActionEvent e)
	{
		
		LispSocketAPI mainlc = new LispSocketAPI("camelot.isi.edu", "5950");
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
	
	
	
	public static void main(String args[] )
	{
		MySwing sng = new MySwing();
		
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