package com.icl.saxon;

import java.io.*;
import java.util.Hashtable;

// Copyright © International Computers Limited 1998
// See conditions of use

/**
  * Class XRenderer<BR>
  * A wrapper class to provide the same services as Renderer, but
  * via an interface that can easily be used from ActiveX clients
  * such as VBScript
  */
  
public class XRenderer
{
    private Renderer renderer = new Renderer();
	private Hashtable buckets = new Hashtable();
	private String errorText = "";
   
    /**
    * Create an output bucket for a particular element type
    * @param element The selected element type, or a pattern in
    * the form "PARENT/CHILD"
    * @param bucketName A string to identify this output bucket,
    * so that its contents can be retrieved later using readBucket()
    */
    
    public void selectBucket( String element, String bucketName )
    {
        StringWriter sw = new StringWriter();
        renderer.setWriter( element, sw );
        buckets.put( bucketName, sw );
    }
    
    /**
    * Read the contents of an output bucket
    * @param bucketName The name of the bucket to be read. This must
    * be the name of a bucket established earlier using selectBucket()
    */
 
    public String readBucket( String bucketName )
    {
        StringWriter sw = (StringWriter)buckets.get(bucketName);
        if (sw==null) return "";
        return sw.toString();
    } 

    /**
    * Supply a prefix and suffix to be used for the rendition
    * of a given XML element type.
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
        renderer.setItemRendition( element, before, after );
    }

   /**
    * Supply strings to be used for the rendition of a consecutive
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
        renderer.setGroupRendition(element, before, between, after );
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
        renderer.setNumbering ( element, baseElement, concatenate );
    }

    /**
    * Establish sorting on the elements within a group.<br>
    * A group is defined as a number of consecutive elements of
    * the same type, subordinate to the same parent element.
    * @param element The tag of the elements to be sorted. May be in
    * the form "PARENT/CHILD".<br>
    * <B>Restriction:</B>Do not use this for an element that can
    * be nested within itself. The effect of doing so is undefined.
    * @param sortkey The attribute on which the elements will be
    * sorted. This may be an actual XML attribute in the input
    * document, or a pseudo-attribute created using setExtendedAttribute().
    * It may also be the special value "*" which refers to the character
    * content of the element. 
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
        renderer.setSorter( element, sortkey, before, between, after );
    }
    
    /**
    * Process a supplied XML input file. This method should be called
    * after all element handlers have been initialised.
    * @param inputFile The XML input filename
    * @return result code: zero indicates success, non-zero failure
    */

    public int setInputFile ( String inputFile ) {

        errorText = "";
        
        File f = new File( inputFile );
        if (!f.exists()) {
            errorText = "Input file " + inputFile + " does not exist";
            return(1);
        }
        if (f.isDirectory()) {
            errorText = "Input file " + inputFile + " is a directory";
            return(1);
        }
        if (!f.canRead()) {
            errorText = "Cannot read input file " + inputFile;
            return(1);
        }

        StringWriter errorMessage = new StringWriter();
        renderer.setErrorOutput(errorMessage);

        int result = renderer.run (
                            new ExtendedInputSource( new File(inputFile) ) );
        if (result>0)
            errorText = errorMessage.toString();
 
        return(result);
    }

    /**
    * Get error message. Returns error message if there has been an
    * error, zero-length string otherwise. Resets the error message,
    * so each message can be read once only.
    * @return The error message, if any
    */

    public String getErrorText() {
        String s = errorText;
        errorText = "";
        return s;
    }


}

