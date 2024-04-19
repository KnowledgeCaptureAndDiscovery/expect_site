import javax.swing.*;
import java.awt.*;
import java.awt.event.*;
import java.io.*;
import java.util.*;

import java.io.*;
import java.lang.*;

import java.util.Vector;

import Connection.*;
import Tree.FlightFareParser;
import Tree.FlightSchedParser;
import Tree.FlightStatParser;

public class EXPECTFlightAgenttry extends JFrame implements ActionListener
{
        Font f12 = new Font("TimesNewRoman",Font.BOLD,12);
        Font f14 = new Font("TimesNewRoman",Font.BOLD,14);
        Font f16 = new Font("TimesNewRoman",Font.BOLD,16);
        Font f18 = new Font("TimesNewRoman",Font.BOLD,18);
	JLabel dateLabel,timeLabel,time,date,rslt;
	JButton relation,instance,close,status;
	JTextField tfname,tlname,taddress,temail;
	JComboBox cb,cb1;
	JFrame f;
	JFrame parent, caller;
	MySwing db;
	String fname,lname,address,email,software,paymode;
    Container cp = getContentPane();
	JFrame fareframe = new JFrame("Air-Fare monitoring agent");
	JFrame schedframe = new JFrame("Flight Schedule monitoring agent");
	JFrame statusframe = new JFrame("Flight Status monitoring agent");
	
	
	//public LispSocketAPI mainlc;
    
    private String hostName = "excalibur.isi.edu";
    private String port = "8700";
    ExpectSocketAPI es;
	JPanel numPanel = new JPanel();
	JPanel schedPanel = new JPanel();
	JPanel statusPanel = new JPanel();
	JTextArea inputArea1 = new JTextArea(2,15);
	JTextArea inputArea2 = new JTextArea(2,15);
	JTextArea inputArea3 = new JTextArea(2,15);
	JTextArea inputArea4 = new JTextArea(2,15);
	JTextArea inputArea5 = new JTextArea(2,15);
	JTextArea inputArea6 = new JTextArea(2,15);
	
	JTextArea schedArea1 = new JTextArea(2,15);
	JTextArea schedArea2 = new JTextArea(2,15);
	JTextArea schedArea3 = new JTextArea(2,15);
	JTextArea schedArea4 = new JTextArea(2,15);
	JTextArea schedArea5 = new JTextArea(2,15);
	JTextArea schedArea6 = new JTextArea(2,15);
	
	JTextArea statusArea1 = new JTextArea(2,15);
	JTextArea statusArea2 = new JTextArea(2,15);
	JTextArea statusArea3 = new JTextArea(2,15);
	JTextArea statusArea4 = new JTextArea(2,15);
	JTextArea statusArea5 = new JTextArea(2,15);
	JTextArea statusArea6 = new JTextArea(2,15);
	
	
	
    //JLabel number1 = new JLabel("");	
	JTextField txtnum1 = new JTextField();
	JTextField txtnum2 = new JTextField(); 
	String text1,text2,text3,text4,text5,text6,result="";
	//LispSocketAPI mainlc = new LispSocketAPI("localhost", "5005");		
	public EXPECTFlightAgenttry()
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
		JLabel l3 = new JLabel("Meet The Elves ");
		l3.setFont(f18);
		l3.setBounds(400,30,650,30);
		l3.setForeground(Color.red);
		cp.add(l3);

		

	JPanel infoPanel = new JPanel();
	infoPanel.setLayout(null);
    infoPanel.setBounds(100,100,800,250);
    infoPanel.setBackground(Color.lightGray);
        
        infoPanel.setBorder(BorderFactory.createCompoundBorder(
        BorderFactory.createLineBorder(Color.black,4),
        BorderFactory.createEmptyBorder(5,5,5,5)));
	


	/*JLabel infoLabel = new JLabel ("Meet the Elves");
	infoLabel.setBounds(300,5,300,30);
	infoLabel.setFont(f18); 
	infoLabel.setForeground((Color.red).darker());
	infoPanel.add(infoLabel);*/
     
     
	 relation = new JButton("Air-Fare");
	 relation.setBounds(300,50,150,25);
      relation.setForeground(Color.white);
      relation.setBackground(((Color.blue).darker().darker()));
      relation.setMnemonic('P');
	  relation.addActionListener(new airfareListener());
      infoPanel.add(relation);
      
