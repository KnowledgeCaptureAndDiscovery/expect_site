package com.icl.saxon;
import org.xml.sax.SAXException;

// Copyright © International Computers Limited 1998
// See conditions of use

/**
  * Class ItemHandler()<P>
  * A general-purpose element handler that outputs the target
  * element with a supplied prefix and suffix.<P>
  * Typically used via the setItemRendition method of class
  * Renderer.<P>
  */


public class ItemRenderer extends ElementCopier {

    private String beforeEach;
    private String afterEach;
    private boolean beforeSubstitutes;
    private boolean afterSubstitutes;

    /**
      * Constructor initialises default actions.<BR>
      * Note that attribute values can be substituted into either string, using
      * the notation "«element/attribute»". Two special attribute names are
      * recognised: "*" meaning the character content of the element, and
      * "#" meaning its element number (allocated only if element numbering is
      * in use.)
      * @param before String to be output before each instance of the element
      * @param after String to be output after each instance of the element
      */

    public ItemRenderer (String before, String after) {
        beforeEach = before;
        afterEach = after;

        // performance optimisation: check whether strings might contain parameters
        beforeSubstitutes = (before.indexOf("«", 0) >= 0);
        afterSubstitutes = (after.indexOf("«", 0) >= 0);
        
    }

    /**
    * Output prefix string at start of element
    */

    public void startElement(ElementInfo e) throws SAXException {
        if (beforeSubstitutes) 
            e.write(e.format(beforeEach));
        else
            e.write(beforeEach);
    }

    /**
    * Output suffix string at end of element
    */

    public void endElement(ElementInfo e) throws SAXException {
        if (afterSubstitutes)
            e.write(e.format(afterEach));
        else
            e.write(afterEach);
    }

}  
