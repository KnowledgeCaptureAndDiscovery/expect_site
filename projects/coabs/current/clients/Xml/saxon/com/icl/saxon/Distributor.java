package com.icl.saxon;

import org.xml.sax.*;
import org.xml.sax.helpers.*;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import com.docuverse.freedom.Freedom;

import java.net.*;
import java.util.*;
import java.io.*;

// Copyright © International Computers Limited 1998
// See conditions of use

/**
  * <B>Distributor</B> processes an XML file, calling registered element handlers
  * when appropriate. It uses the SAX interface to do XML parsing.<P>
  * Element handlers can be registered using the setHandler() interface.
  * They must be declared as implementations of ElementHandler. They can
  * optionally be declared as subclasses of ElementHandlerBase.
  * @see ElementHandler
  * @see ElementHandlerBase
  * @author Michael H. Kay (M.H.Kay@eng.icl.co.uk)
  * @version 6 June 1998
  */
  
public class Distributor implements org.xml.sax.DocumentHandler {

    public static final int RETAIN_CONTENT = 1;
    public static final int RETAIN_ATTRIBUTES = 2;
    public static final int BUILD_DOM = 3;

    private Stack stack;
    private Dictionary handlers;
    private Dictionary writers;
    private ElementHandler defaultHandler;
    private Parser parser;
    private Writer errorOutput;
    private Locator locator;
    private DOMDriver DOMwalker;
    private Document document;
    private Dictionary elementTypes;
    private boolean usingWriters = false;    // to save a lookup when only default writer used
    private boolean[] specialChars;
    private boolean retainContent;
    private boolean retainAttributes;
    private boolean buildDOM;

   /**
    * create a Distributor and initialise the element handlers
    */

    public Distributor() {
        
        // set up the element handlers and writers
        handlers = new Hashtable(100);
        writers = new Hashtable(20);
        defaultHandler = new ElementHandlerBase();
        elementTypes = new Hashtable(100);

        errorOutput = new PrintWriter(System.err);

        retainContent = false;
        retainAttributes = false;
        buildDOM = false;

        // create look-up table for ASCII characters that need special treatment

        specialChars = new boolean[128];
        for (int i=0; i<128; i++) specialChars[i] = false;
        specialChars['<'] = true;
        specialChars['>'] = true;
        specialChars['&'] = true;
        specialChars['\''] = true;
        specialChars['\"'] = true;
        
    }

    /**
    * Set output for error messages. The distributor does not throw an exception
    * for parse errors or input I/O errors, rather it returns a result code an
    * writes diagnistics to a user-specified output stream, which defaults to
    * System.err
    */

    public void setErrorOutput(Writer writer) {
        errorOutput = writer;
    }

    /**
    * Set processing options.
    * @param option: the option to be set. Values are:<UL>
    * <LI>Distributor.RETAIN_CONTENT: make character content of elements available
    * as the pseudo-attribute named "*" (default is false)
    * <LI>Distributor.RETAIN_ATTRIBUTES: make attributes of elements available
    * outside the scope of the startElement handler for that element (default is false)
    * <LI>Distributor.BUILD_DOM: build Document Object Model and make its nodes
    * available to element handlers (default is false)
    * </UL>
    * @param value: the value for the option, true or false
    */

    public void setOption( int option, boolean value ) {
        if (option==RETAIN_CONTENT) retainContent = value;
        if (option==RETAIN_ATTRIBUTES) retainAttributes = value;
        if (option==BUILD_DOM) buildDOM = value;
    }    
    
    /**
    * Run the Distributor, calling element handlers when appropriate.<BR>
    * The SAX parser is obtained by calling <B>ParserManager</B>.<BR>
    * If parsing failures occur, diagnostics are written to the system error output.
    * @param in The InputSource that identifies the XML input. This may
    * be any SAX InputSource object. SAXON provides the <B>ExtendedInputSource</B>
    * class, which may also be used.
    * @return zero for success, non-zero for failure
    * @see ExtendedInputSource
    * @see ParserManager
    */

