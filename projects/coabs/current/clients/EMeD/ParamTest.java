import java.applet.*; 
import java.awt.*; 

public class ParamTest extends Applet { 

   public String myString;
   public void paint(Graphics g) { 

      String myFont   = getParameter("font"); 
     // String myString = getParameter("string"); 
      int mySize      = Integer.parseInt(getParameter("size")); 
	  //myString = this.setInfo();		
      Font f = new Font(myFont, Font.BOLD, mySize); 
      g.setFont(f); 
      g.setColor(Color.red); 
      g.drawString(myString, 20, 20); 

   } 

	public String setInfo(String no)
	{
		myString = new String(no);
		return myString;
	}

} 















