//File: saveData.java
//
// Author: Jihie Kim
// Date : 1999
//

package experiment;

import java.io.*;
import java.util.Date;
import java.util.Calendar;

public class saveData {
  static FileWriter ostream= null;
  static public  void init(String filename) {
    Calendar rightNow = Calendar.getInstance();
    try {
      if (filename.equals(""))
        ostream = new FileWriter ("experiment/log"+
			    rightNow.get(Calendar.HOUR)+
			    rightNow.get(Calendar.MINUTE)+
			    rightNow.get(Calendar.SECOND));
      else ostream = new FileWriter (filename);
    }
    catch (IOException e) {
      System.err.println(e);
    }
  }

  static public  void init(String filename, String directory) {
    Calendar rightNow = Calendar.getInstance();
    try {
      if (filename.equals(""))
        ostream = new FileWriter (directory +"log"+
			    rightNow.get(Calendar.HOUR)+
			    rightNow.get(Calendar.MINUTE)+
			    rightNow.get(Calendar.SECOND));
      else ostream = new FileWriter (directory +filename);
    }
    catch (IOException e) {
      System.err.println(e);
    }
  }

  static public void record (String info) {
    StringReader istream;
    int ch;
    Date d = new Date();
    if (ostream == null) // not initialized yet
      return;
    try {
      istream = new StringReader(info+"\n   at "+d.toString()+"\n\n");
      while  ((ch = istream.read()) != -1) {
        ostream.write (ch);
      }
      istream.close();
    }
    catch (IOException e) {
      System.err.println(e);
    }

  }

  static public void end () {
    try {
      ostream.close();
    }
    catch (IOException e) {
      System.err.println(e);
    }
  }

}