    public int run (InputSource in)
    {

        if (buildDOM)
            return runFromDOM ( in );
        else
            return runFromParser ( in );
    }

    private int runFromDOM(InputSource source)
    {
        Freedom.setDriver("com.icl.saxon.SAXONFreedomDriver");

        document = Freedom.openDocument(source);
        DOMwalker = new DOMDriver();
        DOMwalker.setDocumentHandler(this);
        try {
            DOMwalker.walk(document);
            return 0;
        } catch (SAXException err) {
            try {
                errorOutput.write("Unable to parse XML document\n");
                errorOutput.write("Problem: " + err.getMessage() + "\n");
                return 2;
            } catch (java.io.IOException e2) {
                return 4;
            }
        }
    }      

    private int runFromParser(InputSource in)
    {            
		// Create a new parser instance 
        parser = ParserManager.makeParser();
        if (parser!=null)
            parser.setDocumentHandler(this);
        else {
            try {
                errorOutput.write("No XML Parser established\n");
                errorOutput.flush();
            } catch (Exception e) {}
            return(4);
        }
        try {
            parser.parse(in);           // this is the real work!
            return(0);
        }
        catch (java.io.IOException e) {
            try {
                errorOutput.write("Input/Output error during parsing\n");
                errorOutput.write("Details: " + e.getMessage() + "\n");
                errorOutput.flush();
            } catch (Exception e2) {}
            return(3);
        }
        catch (SAXException e) {
            try {
                errorOutput.write("Unable to parse XML document\n");
                errorOutput.write("Problem: " + e.getMessage() + "\n");
                if (locator!=null) {
                    errorOutput.write("  URL:    " + locator.getSystemId() + "\n");
                    errorOutput.write("  Line:   " + locator.getLineNumber() + "\n");
                    errorOutput.write("  Column: " + locator.getColumnNumber() + "\n");
                }
                errorOutput.flush();
            } catch (Exception e2) {};
            return(2);
        }   
    }

    /**
    * Walk an existing tree, calling registered element handlers as appropriate. This
    * works only if BUILD_DOM was specified
    */
    
    public int run(Document doc)
    {
        if (buildDOM) {
            try {
                DOMwalker.walk(doc);
                return 0;
            } catch (SAXException err) {
                System.err.println("Gotcha!");       // fix this
                return 4;
            }
        }
        else return 4;
    }

    /**
    * Get the DOM Document object. Only works if BUILD_DOM was set.
    */

    public Document getDocument()
    {
        return document;
    }
        
    /**
      * Register a handler for a particular element type. Note that several
      * handlers are allowed for the same element; they will be invoked in
      * the order supplied.
      * @param name Must be either <UL>
      * <LI>an element tag (the handler is used when this element is encountered)
      * <LI>a tag in context, in the form "PARENT/CHILD" (the handler is used
      * whenever the CHILD element is found with PARENT as its parent). Note that
      * if there is at least one PARENT/CHILD handler for a particular element type,
      * the system will not look for a CHILD handler for that element type.</UL>
      * @param eh The ElementHandler to be used
      * @see ElementHandler
      */
        
    public void setHandler(String name, ElementHandler eh) {
        // see if there is already a handler registered
        ElementHandler old = (ElementHandler) handlers.get(name);
        if (old==null)
            // no existing handler
            handlers.put(name, eh);
        else {
            // there is already an element handler so we register a multi-handler
            ElementHandler multi = new MultiHandler( old, eh );
            handlers.put(name, multi);
        }
    }

    /**
      * Find the handler registered for a particular element type.
      * @param tag The element tag for this element type.
      * @param parent The element tag for the parent element type; supply
      * an empty string if the current element is the root.
      * @return The element handler that will process this
      * element type. Returns the default handler if there is no specific
      * one registered.
      */

