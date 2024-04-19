package com.icl.saxon;
import org.xml.sax.SAXException;

// Copyright © International Computers Limited 1998
// See conditions of use

/**
  * Class GroupRenderer()<P>
  * A general-purpose element handler for processing a sequence of elements
  * of the same type.<P>
  */


public class GroupRenderer extends ElementCopier {

    private String beforeFirstOfType;
    private String betweenEach;
    private String afterLastOfType;

    /**
      * Constructor initialises default actions.<BR>
      * @param before String to be output before a group of one or more elements
      * @param between String to be output between adjacent elements
      * @param after String to be output after a group of one or more elements
      */

    public GroupRenderer (String before, String between, String after) {
        betweenEach = between;
        beforeFirstOfType = before;
        afterLastOfType = after;
    }

    /**
    * Before a group of one or more consecutive elements, output the 
    * registered "before" string
    */
    
    public void beforeGroup(ElementInfo e) throws SAXException {
        e.write(beforeFirstOfType);
    }

    /**
    * Before an element, output the registered "between" string if this
    * is not the first element of a group
    */

    public void startElement(ElementInfo e) throws SAXException {
        if (!e.isFirstOfType()) 
            e.write(betweenEach);
    }

    /**
    * After an element, output nothing
    */

    public void endElement(ElementInfo e) {}

    /**
    * After a group of one or more consecutive elements, output the 
    * registered "after" string
    */
    public void afterGroup(ElementInfo e) throws SAXException {
        e.write(afterLastOfType);
    }
 
}  
