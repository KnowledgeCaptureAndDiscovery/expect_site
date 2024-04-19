package com.icl.saxon;

// Copyright © International Computers Limited 1998
// See conditions of use

/**
  * Class NumberHandler<P>
  * An element handler that supports automatic numbering of elements within
  * a document.<P>
  * Elements of the defined type are numbered consecutively within the
  * document starting at one. Numbering restarts at one within each instance
  * of the specified base element type; if numbering is to be continuous,
  * specify the root element as the base element type.<P>
  * It the base element is also numbered, there is an option to concatenate
  * the element numbers of this element with those of the base element.<P>
  * The element number is generated in the form of a pseudo-attribute called
  * "#". It may be accessed by calling <B>getExtendedAttribute()</B> with "#"
  * as the attribute name, or by using textual substitution in the <B>format()</B>
  * method invoked by <B>ItemRenderer</B>
  * @author M.H.Kay (M.H.Kay@eng.icl.co.uk)
  * @version 8 May 1998
  */


public class NumberHandler extends ElementHandlerBase {

    private String baseTag;
    private ElementInfo currentAncestor;
    private int currentNumber;
    private boolean concatenate;

    /**
      * Constructor supplies parameters to control numbering. 
      * @param baseTag An ancestor element to act as the nunbering base:
      * numbers are reset to one when a new ancestor element occurs.
      * @param concatenate True if numbers are to be concatenated with the
      * numbers of the base element.
      */

    public NumberHandler (String base, boolean concat) {
        baseTag = base;
        concatenate = concat;
        currentNumber = 0;
        currentAncestor = null;
    }

    /**
    * Handle start of element<BR>
    * This implementation generates a number.
    */

    public void startElement(ElementInfo e) {
        ElementInfo ancestor = e.getAncestor(baseTag);
        if (ancestor==null) 
            e.setExtendedAttribute("#", "0");
        else {
            if (ancestor==currentAncestor) 
                currentNumber++;
            else 
                currentNumber=1;
                
            if (concatenate)
                e.setExtendedAttribute("#",
                    e.getExtendedAttribute(baseTag, "#") +
                         "." + Integer.toString(currentNumber));
            else
                e.setExtendedAttribute("#", Integer.toString(currentNumber));
                
            currentAncestor=ancestor;
        }
    }

}  