    public ElementHandler getHandler (String tag, String parent) {
        
        ElementHandler eh;

        // first see if there is a handler registered with a PARENT/CHILD key
        String fullkey = parent + "/" + tag;
        eh = (ElementHandler) handlers.get(fullkey);
        
        // if not, see if there is a handler registered for the CHILD element alone
        if (eh==null) eh = (ElementHandler) handlers.get(tag);

        // if no handler has been registered, use the default handler
        if (eh==null) eh = defaultHandler;
        
        return eh;
    }

    /**
      * Register the default element handler
      * @param handler The element handler to be used for all element types
      * that have no specific handler registered
      */
        
    public void setDefaultHandler(ElementHandler handler) {
         defaultHandler = handler;      
    }

    /**
      * Find the default element handler
      */

    public ElementHandler getDefaultHandler() {
        return defaultHandler;
    }

    /**
    * Set the writer to be used for an element type.<BR>
    * This setting may be overridden for a particular element instance
    * by calling <B>ElementInfo.setWriter()</B> from the element handler.
    * @param element Either the name (tag) of the element type, or a pattern in the
    * form "PARENT/CHILD". The selected Writer is used for this
    * element and for all its children unless otherwise specified
    * @param writer A Writer that will be used when the write() method is called for this
    * element and (unless otherwise specified) its children
    */

    public void setWriter( String element, Writer writer ) {
        usingWriters = true;
        writers.put( element, writer );
    }

    /**
    * Set a null writer for an element. This causes
    * output for that element to be discarded.
    * @param element Must be either <UL>
      * <LI>an element tag (the output is discarded when this element is encountered)
      * <LI>a tag in context, in the form "PARENT/CHILD" (the output is discarded
      * whenever the CHILD element is found with PARENT as its parent). 
    */

    public void setNullWriter( String element ) {
        // a very crude implementation
        setWriter( element, new StringWriter() );
    }

    /**
      * Find the Writer registered for a particular element type.
      * @param tag The element tag for this element type.
      * @param parent The element tag for the parent element type; supply
      * an empty string if the current element is the root.
      * @return The context explicitly registered for this element type; or null
      * if none has been registered.
      */

    public Writer getWriter (String tag, String parent) {
        Writer c;

        // first try to find a context registered for the key PARENT/CHILD
        String fullkey = parent + "/" + tag;
        c = (Writer)writers.get(fullkey);
        if (c!=null) return c;

        // if none found, find a context registered for the key CHILD alone
        c = (Writer)writers.get(tag);

        // for faster access next time, save this with a full key
        if (c!=null) writers.put(fullkey, c);
        return c;
    }

  //////////////////////////////////////////////////////////////////////
  // Implement the org.xml.sax.DocumentHandler interface.
  //////////////////////////////////////////////////////////////////////

    /**
    * Callback interface for SAX: not for application use<BR>
    */

    public void startDocument ()
    {
        stack = new Stack();
    }

    /**
    * Callback interface for SAX: not for application use<BR>
    */

    public void endDocument ()
    {}

    /**
    * Callback interface for SAX: not for application use<BR>
    */
    
    public void setDocumentLocator (Locator locator)
    {
        this.locator = locator;
    }

    /**
    * Callback interface for SAX: not for application use<BR>
    */
  
