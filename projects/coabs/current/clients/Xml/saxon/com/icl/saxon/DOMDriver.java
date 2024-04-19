package com.icl.saxon;

// Author MHK, 5 Jun 1998

import org.xml.sax.Locator;
import org.xml.sax.AttributeList;
import org.xml.sax.DocumentHandler;
import org.xml.sax.HandlerBase;
import org.xml.sax.SAXException;

import org.xml.sax.helpers.AttributeListImpl;

import org.w3c.dom.*;

/**
* DOMDriver.java: a (pseudo-)SAX driver for DOM.
* This program performs a depth-first traversal of the DOM tree
* structure, calling a SAX-compliant DocumentHandler
* to process the Element nodes as it does so. This is an internal
* class within SAXON, and you will not normally need to use it
* directly.
/*

public class DOMDriver implements Locator
{

  //
  // Variables.
  //

  private DocumentHandler documentHandler = new HandlerBase();
  private Element currentElement;


  /**
    * Set the SAX-compliant document handler.
    * @param handler The object to receive document events.
    */
    public void setDocumentHandler (DocumentHandler handler) 
    {
        this.documentHandler = handler;
    }

  /**
    * Walk a document (traversing the nodes depth first).
    * If you want anything useful to happen, you should supply a
    * SAX DocumentHandler first.
    * @param doc The (DOM) Document object to walk.
  */

    public void walk (Document doc)
        throws SAXException
    {
        documentHandler.setDocumentLocator(this);
        documentHandler.startDocument();
        walk(doc.getDocumentElement());            // walk the root element
        documentHandler.endDocument();
    }
    
  /**
    * Perform a depth-first traversal of an Element in the DOM, calling
    * a SAX-compliant document handler to process the nodes as they are
    * encountered.
    * @param elem The DOM Element object to walk
    * 
    */
    
    public void walk (Element elem)
        throws SAXException
    {
        currentElement = elem;
        
        AttributeListImpl attlist = new AttributeListImpl();
        NodeIterator atit = elem.getAttributes();
        for (Attribute att = (Attribute)atit.toNextNode(); att != null; att = (Attribute)atit.toNextNode()) {
            attlist.addAttribute(att.getName(),"CDATA", att.getValue());
        }
        documentHandler.startElement(elem.getTagName(), attlist);
        
        if (elem.hasChildNodes()) {
            NodeIterator nit = elem.getChildNodes();
            for (Node child = nit.toNextNode(); child != null; child = nit.toNextNode()) {
                switch (child.getNodeType()) {
                    case Node.DOCUMENT:
                        break;                  // should not happen
                    case Node.ELEMENT:
                        walk((Element)child);
                        break;
                    case Node.ATTRIBUTE:        // have already dealt with attributes
                        break;
                    case Node.PI:
                        documentHandler.processingInstruction(((PI)child).getName(), ((PI)child).getData());
                        break;
                    case Node.COMMENT:
                        break;
                    case Node.TEXT:
                        documentHandler.characters(child.toString().toCharArray(), 0, child.toString().length());
                        break;
                    default:
                        break;                  // should not happen
                }
            }
        }
        documentHandler.endElement(elem.getTagName());
    }                   
        
    //
    // Implementation of org.xml.sax.Locator.
    //

    /**
    * getPublicId() is needed to implement the Locator interface,
    * but always returns null
    */

    public String getPublicId ()
    {
        return null;		// TODO
    }
    /**
    * getSystemId() is needed to implement the Locator interface,
    * but always returns null
    */
    
    public String getSystemId ()
    {
        return null;
    }

    /**
    * getLineNumber() is needed to implement the Locator interface,
    * but always returns -1
    */

    public int getLineNumber ()
    {
        return -1;
    }

    /**
    * getColumnNumber() is needed to implement the Locator interface,
    * but always returns -1
    */
    
    public int getColumnNumber ()
    {
        return -1;
    }

    /**
    * Get the DOM Element we are currently at. This method is used by SAXON
    * as a call-back on the Locator object returned by the SAX
    * setLocator() interface.
    */

    public Element getCurrentElement ()
    {
        return currentElement;
    }

}
