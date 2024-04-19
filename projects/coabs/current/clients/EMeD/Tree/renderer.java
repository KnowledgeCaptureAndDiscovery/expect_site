package Tree;

import java.io.*;
import java.util.*;
import com.icl.saxon.*;
import org.xml.sax.*;
import org.xml.sax.helpers.*;
import org.apache.xerces.parsers.*;

public class renderer extends Distributor {
  private static final String 
        DEFAULT_PARSER_NAME = "org.apache.xerces.parsers.SAXParser";

  Parser parser;
  Locator locator;
  PrintStream o = System.err;

public int runFromNamedParser(InputSource in, String parserClassName) {            
    // Create a new parser instance 
  //parser = ParserManager.makeParser(parserClassName);
    parser = ParserManager.makeParser(DEFAULT_PARSER_NAME);
    if (parser!=null)
      parser.setDocumentHandler(this);
    else {
      try {
        o.println("No XML Parser established\n");
      } catch (Exception e) {}
      return(4);
    }
    try {
      parser.parse(in);           // this is the real work!
      System.out.println("parsing here");
      return(0);
    }
    catch (java.io.IOException e) {
      try {
        o.println("Input/Output error during parsing\n");
        o.println("Details: " + e.getMessage() + "\n");
      } catch (Exception e2) {}
      return(3);
    }
    catch (SAXException e) {
      try {
        o.println("Tree renderer: Unable to parse XML document\n");
	printInput(in.getByteStream());
        o.println("Problem: " + e.getMessage() + "\n");
        if (locator!=null) {
	o.println("  URL:    " + locator.getSystemId() + "\n");
	o.println("  Line:   " + locator.getLineNumber() + "\n");
	o.println("  Column: " + locator.getColumnNumber() + "\n");
        }
      } catch (Exception e2) {};
      return(2);
    }   
  }

 public static String readFileToString(String fileName) {
    int ch;
    String contents;
    
    try {
	FileReader istream = new FileReader(fileName);
	StringWriter ostream = new StringWriter();
	while ((ch = istream.read()) != -1) {
	   ostream.write(ch);
	}
	istream.close();
	contents = ostream.toString();
	ostream.close();
    } catch (IOException e) {
	System.err.println(e);
	return("");
	}
    return(contents);
    }

  public String removeExtraSpace(String input) {
    String result = "";
    int i;
    boolean space = false;
    if (input == null) return null;
    for (i=0; i<input.length();i++) {
      if (input.charAt(i) == ' ') {
	if (!space) {
	  result = result + input.substring(i,i+1);
	  space = true;
	}
      }
      else {
	space = false;
	result = result + input.substring(i,i+1);
      }
      
    }
    result = result.trim();
    if (result.equals("NIL")) return "";
    else if (result.equals("UNDEFINED")) return result;
    else return result.toLowerCase();
  } 
 
  class passiveHandler extends ElementHandlerBase {
    public void startElement(ElementInfo e) throws SAXException {
    }
    public void endElement(ElementInfo e) throws SAXException {
    }
  }

  public void printInput (InputStream in) {
    BufferedReader inStream = new BufferedReader (new InputStreamReader (in));
    StringBuffer result = new StringBuffer();
    String line;
    System.out.println(" input line 0");
    try {
      while (true) {
	System.out.println(" input line");
	line = inStream.readLine(); 
	result.append(line);
      }
    }
    catch ( IOException e ) {
      o.println ("eol or lisp result read error");
    }
    System.out.println(result.toString());
        
  }
  
}
