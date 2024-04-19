package com.icl.saxon;
import com.icl.saxon.*;
import java.util.*;
import java.io.Writer;
import org.xml.sax.AttributeList;
import org.xml.sax.SAXException;
import org.w3c.dom.Element;

// Copyright © International Computers Limited 1998
// See conditions of use

/**
  * A node in the XML parse tree representing an element.<P>
  * The ElementInfo provides information about the element and its context.
  * Information available includes the tag and attributes of the element, and
  * pointers to the parent element and the previous element at the same level.<P>
  * It is also possible to associate user data with the ElementInfo; user data
  * set while processing the start tag of the element may be accessed, for example,
  * when processing the children of the element or the end tag of the element.<P>
  * SAXON processes a document serially and heirarchically. Because of this,
  * you can only access information about elements that have already been
  * processed, and information about an element is discarded as soon as its
  * parent element is closed.<P> 
  * @author <A HREF="mailto:M.H.Kay@eng.icl.co.uk>Michael H. Kay, ICL</A> 
  * @version 6 June 1998 
  */

public interface ElementInfo {

    /**
    * Get the corresponding element in the DOM. This will only work if the
    * BUILD_DOM option was set. Otherwise it returns null
    */
    public Element getElementInDOM();

    /**
    * Get the attribute list for this element.
    * @return The attribute list (as in the SAX interface)
    */
    
    public AttributeList getAttributeList();

    /**
    * Get the user data for the element
    * @return The user data object. Returns null if setUserData() has not been called
    * for this element.
    */

    public Object getUserData();

    /**
    * Set the user data for the element
    * @param userData an object to be saved with this element, which can be
    * retrieved later using getUserData().
    */
    
    public void setUserData(Object userData);

    /**
    * Get the Writer used for this element instance
    * @return the Writer used for output from this element. This will be:
    * <UL><LI>A writer provided for the element instance using
    * ElementInfo.setWriter(), if any;</LI>
    * <LI>Otherwise, a writer provided for the element type using
    * Distributor.setWriter(), if any;</LI>
    * <LI>Otherwise, the writer being used for the parent element.</LI></UL>
    * The default Writer for the root element is System.out
    */

    public Writer getWriter();

    /**
    * Set the writer for this element instance.<BR>
    * This affects subsequent output produced for this element instance, and overrides
    * any Writer set for the element type using Distributor.setWriter(). It
    * will be used for subsequent output for this element, and for any subsequent
    * child element unless the child element type has a Writer explicitly
    * registered for it. It will automatically be closed when the element ends.<P>
    * @param writer The Writer to be used for output from this element instance
    */

    public void setWriter(Writer writer);

    /**
    * Produce output using the appropriate Writer for this element
    * @param s The String to be output
    */

    public void write(String s) throws SAXException;

    /**
    * Produce output using the appropriate Writer for this element
    * @param ch Character array to be output
    * @param start start position of characters to be output
    * @param length number of characters to be output
    */

    public void write(char ch[], int start, int length) throws SAXException;

    /**
    * Produce output using the appropriate Writer for this element,
    * escaping special characters using XML/HTML conventions
    * @param s The String to be output
    */

    public void writeEscape(String s) throws SAXException;

    /**
    * Produce output using the appropriate Writer for this element,
    * escaping special characters using XML/HTML conventions
    * @param ch Character array to be output
    * @param start start position of characters to be output
    * @param length number of characters to be output
    */

    public void writeEscape(char ch[], int start, int length) throws SAXException;


    /**
    * Get the previous sibling of the element.
    * @return The ElementInfo object describing the previous element at the same level.
    * Returns null if the current element is the first
    * child of its parent, or if it is the root element.
    */
    
    public ElementInfo getPreviousSibling();

    /**
     *  Find the value of a given attribute of this element.<BR>
     *  Note this is a short-cut method; the full capability to examine
     *  attributes is offered via the getAttributeList() method
     *  @param name the name of an attribute
     *  @return The value of the attribute, if it exists, otherwise null
     */

    public String getAttribute( String name );

    /**
     * Find the most recent value of a given attribute of a given element. This
     * can be used to find the value of an attribute of this element, of an element
     * that encloses this element, or of any element whose start tag has been
     * processed: but only the for the most recent element of its type. It can also
     * be used to retrieve "pseudo-attributes" that have been attached to an element
     * using setExtendedAttribute().
     * @param element The name (tag) of the element
     * @param name The name of the attribute or pseudo-attribute.
     * There are two special attribute names: "#" for the element number, and "<>"
     *  for the character content.
     * @return The value of the attribute, if it exists, otherwise null
     */

