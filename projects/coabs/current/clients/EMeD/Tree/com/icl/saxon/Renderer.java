package com.icl.saxon;
//import com.icl.saxon.*;

// Copyright © International Computers Limited 1998
// See conditions of use

import org.xml.sax.*;

import java.net.*;
import java.util.*;
import java.io.*;

/**
  * <B>Renderer</B> specialises Distributor for applications that generate
  * output (especially XML or HTML output) from the XML input.<p>
  *
  * It supplements the services of Distributor as follows:<P>
  * <UL><LI>A number of standard element handlers are provided to perform
  * the most common kinds of output generation needed to display or
  * transform XML documents.</LI>
  * <LI>The default element handler copies the element (tag, attributes,
  * and content) to the output Writer</LI>
  * <LI>There is a main program to allow Renderer to be called from the
  * command line. The result of doing so is to re-create the XML document on the
  * standard output.</LI>
  * </UL>
  * @author M.H.Kay (M.H.Kay@eng.icl.co.uk)
  * @version 12 May 1998
  */
  
public class Renderer extends Distributor {

    /**
    * Main program <BR>
    * Can be used directly from the command line, format:<BR>
    *     java com/icl/saxon/Renderer <I>input-file</I> &gt;<I>output-file</I><BR>
    * This interface is provided largely for test purposes.
    * The program takes one argument: the name of the input file containing
    * the XML input. It produces a copy of the XML (minus attributes)
    * on the standard output.
    */
    
    public static void main (String args[])
        throws java.lang.Exception
    {
        long startTime = (new Date()).getTime();
        
				// Check the command-line arguments.
        if (args.length != 1) {
            System.err.println("Usage: java com.icl.saxon.Renderer input-file >output-file");
            System.exit(1);
        }

				// Create a new SAX Document Handler.
        Renderer app = new Renderer();

	            // Invoke the application.
        int result = app.run ( new ExtendedInputSource(new File(args[0])) );

                // Exit
        long endTime = (new Date()).getTime();
        System.err.println("Elapsed time: " + (endTime-startTime) + " milliseconds");
        System.exit(result);
    }

    public Renderer()
    {
        setDefaultHandler(new ElementCopier());
    }

    /**
    * Establish a prefix and suffix to be used for the rendition
    * of a given XML element type.<BR>
    * The "before" and "after" strings can include textual substitution
    * of attributes or pseudo-attributes. Textual substitution is invoked
    * by including a pattern of the form «ELEMENT/ATTRIBUTE» (between
    * guillemots or angle quotation marks as shown). The special attribute
    * names "#" (element number) and "*" (element content) are recognised.
    * @param element The tag of the specified element; or a pattern of
    * the form "PARENT/CHILD"
    * @param before Text to be output before the contents of the element.
    * @param after Text to be output after the contents of the element.
    */

    public void setItemRendition( String element,
                                  String before,
                                  String after )
    {
        // if parameter substitution in use, ensure appropriate options are set
        
        if (before.indexOf('«')>=0 || after.indexOf('«')>=0)
            setOption(RETAIN_ATTRIBUTES, true);
        if (before.indexOf("/*»")>=0 || after.indexOf("/*»")>=0)
            setOption(RETAIN_CONTENT, true);
            
        setHandler( element, new ItemRenderer( before, after ) );
    }

   /**
    * Establish strings to be used for the rendition of a consecutive
    * sequence of instances of a given XML element type.
    * @param element The tag of the specified element, or a pattern
    * of the form "PARENT/CHILD"
    * @param before Text to be output before the contents of the first (or only) element in a sequence.
    * @param between Text to be output between consecutive instances of the element.
    * @param after Text to be output after the contents of the last (or only) element in a sequence.
    */
    public void setGroupRendition( String element,
                                   String before,
                                   String between,
                                   String after )
    {
        setHandler( element, new GroupRenderer( before, between, after ) );
    }

    /**
    * Establish automatic numbering on an element. The numbers may be
    * accessed as a special attribute named "#".
    * @param element The element to be automatically numbered. May be in
    * the form "PARENT/CHILD".
    * @param baseElement The ancestor element that causes numbering to
    * reset to one.
    * @param concatenate True if numbers are to be concatenated with those
    * of the base element
    */
    
