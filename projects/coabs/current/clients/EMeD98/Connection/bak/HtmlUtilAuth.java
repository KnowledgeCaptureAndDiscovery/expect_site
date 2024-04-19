package Connection;

import java.io.*;
import java.util.*;
import java.net.*;

public class HtmlUtilAuth {
  static boolean debug = false;
  static int UNAUTHORIZED = 401;


  public static Strings post(String serverAndPort, 
		      String fileIncludingLeadingBackslash,
		      Hashtable properties, 
		      String auth_data)
  {
    Strings result = new Strings();

    try {
      PrintStream out = System.out;

      URL url = new URL("http://"+serverAndPort+fileIncludingLeadingBackslash);
      HttpURLConnection connection = (HttpURLConnection) url.openConnection();
      connection.setRequestProperty("Authorization",auth_data);
      if (connection.getResponseCode() == UNAUTHORIZED) {
	out.println(" Unauthorized access");
	return null;
      }
      html32 t = new html32(connection.getInputStream());
      SimpleNode n = t.html();
      if(debug) {
	out.println("begin printing HTML.");
	n.dump("");
	out.println("end printing HTML.");
      }

      // Extract the form data from the HTML page.
      HtmlForm form = new HtmlForm(n,fileIncludingLeadingBackslash);
      if(debug){out.println(form);}

      // Fill in the form.
      Enumeration e=properties.keys();
      while(e.hasMoreElements()) {
	String name = (String) e.nextElement();
	String value = (String) properties.get(name);
	form.set(name,value);
      }
      if(debug){out.println(form);}

      URL url2 = new URL("http://"+serverAndPort+fileIncludingLeadingBackslash);
      String query = form.generateQuery();
      if(debug){out.println(query);}

      HttpURLConnection c = (HttpURLConnection) url2.openConnection();
      c.setRequestProperty("Authorization",auth_data);
      c.setDoOutput(true);
      c.setRequestProperty("Content-type","application/x-www-form-urlencoded");
      c.setRequestProperty("Content-length",Integer.toString(query.length()));
      DataOutputStream outStream = new DataOutputStream(c.getOutputStream());
      outStream.writeBytes(query);
      outStream.writeBytes("\n");
      outStream.close();

      InputStream raw = c.getInputStream();
      BufferedReader inStream = new BufferedReader(new InputStreamReader(raw));
      if(debug){out.println(c.getContentType());}
      if(debug){out.println(c.getContentLength());}
      String inputLine;
      while(true) {
	inputLine = inStream.readLine();
	if(inputLine==null){break;}
	inputLine = inputLine + "\n";
	if(debug){out.println("inputLine:"+inputLine);}
	result.items.addElement(inputLine);
      }
      inStream.close();
      return result;
    }
    catch (Exception e) {
      System.out.println("Oops.");
      System.out.println(e.getMessage());
      System.out.println(" please try again..");
      System.exit(1);
      //e.printStackTrace();
    }
    return result;
  }


}