    public void startElement (String name, AttributeList atts) throws SAXException
    {        
        // create an ElementInfo structure for use by the handlers
        
        ElementInfoImpl e = new ElementInfoImpl();
        e.tag = name;
        e.userData = null;

        // find the corresponding element in the DOM, if any
 
        e.DOMelement = (buildDOM ? DOMwalker.getCurrentElement() : null);

        // build copy of attribute list, if required

        if (retainAttributes) {
            AttributeListImpl ea = new AttributeListImpl(atts);
            e.attributeList = ea;
            elementTypes.put(name, ea);
        }
        else
            e.attributeList = atts;

        // initialise the ElementInfo with details of the element's context

        String parentTag;

        if (stack.isEmpty()) {        // this is the root
            parentTag = "";
            e.parent = null;
            e.previousSibling = null;
        }
        else {
            ElementInfoImpl parent = (ElementInfoImpl) stack.peek();
            parentTag = parent.tag;
            e.parent = parent;
            e.previousSibling = parent.youngestChild;
            parent.youngestChild=e;
        };

        ElementInfoImpl prev = e.previousSibling;
        boolean firstInGroup = (prev==null || !(prev.tag.equals(name)));
        
        // establish the appropriate Writer for this element
        
        e.newOutput = true;
        e.autoClose = false;
        e.writer = null;
        
        if (usingWriters)
            e.writer = getWriter( name, parentTag );
        if (e.writer==null) {            
            if (e.parent==null)  // use System.out as default writer for the root element
                e.writer = new BufferedWriter(new PrintWriter(System.out));
            else {               // inherit the writer for the parent element
                e.writer = e.parent.writer;
                e.newOutput = false;
            }
        }

        // save this ElementInfo on the stack

        stack.push(e);

        // find the relevant element handler and call it as appropriate

        if (firstInGroup) {
            e.handler = getHandler( name, parentTag );
            if (prev != null)
                prev.handler.afterGroup(prev);
            e.handler.beforeGroup(e);
        }
        else
            e.handler = prev.handler;

            
        // always call the start element method
        e.handler.startElement(e);
           
    }

    /**
    * Callback interface for SAX: not for application use<BR>
    */

    public void endElement (String name) throws SAXException
    {            
        // remove the ElementInfo from the stack
        
        ElementInfoImpl e = (ElementInfoImpl) stack.pop();

        // save the content as a pseudo-attribute
        if ( retainContent && e.content.length()>0)
            e.setExtendedAttribute( "*", e.content.toString() );

        // determine whether we need to call the "after group" method for
        // a group that has ended
        
        ElementInfoImpl youngest = e.youngestChild;
        if (youngest!=null)
            youngest.handler.afterGroup(youngest);
        e.youngestChild = null; // to allow the garbage collector to lose it

        // call the "end element" method

        e.handler.endElement(e);

        // flush the Writer for this element (if it's the last one for its writer)

        try {
            if (e.newOutput) e.writer.flush();
            if (e.autoClose) e.writer.close();
        } catch (java.io.IOException err) {
            throw new SAXException("IO Error writing output", err);
        }       
    }

    /**
    * Callback interface for SAX: not for application use<BR>
    */

    public void characters (char ch[], int start, int length) throws SAXException
    {
        // find out from the stack which element we are in        
        ElementInfoImpl e = (ElementInfoImpl) stack.peek();

        // save the content as a pseudo-attribute
        if (retainContent)
            e.content.append(ch, start, length);
        
        // call the appropriate handler
        e.handler.characters(e, ch, start, length);
    }

    /**
    * Callback interface for SAX: not for application use<BR>
    */
 
    public void ignorableWhitespace (char ch[], int start, int length) throws SAXException
    {
        // find out from the stack which element we are in,
        // and call the appropriate handler
        
        try {
            ElementInfoImpl e = (ElementInfoImpl) stack.peek();
            e.handler.ignorable(e, ch, start, length);
        }
        // some parsers report white space after end of outermost element
        catch (java.util.EmptyStackException e) {} 
    }

    /**
    * Callback interface for SAX: not for application use<BR>
    */

    public void processingInstruction (String name, String remainder)
    {}

///////////////////////////////////////////////////////////////////////////////

//================================================================
//private inner class ElementInfoImpl
//================================================================

/**
  * A node in the XML parse tree representing an element.<BR>
  * The default implementation of the ElementInfo interface.<BR>
  */

private class ElementInfoImpl implements ElementInfo {

    public ElementInfoImpl parent;
    public ElementInfoImpl previousSibling;
    public ElementInfoImpl youngestChild;
    public Element DOMelement;
    public AttributeList attributeList;
    public ElementHandler handler;
    public String tag;
    public StringBuffer content = new StringBuffer();
    public Object userData;
    public Writer writer;
    public boolean newOutput;
    public boolean autoClose;

