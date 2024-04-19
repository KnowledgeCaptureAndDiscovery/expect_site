package com.icl.saxon;
import com.icl.saxon.*;
import org.xml.sax.SAXException;

// Copyright © International Computers Limited 1998
// See conditions of use

/**
 * This interface defines the element handler used by the SAXON distributor.
 * @author <A HREF="mailto:M.H.Kay@eng.icl.co.uk>Michael H. Kay, ICL</A>
 * @version 25 Feb 1998
 */
 
public interface ElementHandler {

    /**
    * Define action to be taken before a group of one or more
    * consecutive elements of the same element type. (That is,
    * before every element of this type unless it was immediately preceded
    * by another element of the same type.)<BR>
    * @param e The ElementInfo object for the first element in the group.
    */
    public void beforeGroup( ElementInfo e ) throws SAXException;

    /**
    * Define action to be taken before an element of this element type.<BR>
    * @param e The ElementInfo object for the current element.
    */
    
    public void startElement( ElementInfo e ) throws SAXException;

    /**
    * Define action to be taken after an element of this element type.<BR>
    * @param e The ElementInfo object for the current element.
    */

    public void endElement( ElementInfo e ) throws SAXException;

    /**
    * Define action to be taken after a group of one or more
    * consecutive elements of the same element type. (That is,
    * before an element of a different type that is immediately preceded
    * by an element of this type.)<BR>
    * @param e The ElementInfo object for the last element in the group.
    */

    public void afterGroup( ElementInfo e ) throws SAXException;


    /**
    * Define action to be taken with character data belonging to
    * this element type.<BR>
    * @param e The ElementInfo object describing the XML element
    * containing this character data.
    * @param ch A character array containing the character data
    * @param start Offset of the character data within the array
    * @param length Length of the character data within the array
    */
    
    public void characters( ElementInfo e,
                char ch[], int start, int len ) throws SAXException;

    /**
    * Define action to be taken with ignorable white space belonging to
    * this element type.<BR>
    * @param e The ElementInfo object describing the XML element
    * containing this ignorable white space.
    * @param ch A character array containing the white space
    * @param start Offset of the white space within the array
    * @param length Length of the white space within the array
    */
    
    public void ignorable( ElementInfo e,
               char ch[], int start, int len ) throws SAXException;
                               
}
