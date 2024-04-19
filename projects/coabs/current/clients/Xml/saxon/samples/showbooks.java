import com.icl.saxon.*;
import java.util.*;
import java.io.*;
import org.xml.sax.SAXException;

// Copyright © International Computers Limited 1998
// See conditions of use

/**
  * Class ShowBooks
  * This class produces an HTML rendition of a List of Books supplied in XML.
  * The example demonstrates how to produce a sorted table.<P>
  * It is intended to be run with the input file books.xml (which is
  * adapted from the MSXML distribution).
  *
  * @author Michael H. Kay (M.H.Kay@eng.icl.co.uk)
  * @version 15 Jun 1998
  */
  
public class ShowBooks extends Renderer
{   
    /**
      * main()<BR>
      * Expects one argument, the input filename<BR>
      * It produces an HTML rendition on the standard output<BR>
      */

    public static void main (String args[])
    throws java.lang.Exception
    {
        // Check the command-line arguments

        if (args.length != 1) {
            System.err.println("Usage: java ShowBooks input-file >output-file");
            System.exit(1);
        }
        ShowBooks app = new ShowBooks();

        // Invoke the application.
        app.prepare();
        app.run ( new ExtendedInputSource( new File(args[0]) ) );
        
        System.exit(0);
    }

    public void prepare() {

        setOption( RETAIN_ATTRIBUTES, true );
        setOption( RETAIN_CONTENT, true );

        // define how each XML element type should be handled

        setHandler( "AUTHOR", new AttributeHandler() );
        setHandler( "PUBLISHER", new AttributeHandler() );
        setHandler( "PRICE", new AttributeHandler() );
        setHandler( "QUANTITY", new AttributeHandler() );
        setHandler( "TITLE", new AttributeHandler() );

        setItemRendition( "BOOKS",
              "<HTML><HEAD><TITLE>Book List</TITLE></HEAD><BODY><H1>Book List</H1>",
              "</BODY></HTML>" );

        String head = "<TR><TH>Author</TH>" +
                        "<TH>Title</TH>" +
                        "<TH>Publisher</TH>" +
                        "<TH>Quantity</TH>" +
                        "<TH>Price</TH></TR>";
        
        setHandler( "ITEM",
            new ItemSorter( "AUTHOR",                           // sort on author
                            "<TABLE BORDER>" + head + "<TR>",   // start of table
                            "</TR><TR>",                        // between items
                            "</TR></TABLE>" )                   // end of table
                         );          
    }
    
    private class AttributeHandler extends ElementHandlerBase {
       
        public void endElement( ElementInfo e ) {
            // make the content into a pseudo-attribute of the owning ITEM element
            String att = e.getExtendedAttribute("*");
            e.setExtendedAttribute("ITEM", e.getTag(), att);
        }
    }

    private class ItemSorter extends ElementSorter {
        
        public ItemSorter (String sortkey, String before, String between, String after)
        {
            super(sortkey, before, between, after);
        }
            
        public void endElement( ElementInfo e ) throws SAXException {
            // pick up the values of the pseudo-attributes created from child elements
            String author   = e.getExtendedAttribute( "AUTHOR" );
            String title    = e.getExtendedAttribute( "TITLE" );
            String publisher= e.getExtendedAttribute( "PUBLISHER" );
            String quantity = e.getExtendedAttribute( "QUANTITY" );
            String price    = e.getExtendedAttribute( "PRICE" );

            e.write("<TD>" + (author==null?"":author) + "</TD>");
            e.write("<TD>" + (title==null?"":title) + "</TD>");
            e.write("<TD>" + (publisher==null?"":publisher) + "</TD>");
            e.write("<TD>" + (quantity==null?"":quantity) + "</TD>");
            e.write("<TD>" + (price==null?"":price) + "</TD>");

            super.endElement(e);
        }
    }          			
} 
