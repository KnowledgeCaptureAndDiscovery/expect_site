import java.util.*;
import java.io.*;
import java.net.*;
import com.icl.saxon.*;
import org.xml.sax.SAXException;


/******************************************************************
* Class LoadPlay<P>
* This program takes a Shakespeare play in XML form and splits it
* into a number of output XML files: play.xml and sceneN.xml (one per
* scene) in an output directory.<P>
* Usage: java LoadPlay <I>play-name</I><BR>
* where <I>play-name</I> identifies the play. The input XML file
* is in <I>play-name.xml</I>; the output files will be created in
* a directory called <I>play-name</I>, which is created if necessary.
*/

class LoadPlay extends Renderer
{

    private int sceneNr;                // scene number within play, starts at 1
    private String outputDir;           // output directory
    private String playName;            // name of play, as supplied on input
    private String actTitle;            // title of current act
    private String playTitle;           // full title of play
    
    /**
    * command-line interface.<BR>
    * Takes a single argument, the name of a play<BR>
    * Expects to find the XML in [play].xml<BR>
    * Creates output files in the directory called [play]
    */

    public static void main (String args[])
    throws java.lang.Exception
    {
        // Check the command-line arguments

        if (args.length != 1) {
            System.err.println("Usage: java LoadPlay name-of-play");
            System.exit(1);
        }
        
        // Instantiate the loader and run it
        
        LoadPlay d = new LoadPlay();
        d.load( args[0] );
    }

    /**
    * Process a play, generating multiple output files
    * @param play The name of the play (the input must be in "<I>play</I>.xml")
    */

    public void load(String play) throws java.lang.Exception {
    
        sceneNr = 0;

        // set up the element handlers
 
        setHandler("PLAY", new ElementHandlerBase()); // this handler does nothing

        setHandler("ACT/TITLE", new ACTTITLEHandler());
        setHandler("PLAY/TITLE", new PLAYTITLEHandler());

        setHandler("SCENE", new SCENEHandler());
        setHandler("PROLOGUE", new SCENEHandler());
        setHandler("EPILOGUE", new SCENEHandler());
 
        setHandler("SCENE/TITLE", new SCTITLEHandler());
        setHandler("PROLOGUE/TITLE", new SCTITLEHandler());
        setHandler("EPILOGUE/TITLE", new SCTITLEHandler());
       
        // Remember the name of the play
        
        playName = play;

        // Check the input file is OK
        
        String inputFile = play + ".xml";
        File f = new File(inputFile);
        if (!f.exists() || f.isDirectory() || !f.canRead()) {
            System.err.println("Cannot read from " + inputFile + "!");
            System.exit(2);
        }
        
        // Determine the output directory, create it if necessary
        
        outputDir = play;
        File dir = new File(outputDir);
        if (dir.exists()) {
            if (!dir.isDirectory()) {
                System.err.println(outputDir + " exists but is not a directory!");
                System.exit(2);
            }
        } else {
            try {
                dir.mkdir();
            }
            catch (Exception e) {
                System.err.println("Cannot create output directory " + outputDir);
            }
        }

        // Define output Writers for different parts of the XML input document
        // (Note: we will define an output writer for each SCENE instance later)
        
        StringWriter playSW = new StringWriter();
        setWriter("PLAY", playSW);   // temporary holding place for the output play file
        setNullWriter("FM");  // this part of the XML is discarded

	    // Process the XML
        
        int result = run ( new ExtendedInputSource( new File(inputFile) ) );

        // Produce the play output file

        String playFile = outputDir + "\\play.xml";
        PrintWriter playWriter = new PrintWriter(new FileWriter(playFile));
        playWriter.write("<PLAY NAME='" + play +
                         "' SCENES='" + sceneNr + "'>\n");
        playWriter.write(playSW.toString());
        playWriter.write("\n</PLAY>\n");
        playWriter.close();
   
    }

// element handler classes (inner classes)

    /**
    * Handle a SCENE element. At start, increment the scene number;
    * output a SCENE tag with additional attributes PLAY and SCENE.
    * At the end of the scene, output summary details
    * to the PLAY file in the form of a cross-reference.
    */


class SCENEHandler extends ElementHandlerBase {
    
    public void startElement(ElementInfo e) throws SAXException {
        sceneNr++;

        // start a new output file for this scene
        
        String fileName = outputDir + "\\scene" + sceneNr + ".xml";
        try {
            FileWriter sceneFile = new FileWriter(fileName);
            e.setWriter(sceneFile);
        } catch (java.io.IOException err) {
            throw new SAXException("Cannot write to " + fileName, err);
        }
        e.write("<SCENE SCENE='" + sceneNr + "'>");
        e.write("<CONTEXT><PLAY NAME='" + playName +
                                "' TITLE='" + playTitle + "'/>\n");
        e.write("<ACT TITLE='" + actTitle + "'/>\n");
        e.write("</CONTEXT>\n");
    }

    public void endElement(ElementInfo e) throws SAXException {
        e.write("</SCENE>");
    }
}

/**
* Handler for PLAY TITLE is standard except we remember the content
*/

class PLAYTITLEHandler extends ElementCopier {

    public void characters(ElementInfo e, char ch[], int start, int length)
    throws SAXException {
        super.characters(e, ch, start, length);
        playTitle = escape(ch, start, length);
    }
}

/**
* Handler for ACT TITLE is standard except we remember the content
*/

class ACTTITLEHandler extends ElementCopier {

    public void characters(ElementInfo e, char ch[], int start, int length)
    throws SAXException {
        super.characters(e, ch, start, length);
        actTitle = escape(ch, start, length);
    }
}

class SCTITLEHandler extends ElementCopier {

    public void startElement(ElementInfo e) throws SAXException {
        e.write("<SCTITLE SCENE='" + sceneNr + "'>");       
    }

    public void endElement(ElementInfo e) throws SAXException {
        e.write("</SCTITLE>\n");
    }

    public void characters(ElementInfo e, char ch[], int start, int length)
    throws SAXException {
        e.writeEscape(ch, start, length);
        
        // output the scene title also to the play file
        // We do this by writing to the PrintWriter for the PLAY element

        ElementInfo p = e.getAncestor("PLAY");
        p.write("<SCTITLE SCENE='" + sceneNr + "'>");
        p.writeEscape(ch, start, length);;
        p.write("</SCTITLE>\n");

    }
}


} // end of outer class

