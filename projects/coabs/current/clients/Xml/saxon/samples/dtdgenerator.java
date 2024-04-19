import org.xml.sax.AttributeList;
import com.icl.saxon.*;

import java.net.URL;
import java.util.*;
import java.io.*;

/**
* DTDGenerator<BR>
* Generates a possible DTD from an XML document instance.
* Uses SAXON to process the document contents.
* @author M.H.Kay
* @version 12 May 1998
*/

public class DTDGenerator extends Distributor {

  BinaryTree elementList;

  /**
    * Entry point
    * Usage:  java DTDGenerator input-file >output-file
    */

    public static void main (String args[])
        throws java.lang.Exception
    {
				// Check the command-line arguments.
        if (args.length != 1) {
            System.err.println("Usage: java DTDGen input-file >output-file");
            System.exit(1);
        } 

                // Instantiate and run the application
        DTDGenerator app = new DTDGenerator();
        app.prepare();
        app.run(new ExtendedInputSource(new File(args[0])));
        app.printDTD();
    }

    public DTDGenerator () 
    {
        elementList = new BinaryTree();
    }

    /**
    * Set the element handler for all elements
    */

    private void prepare ()
    {
        setDefaultHandler( new ElemHandler() );
    }
  
    /**
    * When the whole document has been analysed, construct the DTD
    */
    
    private void printDTD ()
    {
        // process the element types encountered, in turn

        Enumeration e=elementList.keys();
        while ( e.hasMoreElements() )
        {
            String elementname = (String) e.nextElement();
            ElementDetails ed = (ElementDetails) elementList.get(elementname);
 
            Vector children = ed.children;

            //EMPTY content
            if (children.isEmpty() && !ed.hasCharacterContent) 
                System.out.print("<!ELEMENT " + elementname + " EMPTY >\n");

            //CHARACTER content
            if (children.isEmpty() && ed.hasCharacterContent)
                System.out.print("<!ELEMENT " + elementname + " ( #PCDATA ) >\n");

            //ELEMENT content
            if (!(children.isEmpty()) && !ed.hasCharacterContent) {
                System.out.print("<!ELEMENT " + elementname + " ( ");
                Enumeration c=children.elements();
                while (true)
                {
                    String child = (String) c.nextElement();
                    System.out.print(child);
                    if (c.hasMoreElements())
                        System.out.print(" | ");
                    else
                        break;
                };
                System.out.print(" )* >\n");
            };

            //MIXED content
            if (!(children.isEmpty()) && ed.hasCharacterContent) {
                System.out.print("<!ELEMENT " + elementname + " ( #PCDATA");
                for (Enumeration c=children.elements(); c.hasMoreElements(); )
                {
                    String child = (String) c.nextElement();
                    System.out.print(" | " + child);
                };
                System.out.print(" )* >\n");
            };

            //Now examine the attributes encountered for this element type

            BinaryTree attlist = ed.attributes;
            Enumeration a=attlist.keys();
            while ( a.hasMoreElements() )
            {
                String attname = (String) a.nextElement();
                AttributeDetails ad = (AttributeDetails) attlist.get(attname);

                boolean required = (ad.occurrences==ed.occurrences);
                boolean isid = (ad.values.size()==ad.occurrences) && (ad.occurrences>10);
                boolean isenum = (ad.occurrences>10) && 
                                (ad.values.size()<=ad.occurrences/3) &&
                                (ad.values.size()<10);

                System.out.print("<!ATTLIST " + elementname + " " + attname + " ");

                if (isid) 
                    System.out.print("ID");
                else if (isenum)
                {
                    System.out.print("( ");
                    Enumeration v=ad.values.keys();
                    while (true)
                    {   String val = (String) v.nextElement();
                        System.out.print(val);
                        if (v.hasMoreElements())
                            System.out.print(" | ");
                        else
                            break;
                    };
                    System.out.print(" )");
                }
                else
                    System.out.print("CDATA");

                if (required)
                    System.out.print(" #REQUIRED >\n");
                else if (ad.dflt!=null)
                    System.out.print(" \"" + ad.dflt + "\" >\n");
                else
                    System.out.print(" #IMPLIED >\n");
            };
            System.out.print("\n");
        };
   
    }

    // inner classes

    /**
    * Element handler processes each element in turn
    */

    private class ElemHandler extends ElementHandlerBase {

    /**
    * Handle the start of an element 
    */
    public void startElement (ElementInfo e)
    {
        AttributeList atts = e.getAttributeList();
        String name = e.getTag();
        ElementDetails ed = (ElementDetails) elementList.get(name);
        if (ed==null)  { 
            ed = new ElementDetails(name);
            elementList.put(name,ed);
        };
        e.setUserData(ed);
        
        // count occurrences of this element type

        ed.occurrences++;

        // Handle the attributes accumulated for this element.
        // Merge the new attribute list into the existing list for the element

        for (int i = 0; i < atts.getLength(); i++) {
            String att = atts.getName(i);
            String val = atts.getValue(i);
 
            AttributeDetails ad = (AttributeDetails) ed.attributes.get(att);
            if (ad==null) {
               ad=new AttributeDetails(att);
               ed.attributes.put(att, ad);
            };
 
            ad.values.put(val, Boolean.TRUE); //dummy value to indicate presence
            ad.occurrences++;
        };

        // now keep track of the nesting of elements

        if (!e.isRoot()) {
            ElementDetails parent = (ElementDetails)e.getParent().getUserData();
            Vector children = parent.children;
            if (!children.contains(name)) children.addElement(name);
        };
    }

    /**
    * Handle character data.
    * Make a note whether significant character data is found in the element
    */
    public void characters (ElementInfo e, char ch[], int start, int length)
    {
        String s = new String(ch, start, length);
        if (s.trim().length()>0) 
            ((ElementDetails)e.getUserData()).hasCharacterContent = true;
    }

    } // end of inner class ElemHandler

    /**
    * ElementDetails is a data structure to keep information about element types
    */

    private class ElementDetails {
        String name;
        int occurrences;
        boolean hasCharacterContent;
        Vector children;
        BinaryTree attributes;

        public ElementDetails ( String name ) {
            this.name = name;
            this.occurrences = 0;
            this.hasCharacterContent = false;
            this.children = new Vector();
            this.attributes = new BinaryTree();
        }
    }

    /**
    * AttributeDetails is a data structure to keep information about attribute types
    */

    private class AttributeDetails {
        String name;
        String dflt;
        int occurrences;
        BinaryTree values; //used as a set

        public AttributeDetails ( String name ) {
            this.name = name;
            this.occurrences = 0;
            this.values = new BinaryTree();
        }
    }


} // end of outer class DTDGen