    /**
    * Get the corresponding element in the DOM. This will only work if the
    * BUILD_DOM option was set. Otherwise it returns null
    */
    public Element getElementInDOM() {
        return DOMelement;
    }

    /**
    * Get the attribute list for the current element.<BR>
    * If the RETAIN_ATTRIBUTES option was set, this may be called at
    * any time. If not, it should be called only while processing the
    * startElement() event.
    * @return The attribute list (as in the SAX interface)
    */
    public AttributeList getAttributeList()
    { return attributeList; }

    /**
     * Find the value of a given attribute of this element<BR>
     * If the RETAIN_ATTRIBUTES option was set, this may be called at
     * any time. If not, it should be called only while processing the
     *  @param name The name of an attribute
     *  @return The value of the attribute, if it exists, otherwise null
     */

    public String getAttribute( String name ) {
        return (String) attributeList.getValue(name);
    }

    /**
     *  Get the value of a given attribute in the most recent occurrence
     *  of a given element type, or the value set using setExtendedAttribute().
     *  Note that attributes in the source document are retained only if 
     *  the RETAIN_ATTRIBUTES option was set.
     *  @param element The name (tag) of the element
     *  @param name The name of an attribute or pseudo-attribute. There
     *  are two special attribute names: "#" for the element number, and "*"
     *  for the character content.
     *  @return The value of the attribute, if it exists, otherwise null.
     */

    public String getExtendedAttribute( String element, String name )
    {
        AttributeList atts = (AttributeList)elementTypes.get(element);
        if (atts==null) return null;
        return atts.getValue(name);
    }

    /**
     *  Set the value of a given attribute of a given element type. Note the only
     *  effect is on subsequent calls of getExtendedAttribute().
     *  @param element The name (tag) of the element
     *  @param name The name of an attribute or pseudo-attribute. There
     *  are two special attribute names: "#" for the element number, and "*"
     *  for the character content.
     *  @return The value of the attribute, if it exists, otherwise null
     */

    public void setExtendedAttribute( String element, String name, String value )
    {
        AttributeListImpl atts = (AttributeListImpl)elementTypes.get(element);
        if (atts==null) {
            atts = new AttributeListImpl();
            elementTypes.put(element, atts);
        }
        atts.removeAttribute(name);
        if (value!=null)
             atts.addAttribute( name, "", value);
    }
    
    /**
     *  Find the most recent value of a given attribute of this element
     *  @param name The name of an attribute or pseudo-attribute. There
     *  are two special attribute names: "#" for the element number, and "*"
     *  for the character content.
     *  @return The value of the attribute, if it exists, otherwise null
     */

    public String getExtendedAttribute( String name ) {
        return getExtendedAttribute(tag, name);
    }

    /**
     *  Set the value of a given attribute of this element. Note the only
     *  effect is on subsequent calls of getExtendedAttribute().
     *  @param name The name of an attribute or pseudo-attribute. There
     *  are two special attribute names: "#" for the element number, and "*"
     *  for the character content.
     *  @return The value of the attribute, if it exists, otherwise null
     */

    public void setExtendedAttribute( String name, String value ) {
        setExtendedAttribute(tag, name, value);
    }
    

    /**
     * Get the tag of this element
     * @return The tag as a String
     */
     
    public String getTag() {
        return tag;
    }

    /**
     * Get the handler of this element
     * @return The element handler
     */
     
    public ElementHandler getHandler() {
        return handler;
    }
    /**
    * Format a string with substitution of parameters
    * @param pattern String containing place-markers to be expanded. Place markers
    * are marked by enclosing guillemots (angle quotation marks) and take the form:<UL>
    * <LI>«element/attribute»: The most recent value of the given attribute on
    * the given element. (Null string if attribute not specified)</LI>
    * <LI>«element/#»: The element number assigned to the element using the
    * setNumbering() interface</LI>
    * @return String after substitution. 
    */