    public String getExtendedAttribute( String element, String name );
    
    /**
     * Set the value of a (pseudo-) attribute of a given element. This affects
     * subsequent calls of getExtendedAttribute() for that element.
     * @param element The name (tag) of the element. Note, there is no check that
     * this represents a real element in the document. If it does, the attribute
     * value will overwrite any value for the attribute that was actually present
     * on that element
     * @param name The name of an attribute or pseudo-attribute. This does not
     * need to be a well-formed or valid attribute name for the element type.
     * There are two special attribute names: "#" for the element number, and "<>"
     *  for the character content.
     * @return The value of the attribute, if it exists, otherwise null
     */

    public void setExtendedAttribute( String element, String name, String value );

    /**
     * Find the most recent value of a given attribute of this element. It can also
     * be used to retrieve "pseudo-attributes" that have been attached to an element
     * using setExtendedAttribute().
     * @param name The name of the attribute or pseudo-attribute.
     * There are two special attribute names: "#" for the element number, and "<>"
     *  for the character content.
     * @return The value of the attribute, if it exists, otherwise null
     */

    public String getExtendedAttribute( String name );
    
    /**
     * Set the value of a (pseudo-) attribute of this element. This affects
     * subsequent calls of getExtendedAttribute() for that element.
     * @param name The name of an attribute or pseudo-attribute. This does not
     * need to be a well-formed or valid attribute name for the element type.
     * There are two special attribute names: "#" for the element number, and "<>"
     *  for the character content.
     * @return The value of the attribute, if it exists, otherwise null
     */

    public void setExtendedAttribute( String name, String value );
        
    /**
     * Get the tag of this element
     * @return The element tag as a String
     */
     
    public String getTag();

    /**
     * Get the element handler for this element
     * @return The element handler
     */
     
    public ElementHandler getHandler();
    
    /**
    * Format a string with substitution parameters
    * @param pattern String containing place-markers to be expanded. Place markers
    * are marked by enclosing underscores and take the form:<UL>
    * <LI><B>«element/attribute»</B>: The value of the given attribute on the current or most recent
    * instance of the given element. This is the same value as getExtendedAttribute() would return.
    * (Zero-length string if there is no value for the attribute)</LI>
    * <LI><B>«element/#»</B>: The element number assigned to the element using the
    * setNumbering() method of class Renderer</LI>
    * <LI><B>«»element/*»</B>: The value of the character content of the element. (This
    * is only available once some character content has been read)</LI></UL>
    * @return String after substitution.
    */

    public String format( String pattern );

   /**
     * Find the parent of this element.
     * @return The ElementInfo object describing the parent element.
     * Returns null if this element is the root.
     *
     */
     
     public ElementInfo getParent();

     /**
     * Get the nearest ancestor element with a given tag
     * @param tag The tag of the required ancestor element
     * @return The ElementInfo for the nearest ancestor with the
     * given tag; null if there is no such ancestor
     */

     public ElementInfo getAncestor(String tag);

   /**
     * Determine whether this element is the first in a consecutive
     * group. A consecutive group is a group of elements of the same
     * type subordinate to the same parent element; there can be intervening
     * character data, white space, or processing instructions, but no
     * elements of a different type.
     * @return True if this is the first child of its parent, or if the
     * previous child was a different element type, or if this element 
     * is the root.
     */
     
    public boolean isFirstOfType();
 
   /**
     * Determine whether this element is the first child of its parent.
     * @return True if this element is the first child of its parent, or
     * if it is the root element.
     *
     */
     
    public boolean isFirstChild();

    /**
    * Get the first element of this group. A group is a consecutive
    * sequence of one or more elements of the same type, subordinate
    * to the same parent element. 
    * There may be intervening character data but no
    * intervening elements of a different type.
    * @return The ElementInfo for the first element in the group. This
    * may, of course, be the current element.
    */

    public ElementInfo getFirstInGroup();
    
    /**
     * Determine whether the parent of this element is an element of
     * a specified type.
     * @return True if the parent element has the specified tag.
     * Return False if this element is the root.
     * @param tag The putative tag of the parent element type
     */
     
    public boolean hasParent(String tag);
    
    /**
     * Determine whether this element is the root.
     * @return True if this element is the root element.
     */
     
    public boolean isRoot();

    
}
