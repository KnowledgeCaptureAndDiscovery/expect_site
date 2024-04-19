package xml2jtml;

import java.io.*;
import java.util.*;
import com.icl.saxon.*;
import org.xml.sax.*;
import org.xml.sax.helpers.*;

public class renderer extends Distributor {

Parser parser;
Locator locator;
PrintStream o = System.err;

public int runFromNamedParser(InputSource in, String parserClassName) {            
    // Create a new parser instance 
    parser = ParserManager.makeParser(parserClassName);
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
        o.println("Unable to parse XML document\n");
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
    
}