    public String format (String pattern)
    {
        int i1, i2, i3, last;
        StringBuffer out = new StringBuffer();
        String elemkey, attkey, att;
        last=0;
        while (true) {
            i1=pattern.indexOf("«", last);
            if (i1<0) break;
            i2=pattern.indexOf("/", i1+1);
            if (i2<0) break;
            i3=pattern.indexOf("»", i2+1);
            if (i3<0) break;
            elemkey = pattern.substring(i1+1, i2);
            attkey = pattern.substring(i2+1, i3);
            att = getExtendedAttribute(elemkey, attkey);
            if (att==null) att="";
            out.append(pattern.substring(last,i1));
            out.append(att);
            last=i3+1;
        }
        out.append(pattern.substring(last));
        return out.toString();
    }  

    /**
     * Find the parent of this element.
     * @return The ElementInfo deescribing the parent;
     * or null if this element is the root.
     */
     
    public ElementInfo getParent() {
        return parent;
    }
    
    /**
     * Get the nearest ancestor element with a given tag
     * @param tag The tag of the required ancestor element
     * @return The ElementInfo for the nearest ancestor with the
     * given tag; null if there is no such ancestor
     */

    public ElementInfo getAncestor(String tag)
    {
        ElementInfoImpl p = parent;
        while (p!=null) {
            if (p.tag.equals(tag)) return p;
            else p=p.parent;
        }
        return null;
    }

    /**
    * Get the user data for the element
    * @return the user data object that was attached to the element
    * using setUserData(); null if no user data object was attached
    */
    
    public Object getUserData() {
        return userData;
    }

    /**
    * Attach a user data object to the element
    * @param data An object to be saved with this element, which can be
    * retrieved later using getUserData()
    */
    
    public void setUserData(Object data) {
        userData = data;
    }    

    /**
    * Get the previous sibling of the element.
    * @return the previous sibling element. Returns null if this is the first
    * child of its parent, or if it is the root element.
    */
    
    public ElementInfo getPreviousSibling() {
        return previousSibling;
    }

    /**
    * Get the first element in the current group.
    */

    public ElementInfo getFirstInGroup() {
        ElementInfo first = this;
        while (!first.isFirstOfType()) first=first.getPreviousSibling();
        return first;
    }

   /**
     * Determine whether this element is the first in a consecutive
     * group.
     * @return True if this is the first child of its parent, or if the
     * previous child was a different element type, or if this element 
     * is the root. False otherwise.
     */
     
    public boolean isFirstOfType() {
        if (previousSibling==null) return true;
        return !previousSibling.tag.equals(tag);
    }
 
   /**
     * Determine whether this element is the first child of its parent.
     * @return True if this element is the first child of its parent, or
     * if it is the root element. False otherwise.
     */
     
    public boolean isFirstChild() {
        return (previousSibling==null);
    }

    /**
     * Determine whether the parent of this element is an element of
     * a specified type.
     * @return True if the parent of this element has the specified tag.
     * False if not (or if this element is the root).
     * @param tag The tag of the parent element type
     */
     
    public boolean hasParent(String tag) {
        if (parent==null) return false;
        return (parent.tag.equals(tag));
    }

    /**
     * Determine whether this element is the root.
     * @return True if this element is the root; False if not.
     */
     
    public boolean isRoot() {
        return (parent==null);
    }
 
    /**
    * Get the Writer being used for this element
    */

    public Writer getWriter() {
        return this.writer;
    }

    /**
    * Set the Writer for this element instance
    */

    public void setWriter(Writer writer) {
        this.writer = writer;
        this.autoClose = true;
    }

    /**
    * Produce output using the Writer registered for this
    * element type
    */

    public void write(String s) throws SAXException {
        try {
            this.writer.write(s);
        } catch (java.io.IOException err) {
            throw new SAXException("IO Error writing output", err); 
        }
    }

    /**
    * Produce output using the appropriate Writer for this element
    * @param ch Character array to be output
    * @param start start position of characters to be output
    * @param length number of characters to be output
    */

