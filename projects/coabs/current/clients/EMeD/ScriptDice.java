// Dice for JavaScript -- Williams 
import java.applet.*;
import java.awt.*;

public class ScriptDice extends Applet implements Runnable
  {
  public int d1=0;
  public int d2=0;  // die values
  java.util.Random randobj = new java.util.Random();
  Thread thread;
  int delay;
  int rolls;
  
// standard routine
 public String getAppletInfo()
   {
   return "ScriptDice 1.0 by Al Williams";
   }

// helper routine to read integers
  public int getIntParameter(String key,int defvalue)
    {
    String v = this.getParameter(key);
    try {
      return Integer.parseInt(v);
      }
    catch (Exception e) { return defvalue; }
    }
// Get started
  public void init()
    {
    delay=getIntParameter("delay",250);
    rolls=getIntParameter("rolls",10);
    }

// draw pips on a die
  private void pip(Graphics g, int n,int x0,int y0,int w,int h)
    {
    int pipw=10,piph=10;
    switch (n)
      {
      case 1:
	g.fillOval(w/2+x0-pipw/2,h/2+y0-piph/2,pipw,piph);
        break;
      case 2:
        g.fillOval(x0+pipw,y0+piph,pipw,piph);
        g.fillOval(x0+w-2*pipw,y0+h-2*piph,pipw,piph);
        break;
      case 3:
        g.fillOval(w/2+x0-pipw/2,h/2+y0-piph/2,pipw,piph);
        g.fillOval(x0+pipw,y0+piph,pipw,piph);
        g.fillOval(x0+w-2*pipw,y0+h-2*piph,pipw,piph);
	break;
      case 4:
        g.fillOval(x0+pipw,y0+piph,pipw,piph);
        g.fillOval(x0+w-2*pipw,y0+h-2*piph,pipw,piph);
        g.fillOval(x0+w-2*pipw,y0+piph,pipw,piph);
        g.fillOval(x0+piph,y0+h-2*piph,pipw,piph);
        break;
      case 5:
        g.fillOval(w/2+x0-pipw/2,h/2+y0-piph/2,pipw,piph);
        g.fillOval(x0+pipw,y0+piph,pipw,piph);
        g.fillOval(x0+w-2*pipw,y0+h-2*piph,pipw,piph);
        g.fillOval(x0+w-2*pipw,y0+piph,pipw,piph);
        g.fillOval(x0+piph,y0+h-2*piph,pipw,piph);
        break;

      case 6:
        g.fillOval(x0+pipw,y0+piph,pipw,piph);
        g.fillOval(x0+w-2*pipw,y0+h-2*piph,pipw,piph);
        g.fillOval(x0+w-2*pipw,y0+piph,pipw,piph);
        g.fillOval(x0+piph,y0+h-2*piph,pipw,piph);
        g.fillOval(w/2+x0-pipw/2,y0+piph,pipw,piph);
        g.fillOval(w/2+x0-pipw/2,y0+h-2*piph,pipw,piph);
        break;

      }
    }
    
  public void paint(Graphics g)
    {
    Color white=new Color(0xFF,0xFF,0xFF);
    Color black=new Color(0,0,0);
    Dimension d=getSize();
    g.setColor(white);
    g.fillRect(0,0,d.width,d.height);
    g.setColor(black);
    g.drawRect(1,1,d.width/2-2,d.height-2);
    g.drawRect(d.width/2+1,1,d.width/2-2,d.height-2);
    // draw pips
    pip(g,d1,1,1,d.width/2-2,d.height-2);
    pip(g,d2,d.width/2+1,1,d.width/2-2,d.height-2);
    }
    
// make random numbers
  public int rand(int lo, int hi)
    {
    int mx = hi - lo + 1;
    int n = randobj.nextInt() % mx;
    if (n < 0) n = -n;  // absolute value
    return lo + n;
    }

// public interface to roll dice
   synchronized public int roll()
    {
    thread = new Thread(this);
    thread.start();
    try 
      {
      wait();
      }
    catch (InterruptedException e)
      {
      }
    d1=rand(1,6);
    d2=rand(1,6);
    repaint();
    return d1+d2;
    }
    
// this thread routine does the rolling
  synchronized public void run()
    {
    int count=rolls;
    while (--count!=0) 
      {
      d1=rand(1,6);
      d2=rand(1,6);
      repaint();
      // sleep
    try 
      {
      thread.sleep(delay);
      }
    catch (InterruptedException e)
      {
      }
    }
    // signal main thread
    notify();
  }
}
    