    public void setNumbering ( String element,
                               String baseElement,
                               boolean concatenate )
    {
        setOption(RETAIN_ATTRIBUTES, true);  // because otherwise numbering is no use
        setHandler ( element,
                    new NumberHandler( baseElement, concatenate ) );
    }

    /**
    * Establish sorting on the elements within a group.<br>
    * A group is defined as a number of consecutive elements of
    * the same type, subordinate to the same parent element.
    * 
    * @param element The tag of the elements to be sorted. May be in
    * the form "PARENT/CHILD".<BR>
    * <B>Restriction:</B>Do not use this for an element that can
    * be nested within itself. The effect of doing so is undefined.
    * @param sortkey The attribute on which the elements will be
    * sorted. This may be an actual XML attribute in the input
    * document, or a pseudo-attribute created using setExtendedAttribute().
    * It may also be the special value "*" which refers to the character
    * content of the element. The attribute is examined at the end of
    * each element, so it is possible to set up attributes while the
    * element is processed, for example, while processing a child element.
    * @param before A string to be output before the first element in
    * a sorted group of elements
    * @param between A string to be output after each element in the sorted
    * output, other than the last
    * @param after A string to be output after the last element in the
    * sorted group of elements
    *
    */

    public void setSorter (     String element,
                                String sortkey,
                                String before,
                                String between,
                                String after )
    {
        setHandler ( element,
            new ElementSorter( sortkey, before, between, after )
                    );

        // ensure that appropriate options are set            
        if (sortkey.equals("*"))
            setOption(RETAIN_CONTENT, true);
        else
            setOption(RETAIN_ATTRIBUTES, true);
    }                              
           
    /**
    * Escape special characters for display.
    * @param ch The character array containing the string
    * @param start The start position of the input string within the character array
    * @param length The length of the input string within the character array
    * @return The XML/HTML representation of the string<br>
    * This static method converts a Unicode string to a string containing
    * only ASCII characters, in which non-ASCII characters are represented
    * by the usual XML/HTML escape conventions (for example, "&lt;" becomes "&amp;lt;").
    * Note: if the input consists solely of ASCII or Latin-1 characters,
    * the output will be equally valid in XML and HTML. Otherwise it will be valid
    * only in XML.
    */
    public static String escape(char ch[], int start, int length)
    {        
        // Use a character array for performance reasons;
        // allocate size on the basis that it might be all non-ASCII
        
        char[] out = new char[length*8]; // allow for worst case
        int o = 0;
        for (int i = start; i < start+length; i++) {
            if (ch[i]=='<') {("&lt;").getChars(0,4,out,o); o+=4;}
            else if (ch[i]=='>') {("&gt;").getChars(0,4,out,o); o+=4;}
            else if (ch[i]=='&') {("&amp;").getChars(0,5,out,o); o+=5;}
            else if (ch[i]=='\"') {("&#34;").getChars(0,5,out,o); o+=5;}
            else if (ch[i]=='\'') {("&#39;").getChars(0,5,out,o); o+=5;}
            else if (ch[i]<0x7f) {out[o]=ch[i]; o++;}
            else {
                String dec = "&#" + Integer.toString((int)ch[i]) + ';';
                dec.getChars(0, dec.length(), out, o);
                o+=dec.length();
            }
        }
        return new String(out, 0, o);
    }

    /**
    * Escape special characters in a String value.
    * @param in The input string
    * @return The XML representation of the string<br>
    * This static method converts a Unicode string to a string containing
    * only ASCII characters, in which non-ASCII characters are represented
    * by the usual XML/HTML escape conventions (for example, "&lt;" becomes
    * "&amp;lt;").<br>
    * Note: if the input consists solely of ASCII or Latin-1 characters,
    * the output will be equally valid in XML and HTML. Otherwise it will be valid
    * only in XML.
    */
    public static String escape(String in)
    {
        return escape( in.toCharArray(), 0, in.length() );
    }

} 