   public void write(char ch[], int start, int length) throws SAXException {
       try {
            this.writer.write(ch, start, length);
        } catch (java.io.IOException err) {
            throw new SAXException("IO Error writing output", err);
        }
   }

   /**
    * Produce output using the appropriate Writer for this element,
    * escaping special characters using XML/HTML conventions
    * @param s The String to be output
    */

    public void writeEscape(String s) throws SAXException {
        writeEscape( s.toCharArray(), 0, s.length() );
    }

   /**
    * Produce output using the appropriate Writer for this element,
    * escaping special characters using XML/HTML conventions
    * @param ch Character array to be output
    * @param start start position of characters to be output
    * @param length number of characters to be output
    */

    public void writeEscape(char ch[], int start, int length) throws SAXException {

        // this code is designed to be fast for the normal (all-ASCII) case
        
        int limit = start+length;
        int i = start;
        while(i < limit) {
            int j=i;
            while ( j < limit && ch[j]<=0x7f && !specialChars[ch[j]] ) j++;
            if (j>i) {
                write(ch, i, j-i);
                i=j;
            }
            if (i < limit) {
                if (ch[i]=='<') write("&lt;");
                else if (ch[i]=='>') write("&gt;");
                else if (ch[i]=='&') write("&amp;");
                else if (ch[i]=='\"') write("&#34;");
                else if (ch[i]=='\'') write("&#39;");
                else write("&#" + Integer.toString((int)ch[i]) + ';');
            }
            i++;
        }
    }  
        
   
}   // end of inner class ElementInfoImpl

///////////////////////////////////////////////////////////////////

/**
  * Class MultiHandler<P>
  * An element handler that branches, allowing more than one handler
  * to be invoked for the same element. 
  */

  // Actually, it only branches
  // two ways, but typically one of the handlers will be another
  // multi-handler, thus allowing infinite extension.


private class MultiHandler implements ElementHandler {

    private ElementHandler firstHandler;
    private ElementHandler secondHandler;

    /**
      * Constructor supplies the child element handlers. 
      * @param first ElementHandler to be called first 
      * @param second ElementHandler to be called second
      */

    public MultiHandler (ElementHandler first, ElementHandler second) {
        firstHandler = first;
        secondHandler = second;
    }

    /**
    * Handle start of element<BR>
    * This implementation calls the two child handlers.
    */

    public void startElement(ElementInfo e) throws SAXException {
        firstHandler.startElement(e);
        secondHandler.startElement(e);
    }

    /**
    * Handle end of element<BR>
    * This implementation calls the two child handlers. Note, on the
    * way out we call them in reverse order.
    */

    public void endElement(ElementInfo e) throws SAXException {
        secondHandler.endElement(e);
        firstHandler.endElement(e);
    }

    /**
    * Handle start of a group of one or more consecutive elements<BR>
    * This implementation calls the two child handlers.
    */

    public void beforeGroup( ElementInfo e ) throws SAXException {
        firstHandler.afterGroup( e );
        secondHandler.afterGroup( e );
    }

    /**
    * Handle end of a group of one or more consecutive elements<BR>
    * This implementation calls the two child handlers.
    * Note, on teh way out we call them in the reverse order
    */

    public void afterGroup( ElementInfo e ) throws SAXException {
        secondHandler.afterGroup( e );
        firstHandler.afterGroup( e );
    }


    /**
    * Handle character data <BR>
    * This implementation calls the two child handlers.
    */
    
    public void characters( ElementInfo e,
                char ch[], int start, int len ) throws SAXException
    {
        firstHandler.characters( e, ch, start, len);
        secondHandler.characters( e, ch, start, len);
    }

    /**
    * Handle ignorable white space<BR>
    * This implementation calls the two child handlers.
    */
    
    public void ignorable( ElementInfo e,
               char ch[], int start, int len ) throws SAXException
    {
        firstHandler.ignorable( e, ch, start, len);
        secondHandler.ignorable( e, ch, start, len);
    }
    
}   // end of inner class MultiHandler

///////////////////////////////////////////////////////////////////

}   // end of outer class Distributor  
