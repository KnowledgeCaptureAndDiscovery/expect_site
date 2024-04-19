package com.icl.saxon;

import java.io.*;
import java.net.*;
import org.xml.sax.InputSource;

// Copyright © International Computers Limited 1998
// See conditions of use

/**
  * <p>This class allows a SAXON application to encapsulate information
  * about an input source in a single object, which may include
  * a public identifier, a system identifier, a byte stream (possibly
  * with a specified encoding), a character stream, or a file.</p>
  *
  * <p>Most of the functionality is inherited directly from the SAX
  * InputSource class; the additional functionality offered by
  * ExtendedInputSource is to allow the input source to be specified as
  * a File object. This is translated to a system identifier internally.</p>
  *
  * <p>ExtendedInputSource can be used anywhere that the SAX
  * InputSource class is used, it is not dependent on any other SAXON
  * components.</p>
  *
  * @author Michael Kay (M.H.Kay@eng.icl.co.uk)
  */
  
public class ExtendedInputSource extends org.xml.sax.InputSource {

  /**
    * Create a new input source from a File. Note that the directory
    * in which the file occurs will be used as the base for resolving any
    * system identifiers encountered within the XML document
    *
    * <p>Example of use:<BR>
    * parser.parse(new ExtendedInputSource(new File("test.xml")))</p>
    * @param file A File object identifying the XML input file
    *
    */

  public ExtendedInputSource (File file)
  {
    super(CreateURL(file));
  }

  private static String CreateURL(File file)
  {
    String path = file.getAbsolutePath();
    // Following code is cribbed from MSXML
    URL url = null;
    try 
        {
            url = new URL(path);
        } 
    catch (MalformedURLException ex) 
        {
            try 
            {
                // This is a bunch of weird code that is required to
                // make a valid URL on the Windows platform, due
                // to inconsistencies in what getAbsolutePath returns.
                String fs = System.getProperty("file.separator");
                if (fs.length() == 1) 
                {
                    char sep = fs.charAt(0);
                    if (sep != '/')
                        path = path.replace(sep, '/');
                    if (path.charAt(0) != '/')
                        path = '/' + path;
                }
                path = "file://" + path;
                url = new URL(path);
            } 
            catch (MalformedURLException e) 
            {
                System.err.println("Cannot create url for: " + path);
                System.exit(0);
            }
        }   
     return( url.toString() );
  }


}
