package com.icl.saxon;
import java.lang.Math;
import java.io.*;
import java.util.*;
import org.xml.sax.SAXException;

// Copyright © International Computers Limited 1998
// See conditions of use

   /**
    * Class ElementSorter<P>
    * Establish sorting on the elements within a group.<P>
    * A group is defined as a number of consecutive elements of
    * the same type, subordinate to the same parent element.<P>
    * <B>Restriction:</B>Do not use this for an element that can
    * be nested within itself. The effect of doing so is undefined.<P>
    * ElementSorter outputs nothing for the start and end of each element,
    * but outputs the character content of each element. To change this
    * behaviour, write a subclass of ElementSorter. The subclass must
    * invoke the beforeGroup, startElement, endElement, and afterGroup
    * methods of this class to achieve the correct sorting behaviour.<P>
    * @author M. H. Kay (M.H.Kay@eng.icl.co.uk)
    * @version 8 May 1998
    */

public class ElementSorter extends ElementHandlerBase {

    private String sortkey;
    private String before;
    private String between;
    private String after;
    private BinaryTree binaryTree;
    private Writer groupWriter;
    private boolean inElement = false;

    /**
    * Constructor supplies parameters to control sorting. 
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

    public ElementSorter (  String sortkey,
                            String before,
                            String between,
                            String after ) {
 		this.sortkey = sortkey;
 		this.before = before;
 		this.between = between;
 		this.after = after;
    }

    /**
    * Before a group of elements, output the registered "before" string
    */

	public void beforeGroup(ElementInfo e) throws SAXException {
        e.write(before);
		// restriction: we aren't dealing with nested groups
		binaryTree = new BinaryTree();
		groupWriter = e.getWriter();		
	}

	/**
	* At the start of an element, allocate an internal writer
	* to hold the output for this element until later. The application
	* must not itself attempt to allocate a writer for this element.
	*/
 
    public void startElement(ElementInfo e) throws SAXException {
      	e.setWriter(new StringWriter());
      	if (inElement)
      	    throw new SAXException("ElementSorter cannot sort self-nested elements");
      	inElement = true;   
   	}

   	/**
   	* Character content is copied to the output stream. This behaviour
   	* can be overridden in a subclass
   	*/

   	public void characters(ElementInfo e, char[] ch,
   	             int start, int length) throws SAXException {
   	    // default action is to copy the content
   	    e.write(Renderer.escape(ch, start, length));
   	}

   	/**
   	* At the end of an element, read the value of the sort key, and
   	* save the output of this element for later
   	*/

   	public void endElement(ElementInfo e) throws SAXException {
        String value = ((StringWriter)e.getWriter()).toString();
        String key = e.getExtendedAttribute(sortkey);
   	    if (key==null) key = "";
   	    key = key + "\u0000" + Math.random(); // to allow for duplicates
  	    
   	    binaryTree.put(key, value);
   	    inElement = false;
   	}

   	/**
   	* At the end of a group of elements, scan the temporary output streams
   	* and write them to the original output stream in sort key order
   	*/

   	public void afterGroup(ElementInfo e) throws SAXException {
   		Enumeration enum = binaryTree.elements();
   		e.setWriter(groupWriter);
   		while (enum.hasMoreElements()) {
   			String value = (String)enum.nextElement();
            e.write(value);
            if (enum.hasMoreElements()) e.write(between);
   		}
   		e.write(after);
   	}
   	
}   // end of class ElementSorter  
