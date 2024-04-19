//File: data.java
//
// Copyright (C) 1999 by Jihie Kim
// All Rights Reserved
//

package experiment;

import java.io.*;
import java.util.Date;
import java.util.Calendar;

public class saveData {
  static FileWriter ostream;
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

  static public void record (String info) {
    StringReader istream;
    int ch;
    Date d = new Date();

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