      instance = new JButton("Flight Schedules");
      instance.setBounds(300,100,150,25);
      instance.setForeground(Color.white);
      instance.setBackground(((Color.blue).darker().darker()));
      instance.setMnemonic('S');
	  
	  instance.addActionListener(new schedListener());
      infoPanel.add(instance);
	    
	  status = new JButton("Flight Status");
      status.setBounds(300,150,150,25);
      status.setForeground(Color.white);
      status.setBackground(((Color.blue).darker().darker()));
      status.setMnemonic('S');
	  status.addActionListener(new statusListener());
      infoPanel.add(status);
	  
	  
	  close = new JButton("Close");
      close.setBounds(300,200,150,25);
      close.setForeground(Color.white);
      close.setBackground(((Color.blue).darker().darker()));
      close.setMnemonic('C');
	  close.addActionListener(this);
      infoPanel.add(close);
		
	cp.add( infoPanel);
		
		
	} // constructor ends

	class airfareListener implements ActionListener
	{
	public void actionPerformed(ActionEvent e)
	{
		
		
	  FlightFareParser myparser = new FlightFareParser();
      Vector mylist = myparser.getGoals("flightlog.xml");
      System.out.println("show"+mylist.elementAt(6));
      //ExpectSocketAPI es = new ExpectSocketAPI();
      //System.exit(0);
      fareframe.addWindowListener(new WindowAdapter() {
        public void windowClosing(WindowEvent e) {
                  System.exit(0);
        }
      });
      
      fareframe.setSize(1000, 750);
      fareframe.setVisible(true);
      Container cp = fareframe.getContentPane();
      cp.setLayout(null);
      //JPanel numPanel = new JPanel();
      numPanel.setLayout(null);
      numPanel.setBounds(100,100,800,600);
      numPanel.setBackground(Color.lightGray);
        
      numPanel.setBorder(BorderFactory.createCompoundBorder(
      BorderFactory.createLineBorder(Color.black,4),
      BorderFactory.createEmptyBorder(5,5,5,5)));
      JLabel addnum = new JLabel(mylist.elementAt(0).toString());
      addnum.setBounds(300,5,300,30);
	  addnum.setFont(f16); 
	  addnum.setForeground((Color.blue).darker());
	  numPanel.add(addnum);
	  int j=0;
	  /*for(int i=0;i<mylist.size();i++)
	  {
	  	  number= new JLabel("");
	  }	
	  Vector number= new Vector(); 
	  
	  for(int i=1;i<mylist.size();i++)
	  {
      
      number.add(mylist.elementAt(i).toString());
	  JLabel tp = new JLabel(number.elementAt(i).toString());
	  //String tp = number.get(i).toString();
	  //tp = mylist.elementAt(i).toString();
	  tp.setBounds(20,50+j,120,25);
	  tp.setFont(f12); 
	  tp.setForeground((Color.black).darker());
	  numPanel.add(tp);	
	  
	  inputArea1.setBounds(200,50+j,120,20);
	  numPanel.add(inputArea1);
	  j = j+15;
	  //numPanel.revalidate();
	  //numPanel.repaint();
	  }*/
	  JLabel number1 = new JLabel (mylist.elementAt(1).toString());
	  number1.setBounds(20,50,200,25);
	  number1.setFont(f12); 
	  number1.setForeground((Color.black).darker());
	  numPanel.add(number1);	
	  inputArea1.setBounds(200,50,120,20);  /// here
	  numPanel.add(inputArea1);	
	  
	  JLabel number2 = new JLabel (mylist.elementAt(2).toString());
	  number2.setBounds(20,75,200,25);
	  number2.setFont(f12); 
	  number2.setForeground((Color.black).darker());
	  numPanel.add(number2);	
	  inputArea2.setBounds(200,75,120,20);  /// here
	  numPanel.add(inputArea2);	
	  
      JLabel number3 = new JLabel (mylist.elementAt(3).toString());
	  number3.setBounds(20,100,200,25);
	  number3.setFont(f12); 
	  number3.setForeground((Color.black).darker());
	  numPanel.add(number3);	
      inputArea3.setBounds(200,100,120,20);  /// here
	  numPanel.add(inputArea3);	
	  
	  JLabel number4 = new JLabel (mylist.elementAt(4).toString());
	  number4.setBounds(20,125,200,25);
	  number4.setFont(f12); 
	  number4.setForeground((Color.black).darker());
	  numPanel.add(number4);	
      inputArea4.setBounds(200,125,120,20);  /// here
	  numPanel.add(inputArea4);	
	  
	  JLabel number5 = new JLabel (mylist.elementAt(5).toString());
	  number5.setBounds(20,150,200,25);
	  number5.setFont(f12); 
	  number5.setForeground((Color.black).darker());
	  numPanel.add(number5);	
      inputArea5.setBounds(200,150,120,20);  /// here
	  numPanel.add(inputArea5);	
	  
	  //departure date ? 
	  
	  JLabel number6 = new JLabel (mylist.elementAt(6).toString());
	  number6.setBounds(20,175,200,25);
	  number6.setFont(f12); 
	  number6.setForeground((Color.black).darker());
	  numPanel.add(number6);	
      inputArea6.setBounds(200,175,120,20);  /// here
	  numPanel.add(inputArea6);	
	  
	  JButton rsltbtn = new JButton("Go");
	  rsltbtn.setBounds(410,120,250,25);
      rsltbtn.setForeground(Color.white);
      rsltbtn.setBackground(((Color.blue).darker().darker()));
      rsltbtn.setMnemonic('R');
	  
	  JButton histbtn = new JButton("Show All Previous Results");
	  histbtn.setBounds(410,170,250,25);
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
      		FileReader fileIn = new FileReader("C:\\Mukta\\current\\clients\\EMeD\\airfarelog");
      		BufferedReader rd = new BufferedReader(fileIn);
      		String line;
      		JTextArea inputArea1 = new JTextArea(500,300);
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
	  areaScrollPane.setPreferredSize(new Dimension(500, 300));
      areaScrollPane.setBounds(200,350,500,300);
      //numPanel.add(areaScrollPane);
      fareframe.getContentPane().add(areaScrollPane);
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
        text3 = inputArea3.getText();
        text4 = inputArea4.getText();
        text5 = inputArea5.getText();
        text6 = inputArea6.getText();
        System.out.println("text1 chk here :"+text1);
        System.out.println("text1 chk here :"+text2);
        //LispSocketAPI mainlc = new LispSocketAPI("camelot.isi.edu", "5679");
        /*
        mainlc.sendLispCommand("<compute><goal><action>monitor-air-fare</action>"
		     + "<param><name>airline</name><value>" + text1  
		     + "</value></param>"
		     + "<param><name>flight-number</name><value>" + text2
		     + "</value></param>"
		     + "<param><name>from-city</name><value>" + text3
		     + "</value></param>"
		     + "<param><name>to-city</name><value>" + text4
		     + "</value></param>"
		     + "<param><name>on-date</name><value>" + text5
		     + "</value></param>"
		     + "<param><name>for-user</name><value>" + text6
		     + "</value></param>"
		     + "</goal></compute>");
      result = mainlc.safeReadLine();
      System.out.println("Result : "+result); 
      System.out.println("text1 :"+text1); */
      // write to a file 
      try{
			FileWriter fileOut = new FileWriter("C:\\Mukta\\current\\clients\\EMeD\\airfarelog",true);
            System.out.println("log file");   
			
			fileOut.write("Airline : "+text1+"\n");
			fileOut.write("Flight-Number : "+text2+"\n");
			fileOut.write("From City : "+text3+"\n");
			fileOut.write("To City : "+text4+"\n");
			fileOut.write("On Date :  "+text5+"\n");
			fileOut.write("For user: "+text6+"\n");
			fileOut.write("Result : Price has dropped by 50$"); 
			fileOut.close();
		}

	catch(IOException ie)
  	{
   	System.out.println(ie.toString());
  	}
      //rslt = new JLabel ("Result: "+result);
	  rslt = new JLabel ("Result: Price has dropped by 50$");
	  rslt.setBounds(20,200,200,25);
	  rslt.setFont(f12); 
	  rslt.setForeground((Color.red).darker());
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
	
	class statusListener implements ActionListener
	{
	public void actionPerformed(ActionEvent e)
	{
		
	FlightStatParser myparser = new FlightStatParser();
      Vector mylist = myparser.getGoals("flightstatus.xml");
      System.out.println("show"+mylist.elementAt(6));
      //ExpectSocketAPI es = new ExpectSocketAPI();
      //System.exit(0);
      
	  
      //ExpectSocketAPI es = new ExpectSocketAPI();
      statusframe.addWindowListener(new WindowAdapter() {
        public void windowClosing(WindowEvent e) {
                  System.exit(0);
        }
      });
      
      statusframe.setSize(1000, 750);
      statusframe.setVisible(true);
      Container cp = statusframe.getContentPane();
      cp.setLayout(null);
      //JPanel numPanel = new JPanel();
      statusPanel.setLayout(null);
      statusPanel.setBounds(100,100,800,600);
      statusPanel.setBackground(Color.lightGray);
        
      statusPanel.setBorder(BorderFactory.createCompoundBorder(
      BorderFactory.createLineBorder(Color.black,4),
      BorderFactory.createEmptyBorder(5,5,5,5)));
      JLabel addnum = new JLabel(mylist.elementAt(0).toString());
      addnum.setBounds(300,5,300,30);
	  addnum.setFont(f16); 
	  addnum.setForeground((Color.blue).darker());
	  
      statusPanel.add(addnum);
      JLabel number1 = new JLabel (mylist.elementAt(1).toString());
	  number1.setBounds(20,50,120,25);
	  number1.setFont(f12); 
	  number1.setForeground((Color.black).darker());
	  statusPanel.add(number1);	
	  statusArea1.setBounds(200,50,120,20);
	  statusPanel.add(statusArea1);
	  
	  
	  JLabel number2 = new JLabel (mylist.elementAt(2).toString());
	  number2.setBounds(20,75,200,25);
	  number2.setFont(f12); 
	  number2.setForeground((Color.black).darker());
	  statusPanel.add(number2);	
	  statusArea2.setBounds(200,75,120,20);  /// here
	  statusPanel.add(statusArea2);	
	  
      JLabel number3 = new JLabel (mylist.elementAt(3).toString());
	  number3.setBounds(20,100,200,25);
	  number3.setFont(f12); 
	  number3.setForeground((Color.black).darker());
	  statusPanel.add(number3);	
      statusArea3.setBounds(200,100,120,20);  /// here
	  statusPanel.add(statusArea3);	
	  
	  JLabel number4 = new JLabel (mylist.elementAt(4).toString());
	  number4.setBounds(20,125,200,25);
	  number4.setFont(f12); 
	  number4.setForeground((Color.black).darker());
	  statusPanel.add(number4);	
      statusArea4.setBounds(200,125,120,20);  /// here
	  statusPanel.add(statusArea4);	
	  
	  JLabel number5 = new JLabel (mylist.elementAt(5).toString());
	  number5.setBounds(20,150,200,25);
	  number5.setFont(f12); 
	  number5.setForeground((Color.black).darker());
	  statusPanel.add(number5);	
      statusArea5.setBounds(200,150,120,20);  /// here
	  statusPanel.add(statusArea5);	
	  
	  //departure date ? 
	  
	  JLabel number6 = new JLabel (mylist.elementAt(6).toString());
	  number6.setBounds(20,175,200,25);
	  number6.setFont(f12); 
	  number6.setForeground((Color.black).darker());
	  statusPanel.add(number6);	
      statusArea6.setBounds(200,175,120,20);  /// here
	  statusPanel.add(statusArea6);	
	  
	  JButton rsltbtn = new JButton("Go");
	  rsltbtn.setBounds(410,120,250,25);
      rsltbtn.setForeground(Color.white);
      rsltbtn.setBackground(((Color.blue).darker().darker()));
      rsltbtn.setMnemonic('R');
	  
	  JButton histbtn = new JButton("Show all previous results");
	  histbtn.setBounds(410,170,250,25);
      histbtn.setForeground(Color.white);
      histbtn.setBackground(((Color.blue).darker().darker()));
      histbtn.setMnemonic('H');
	  statusPanel.add(rsltbtn);
	  statusPanel.add(histbtn);
	  
	  histbtn.addActionListener(new ActionListener() {
      	
      public void actionPerformed(ActionEvent e)
      {
      	
      	try
      	{
      		FileReader fileIn = new FileReader("C:\\Mukta\\current\\clients\\EMeD\\statuslog");
      		BufferedReader rd = new BufferedReader(fileIn);
      		String line;
      		JTextArea inputArea1 = new JTextArea(500,300);
      		statusArea1.setBounds(400,95,100,100);  /// here
	  	  	//numPanel.add(inputArea1);	
      		String str="";
      		while((line = rd.readLine())!= null)
      		{
      			
	            str = str + line +"\n\n"; 		
      			System.out.println(line);
      		}
      System.out.println("new string"+str);
      statusArea1.setText(str);
      statusArea1.setLineWrap(true);
      JScrollPane areaScrollPane = new JScrollPane(statusArea1);
	  areaScrollPane.setVerticalScrollBarPolicy(
	  JScrollPane.VERTICAL_SCROLLBAR_ALWAYS);
	  areaScrollPane.setPreferredSize(new Dimension(500, 300));
      areaScrollPane.setBounds(200,350,500,300);
      //numPanel.add(areaScrollPane);
      statusframe.getContentPane().add(areaScrollPane);
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
        text1 = statusArea1.getText();
        text2 = statusArea2.getText();
        text3 = statusArea3.getText();
        text4 = statusArea4.getText();
        text5 = statusArea5.getText();
        text6 = statusArea6.getText();
        System.out.println("text1 chk here :"+text1);
        System.out.println("text1 chk here :"+text2);
        //LispSocketAPI mainlc = new LispSocketAPI("camelot.isi.edu", "5679");
        /*
        mainlc.sendLispCommand("<compute><goal><action>monitor-air-fare</action>"
		     + "<param><name>airline</name><value>" + text1  
		     + "</value></param>"
		     + "<param><name>flight-number</name><value>" + text2
		     + "</value></param>"
		     + "<param><name>from-city</name><value>" + text3
		     + "</value></param>"
		     + "<param><name>to-city</name><value>" + text4
		     + "</value></param>"
		     + "<param><name>on-date</name><value>" + text5
		     + "</value></param>"
		     + "<param><name>for-user</name><value>" + text6
		     + "</value></param>"
		     + "</goal></compute>");
      result = mainlc.safeReadLine();
      System.out.println("Result : "+result); 
      System.out.println("text1 :"+text1); */
      // write to a file 
      try{
			FileWriter fileOut = new FileWriter("C:\\Mukta\\current\\clients\\EMeD\\statuslog",true);
            System.out.println("log file");   
			
			fileOut.write("Airline : "+text1+"\n");
			fileOut.write("Flight-Number : "+text2+"\n");
			fileOut.write("From City : "+text3+"\n");
			fileOut.write("To City : "+text4+"\n");
			fileOut.write("On Date :  "+text5+"\n");
			fileOut.write("For user: "+text6+"\n");
			fileOut.write("Result : Flight is cancelled"); 
			fileOut.close();
		}

	catch(IOException ie)
  	{
   	System.out.println(ie.toString());
  	}
      //rslt = new JLabel ("Result: "+result);
	  rslt = new JLabel ("Result : Flight is cancelled");
	  rslt.setBounds(20,200,200,25);
	  rslt.setFont(f12); 
	  rslt.setForeground((Color.red).darker());
	  statusPanel.add(rslt); 
	  statusPanel.revalidate();
	  statusPanel.repaint();
	  
       
        
      }});
      
      
      			
      	
     

      
      
      
      //frame.getContentPane().add("Center", new numberPanel(es, null, false));
      //frame.add(cp);
      //getContentpane().add(numPanel);
      
     // numPanel.add(rslt);
             
      cp.add(statusPanel);
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
    
    class schedListener implements ActionListener
	{
	public void actionPerformed(ActionEvent e)
	{
		
		
	  FlightSchedParser myparser = new FlightSchedParser();
      Vector mylist = myparser.getGoals("flightsched.xml");
      System.out.println("show"+mylist.elementAt(6));
      //ExpectSocketAPI es = new ExpectSocketAPI();
      schedframe.addWindowListener(new WindowAdapter() {
        public void windowClosing(WindowEvent e) {
                  System.exit(0);
        }
      });
      
      schedframe.setSize(1000, 750);
      schedframe.setVisible(true);
      Container cp = schedframe.getContentPane();
      cp.setLayout(null);
      //JPanel numPanel = new JPanel();
      schedPanel.setLayout(null);
      schedPanel.setBounds(100,100,800,600);
      schedPanel.setBackground(Color.lightGray);
        
      schedPanel.setBorder(BorderFactory.createCompoundBorder(
      BorderFactory.createLineBorder(Color.black,4),
      BorderFactory.createEmptyBorder(5,5,5,5)));
      JLabel addnum = new JLabel(mylist.elementAt(0).toString());
      addnum.setBounds(300,5,300,30);
	  addnum.setFont(f16); 
	  addnum.setForeground((Color.blue).darker());
	  
      schedPanel.add(addnum);
      JLabel number1 = new JLabel (mylist.elementAt(1).toString());
	  number1.setBounds(20,50,120,25);
	  number1.setFont(f12); 
	  number1.setForeground((Color.black).darker());
	  schedPanel.add(number1);	
	  schedArea1.setBounds(200,50,120,20);
	  schedPanel.add(schedArea1);
	  
	  
	  JLabel number2 = new JLabel (mylist.elementAt(2).toString());
	  number2.setBounds(20,75,200,25);
	  number2.setFont(f12); 
	  number2.setForeground((Color.black).darker());
	  schedPanel.add(number2);	
	  schedArea2.setBounds(200,75,120,20);  /// here
	  schedPanel.add(schedArea2);	
	  
      JLabel number3 = new JLabel (mylist.elementAt(3).toString());
	  number3.setBounds(20,100,200,25);
	  number3.setFont(f12); 
	  number3.setForeground((Color.black).darker());
	  schedPanel.add(number3);	
      schedArea3.setBounds(200,100,120,20);  /// here
	  schedPanel.add(schedArea3);	
	  
	  JLabel number4 = new JLabel (mylist.elementAt(4).toString());
	  number4.setBounds(20,125,200,25);
	  number4.setFont(f12); 
	  number4.setForeground((Color.black).darker());
	  schedPanel.add(number4);	
      schedArea4.setBounds(200,125,120,20);  /// here
	  schedPanel.add(schedArea4);	
	  
	  JLabel number5 = new JLabel (mylist.elementAt(5).toString());
	  number5.setBounds(20,150,200,25);
	  number5.setFont(f12); 
	  number5.setForeground((Color.black).darker());
	  schedPanel.add(number5);	
      schedArea5.setBounds(200,150,120,20);  /// here
	  schedPanel.add(schedArea5);	
	  
	  //departure date ? 
	  
	  JLabel number6 = new JLabel (mylist.elementAt(6).toString());
	  number6.setBounds(20,175,200,25);
	  number6.setFont(f12); 
	  number6.setForeground((Color.black).darker());
	  schedPanel.add(number6);	
      schedArea6.setBounds(200,175,120,20);  /// here
	  schedPanel.add(schedArea6);	
	  
	  JButton rsltbtn = new JButton("Go");
	  rsltbtn.setBounds(410,120,250,25);
      rsltbtn.setForeground(Color.white);
      rsltbtn.setBackground(((Color.blue).darker().darker()));
      rsltbtn.setMnemonic('R');
	  
	  JButton histbtn = new JButton("Show All Previous results");
	  histbtn.setBounds(410,170,250,25);
      histbtn.setForeground(Color.white);
      histbtn.setBackground(((Color.blue).darker().darker()));
      histbtn.setMnemonic('H');
	  schedPanel.add(rsltbtn);
	  schedPanel.add(histbtn);
	  
	  histbtn.addActionListener(new ActionListener() {
      	
      public void actionPerformed(ActionEvent e)
      {
      	
      	try
      	{
      		FileReader fileIn = new FileReader("C:\\Mukta\\current\\clients\\EMeD\\schedlog");
      		BufferedReader rd = new BufferedReader(fileIn);
      		String line;
      		JTextArea schedArea1 = new JTextArea(500,300);
      		schedArea1.setBounds(400,95,100,100);  /// here
	  	  	//numPanel.add(inputArea1);	
      		String str="";
      		while((line = rd.readLine())!= null)
      		{
      			
	            str = str + line +"\n\n"; 		
      			System.out.println(line);
      		}
      System.out.println("new string"+str);
      schedArea1.setText(str);
      schedArea1.setLineWrap(true);
      JScrollPane areaScrollPane = new JScrollPane(schedArea1);
	  areaScrollPane.setVerticalScrollBarPolicy(
	  JScrollPane.VERTICAL_SCROLLBAR_ALWAYS);
	  areaScrollPane.setPreferredSize(new Dimension(500, 300));
      areaScrollPane.setBounds(200,350,500,300);
      //numPanel.add(areaScrollPane);
      schedframe.getContentPane().add(areaScrollPane);
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
        text1 = schedArea1.getText();
        text2 = schedArea2.getText();
        text3 = schedArea3.getText();
        text4 = schedArea4.getText();
        text5 = schedArea5.getText();
        text6 = schedArea6.getText();
        System.out.println("text1 chk here :"+text1);
        System.out.println("text1 chk here :"+text2);
        //LispSocketAPI mainlc = new LispSocketAPI("camelot.isi.edu", "5679");
        /*
        mainlc.sendLispCommand("<compute><goal><action>monitor-air-fare</action>"
		     + "<param><name>airline</name><value>" + text1  
		     + "</value></param>"
		     + "<param><name>flight-number</name><value>" + text2
		     + "</value></param>"
		     + "<param><name>from-city</name><value>" + text3
		     + "</value></param>"
		     + "<param><name>to-city</name><value>" + text4
		     + "</value></param>"
		     + "<param><name>on-date</name><value>" + text5
		     + "</value></param>"
		     + "<param><name>for-user</name><value>" + text6
		     + "</value></param>"
		     + "</goal></compute>");
      result = mainlc.safeReadLine();
      System.out.println("Result : "+result); 
      System.out.println("text1 :"+text1); */
      // write to a file 
      try{
			FileWriter fileOut = new FileWriter("C:\\Mukta\\current\\clients\\EMeD\\schedlog",true);
            System.out.println("log file");   
			
			fileOut.write("Airline : "+text1+"\n");
			fileOut.write("Flight-Number : "+text2+"\n");
			fileOut.write("From City : "+text3+"\n");
			fileOut.write("To City : "+text4+"\n");
			fileOut.write("On Date :  "+text5+"\n");
			fileOut.write("For user: "+text6+"\n");
			fileOut.write("Result : Scheduled time has not changed"); 
			fileOut.close();
		}

	catch(IOException ie)
  	{
   	System.out.println(ie.toString());
  	}
      //rslt = new JLabel ("Result: "+result);
	  rslt = new JLabel ("Result : Scheduled time has not changed");
	  rslt.setBounds(20,200,250,100);
	  rslt.setFont(f12); 
	  rslt.setForeground((Color.red).darker());
	  schedPanel.add(rslt); 
	  schedPanel.revalidate();
	  schedPanel.repaint();
	  
       
        
      }});
      
      
      			
      	
     

      
      
      
      //frame.getContentPane().add("Center", new numberPanel(es, null, false));
      //frame.add(cp);
      //getContentpane().add(numPanel);
      
     // numPanel.add(rslt);
             
      cp.add(schedPanel);
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
    
    
    
    
	
	public void actionPerformed(ActionEvent e)
	{
		  System.exit(0);
	}	  
	
	public static void main(String args[] )
	{
		EXPECTFlightAgenttry sng = new EXPECTFlightAgenttry();
		
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