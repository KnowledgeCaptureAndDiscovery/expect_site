package com.icl.saxon;
import org.xml.sax.AttributeList;
import org.xml.sax.SAXException;

// Copyright © International Computers Limited 1998
// See conditions of use

/**
* Class ElementCopier.<BR>
* This is an ElementHandler that copies the element
* (tags, attributes, and content) to the appropriate Writer
* @author Michael H. Kay
* @version 7 May 1998
*/

public class ElementCopier extends ElementHandlerBase {

    /**
    * Define action to be taken before an element of this element type.<BR>
    * This implementation outputs a copy of the start tag (with attributes).
    * @param e The ElementInfo object for the current element.
    */
    
    public void startElement( ElementInfo e ) throws SAXException
    {
        AttributeList atts = e.getAttributeList();
        int attNr = atts.getLength();
        e.write("<");
        e.write(e.getTag());
        if (attNr>0) {
            
            for (int i = 0; i < attNr; i++) {
                e.write(" ");
                e.write(atts.getName(i));
                e.write("=\"");
                e.writeEscape(atts.getValue(i));
                e.write("\"");
            }
        }
        e.write(">"); 
    }

    /**
    * Define action to be taken after an element of this element type.<BR>
    * This implementation outputs a copy of the end tag.
    * @param e The ElementInfo object for the current element.
    */

    public void endElement( ElementInfo e ) throws SAXException
    {
        e.write( "</" );
        e.write(e.getTag());
        e.write( ">\n" );
    }

    /**
    * Define action to be taken with character data belonging to
    * this element type.<BR>
    * This implementation outputs the character data, escaping characters
    * that are not legal in XML
    * @param e The ElementInfo object describing the XML element
    * containing this character data.
    * @param ch A character array containing the character data
    * @param start Offset of the character data within the array
    * @param length Length of the character data within the array
    */
    
    public void characters( ElementInfo e,
                char ch[], int start, int len ) throws SAXException
    {
        e.writeEscape( ch, start, len );
    }

}   // end of class ElementCopier
