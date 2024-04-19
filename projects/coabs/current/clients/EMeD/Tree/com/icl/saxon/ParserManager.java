package com.icl.saxon;

import java.lang.ClassNotFoundException;
import java.lang.IllegalAccessException;
import java.lang.InstantiationException;
import java.lang.SecurityException;
import java.lang.ClassCastException;

import java.io.*;
import java.util.Properties;

import org.xml.sax.Parser;

// Copyright © International Computers Limited 1998
// (except sections copied from public SAX distribution)
// See conditions of use


/**
  * ParserManager allows you to register a SAX-compliant XML parser as your
  * default parser and use it whenever you run a SAXON application.<P>
  *
  * There is a command-line interface to register your preferred
  * SAX parser, as follows:<P>
  * <CODE>    java com.icl.saxon.ParserManager <I>parser-class</I></CODE><P>
  *
  * There is also an interface which is used internally by SAXON,
  * and which can be used by any SAX application, to discover the
  * preferred parser and instantiate it.
  *
  * @author Michael H. Kay (M.H.Kay@eng.icl.co.uk)
  * Version 12 May 1998
  */
  
public class ParserManager {

  /**
    * Instantiate a SAX parser. The parser chosen is determined
    * by reading a saxon.ini file which was previously set up by calling
    * ParserManager from the command line.
    */

    public static Parser makeParser ()
    {
        String p = getParserClass();
        if (p!=null) return makeParser(p);
        return null;
    }
        
    public static String getParserClass ()
    {
        String className;
        try {
            File homedir = new File(System.getProperty("user.home"));
            File inifile = new File(homedir, "saxon.ini");
            FileInputStream in = new FileInputStream(inifile);
            Properties props = new Properties();
            props.load(in);
            in.close();
            className = props.getProperty("parser");
            return className;
        }
        catch (Exception e) {
            System.err.println("Cannot read parser property from saxon.ini file");
            System.err.println(e);
            System.err.println("Run \"java com.icl.saxon.ParserManager <parser-class>\" to register a parser");
            System.err.println("The saxon.ini file should be found in directory " + System.getProperty("user.home"));
        }
        return null;
    }

  /**
    * Create a new SAX parser object using the class name provided.<br>
    *
    * The named class must exist and must implement the
    * org.xml.sax.Parser interface.<br>
    *
    * This method returns a parser but does not register it
    * as the default parser.
    *
    * @param className A string containing the name of the
    *   SAX parser class, for example "com.microstar.sax.LarkDriver"
    * 
    */
  public static Parser makeParser (String className)
  {
    try {
        return (Parser)(Class.forName(className).newInstance());
    }
    catch (ClassNotFoundException e) {
        System.err.println("Failed to load SAX parser");
        System.err.println("Class " + className + " not found: check your CLASSPATH");
    }
    catch (IllegalAccessException e) {
        System.err.println("Failed to load SAX parser");
        System.err.println("You do not have permission to load class " + className);
    }
    catch (InstantiationException e) {
        System.err.println("Failed to load SAX parser");
        System.err.println("Cannot instantiate class " + className);
    }
    catch (ClassCastException e) {
        System.err.println("Failed to load SAX parser");
        System.err.println("Class " + className + " is not a SAX parser");
    }
    return null;
  }

  /**
    * Main program registers the default parser<BR>
    * Usage: <B>java com.icl.saxon.ParserManager <i>parser-class</i></B>
    */

    public static void main (String args[])
        throws java.lang.Exception
    {
        				// Check the command-line arguments.
        if (args.length != 1) {
            System.err.println("Usage: java com.icl.saxon.ParserManager parser-class");
            System.exit(1);
        }

        Properties props = new Properties();

        // test that the class is a parser
        Parser parser = makeParser(args[0]);

        // save the specified parser name in a .INI file

        if (parser!=null) {
            props.put("parser", args[0]);

            File homedir = new File(System.getProperty("user.home"));
            File inifile = new File(homedir, "saxon.ini");
            FileOutputStream out = new FileOutputStream(inifile);
            props.save(out, "saxon.ini created by ParserManager");
            out.close();
            System.err.println("Parser registered successfully. See saxon.ini file in " + homedir);
        }
        System.exit(0);
    }

}

