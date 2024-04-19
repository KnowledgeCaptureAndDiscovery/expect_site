/*
 * @(#)PublicMapping.java	1.1 95/04/23  
 *
 * Copyright (c) 1994 Sun Microsystems, Inc. All Rights Reserved.
 *
 * Permission to use, copy, modify, and distribute this software
 * and its documentation for NON-COMMERCIAL purposes and without
 * fee is hereby granted provided that this copyright notice
 * appears in all copies. Please refer to the file "copyright.html"
 * for further important copyright and licensing information.
 *
 * SUN MAKES NO REPRESENTATIONS OR WARRANTIES ABOUT THE SUITABILITY OF
 * THE SOFTWARE, EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED
 * TO THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
 * PARTICULAR PURPOSE, OR NON-INFRINGEMENT. SUN SHALL NOT BE LIABLE FOR
 * ANY DAMAGES SUFFERED BY LICENSEE AS A RESULT OF USING, MODIFYING OR
 * DISTRIBUTING THIS SOFTWARE OR ITS DERIVATIVES.
 */

package html;

import java.io.File;
import java.io.InputStream;
import java.io.FileInputStream;
import java.io.DataInputStream;
import java.io.BufferedInputStream;
import java.io.StringBufferInputStream;
import java.util.Hashtable;
//import net.www.html.URL;
import java.net.URL;                            //??dk
import java.io.IOException;                     //??dk
import java.io.FileNotFoundException;           //??dk

/**
 * A class for mapping public identifiers to URLs.
 *
 * @version 	1.1, 23 Apr 1995
 * @author Arthur van Hoff
 * @modified Dmitri Kondratiev for JDK Beta 2 05/01/96 //??dk
 */
public class PublicMapping
{
    String dir;
    Hashtable tab = new Hashtable();

    /**
     * Create a mapping given a base URL.
     */
    public PublicMapping (String dir) throws FileNotFoundException, IOException
    {   //??dk
	this.dir = dir;
	load (new StringBufferInputStream(MAPPING));

//	load (new FileInputStream(dir + File.separator + "public.map"));
    }

    /**
     * Load a set of mappings from a stream.
     */
    public void load(InputStream in) throws IOException {             //??dk
	DataInputStream data = new DataInputStream(in);

	for (String ln = data.readLine() ; ln != null ; ln = data.readLine()) {
	    if (ln.startsWith("PUBLIC")) {
		int len = ln.length();
		int i = 6;
		while ((i < len) && (ln.charAt(i) != '"')) i++;
		int j = ++i;
		while ((j < len) && (ln.charAt(j) != '"')) j++;
		String id = ln.substring(i, j);
		i = ++j;
		while ((i < len) && ((ln.charAt(i) == ' ') || (ln.charAt(i) == '\t'))) i++;
		j = i + 1;
		while ((j < len) && (ln.charAt(j) != ' ') && (ln.charAt(j) != '\t')) j++;
		String where = ln.substring(i, j);
		put(id, where);
	    }
	}
	data.close();
    }

    /**
     * Add a mapping from a public identifier to a URL.
     */
    public void put(String id, String where) {
	tab.put(id, where);
	if (where.endsWith(".dtd")) {
	    tab.put(where.substring(where.lastIndexOf(File.separatorChar) + 1, where.length() - 4), where);
	}
    }

    /**
     * Map a public identifier to a URL. You can also map
     * a DTD file name (without the .dtd) to a URL.
     */
    public InputStream get(String id) throws FileNotFoundException
    {
      return new StringBufferInputStream (HTML2NET);

//      return new BufferedInputStream (new FileInputStream
//        (dir + File.separator + tab.get(id)));
    }

  final static String MAPPING =

  "-- Ways to refer to Level 2: most general to most specific --\n" +
  "PUBLIC  \"-//IETF//DTD HTML//EN\"                 html2.dtd\n" +
  "PUBLIC  \"-//IETF//DTD HTML 2.0//EN\"             html2.dtd\n" +
  "PUBLIC  \"-//IETF//DTD HTML Level 2//EN\"         html2.dtd\n" +
  "PUBLIC  \"-//IETF//DTD HTML 2.0 Level 2//EN\"     html2.dtd\n" +
  "-- Ways to refer to Level 1: most general to most specific --\n" +
  "PUBLIC  \"-//IETF//DTD HTML Level 1//EN\"         html2-1.dtd\n" +
  "PUBLIC  \"-//IETF//DTD HTML 2.0 Level 1//EN\"     html2-1.dtd\n" +
  "-- Ways to refer to Level 0: most general to most specific --\n" +
  "PUBLIC  \"-//IETF//DTD HTML Level 0//EN\"         html2-0.dtd\n" +
  "PUBLIC  \"-//IETF//DTD HTML 2.0 Level 0//EN\"     html2-0.dtd\n" +
  "-- Ways to refer to Strict Level 2: most general to most specific --\n" +
  "PUBLIC  \"-//IETF//DTD HTML Strict//EN\"                  html2-s.dtd\n" +
  "PUBLIC  \"-//IETF//DTD HTML 2.0 Strict//EN\"              html2-s.dtd\n" +
  "PUBLIC  \"-//IETF//DTD HTML Strict Level 2//EN\"          html2-s.dtd\n" +
  "PUBLIC  \"-//IETF//DTD HTML 2.0 Strict Level 2//EN\"      html2-s.dtd\n" +
  "-- Ways to refer to Strict Level 1: most general to most specific --\n" +
  "PUBLIC  \"-//IETF//DTD HTML Strict Level 1//EN\"          html2-1s.dtd\n" +
  "PUBLIC  \"-//IETF//DTD HTML 2.0 Strict Level 1//EN\"      html2-1s.dtd\n" +
  "-- Ways to refer to Strict Level 0: most general to most specific --\n" +
  "PUBLIC  \"-//IETF//DTD HTML Strict Level 0//EN\"          html2-0s.dtd\n" +
  "PUBLIC  \"-//IETF//DTD HTML 2.0 Strict Level 0//EN\"      html2-0s.dtd\n" +
  "-- ISO latin 1 entity set for HTML --\n" +
  "PUBLIC  \"ISO 8879-1986//ENTITIES Added Latin 1//EN//HTML\" ISOlat1.sgml\n"+
  "-- Netscape --\n" +
  "PUBLIC  \"-//Mosaic Comm. Corp.//DTD HTML//EN//2.0mcom\" html2-net.dtd\n"+
  "-- HTML 3 --\n" +
  "PUBLIC  \"-//IETF//DTD HTML 3.0//EN\" html3.dtd\n";

  final static String HTML2NET =

"<!--	html-mcom.dtd\n"+
"\n"+
"        Document Type Definition for the HyperText Markup Language (HTML DTD)\n"+
"	with Mosaic Communications Copr Extensions\n"+
"\n"+
"	SoftQuad SCCS @(#)html.dtd      @(#)html-net.dtd	1.1 95/01/24\n"+
"	$Id: html-mcom.dtd,v 1.1 1994/10/06 17:42:49 connolly Exp $\n"+
"\n"+
"	Author: Daniel W. Connolly <connolly@hal.com>\n"+
"	See Also: html.decl, ISOlat1.sgml\n"+
"		  http://home.mcom.com/home/frosting.html\n"+
"		  http://www.hal.com/%7Econnolly/html-spec/index.html\n"+
"		  http://info.cern.ch/hypertext/WWW/MarkUp2/MarkUp.html\n"+
"-->\n"+
"\n"+
"<!--     Modified by SoftQuad to add BLINK element, and START attribute on\n"+
"        UL, LI\n"+
"-->\n"+
"\n"+
"<!ENTITY % HTML.Version\n"+
"	\"-//Mosaic Comm. Corp.//DTD HTML//EN//2.0mcom\"\n"+
"\n"+
"        -- Typical usage:\n"+
"\n"+
"            <!DOCTYPE HTML PUBLIC \"-//Mosaic Comm. Corp.//DTD HTML//EN\">\n"+
"	    <html>\n"+
"	    ...\n"+
"	    </html>\n"+
"	--\n"+
"	>\n"+
"\n"+
"\n"+
"<!--================== Feature Test Entities ==============================-->\n"+
"\n"+
"<!ENTITY % HTML.Recommended \"IGNORE\"\n"+
"	-- Certain features of the language are necessary for compatibility\n"+
"	   with widespread usage, but they may compromise the structural\n"+
"	   integrity of a document. This feature test entity enables\n"+
"	   a more prescriptive document type definition that eliminates\n"+
"	   the above features.\n"+
"	-->\n"+
"\n"+
"<![ %HTML.Recommended [\n"+
"	<!ENTITY % HTML.Deprecated \"IGNORE\">\n"+
"]]>\n"+
"\n"+
"<!ENTITY % HTML.Deprecated \"INCLUDE\"\n"+
"	-- Certain features of the language are necessary for compatibility\n"+
"	   with earlier versions of the specification, but they tend\n"+
"	   to be used an implemented inconsistently, and their use is\n"+
"	   deprecated. This feature test entity enables a document type\n"+
"	   definition that eliminates these features.\n"+
"	-->\n"+
"\n"+
"<!ENTITY % HTML.Highlighting \"INCLUDE\">\n"+
"<!ENTITY % HTML.Forms \"INCLUDE\">\n"+
"\n"+
"<!--================== Imported Names =====================================-->\n"+
"\n"+
"<!ENTITY % Content-Type \"CDATA\"\n"+
"	-- meaning a MIME content type, as per RFC1521\n"+
"	-->\n"+
"\n"+
"<!ENTITY % HTTP-Method \"GET | POST\"\n"+
"	-- as per HTTP specification\n"+
"	-->\n"+
"\n"+
"<!ENTITY % URI \"CDATA\"\n"+
"        -- The term URI means a CDATA attribute\n"+
"           whose value is a Uniform Resource Identifier,\n"+
"           as defined by \n"+
"	\"Universal Resource Identifiers\" by Tim Berners-Lee\n"+
"	aka http://info.cern.ch/hypertext/WWW/Addressing/URL/URI_Overview.html\n"+
"	aka RFC 1630\n"+
"\n"+
"	Note that CDATA attributes are limited by the LITLEN\n"+
"	capacity (1024 in the current version of html.decl),\n"+
"	so that URIs in HTML have a bounded length.\n"+
"\n"+
"        -->\n"+
"\n"+
"\n"+
"<!-- DTD \"macros\" -->\n"+
"\n"+
"<!ENTITY % heading \"H1|H2|H3|H4|H5|H6\">\n"+
"\n"+
"<!ENTITY % list \" UL | OL | DIR | MENU \" >\n"+
"\n"+
"\n"+
"<!--================ Character mnemonic entities ==========================-->\n"+
"\n"+
"<!ENTITY % ISOlat1 SYSTEM \"lat1html.ent\">\n"+
"%ISOlat1;\n"+
"\n"+
"<!ENTITY amp CDATA \"&#38;\"     -- ampersand          -->\n"+
"<!ENTITY gt CDATA \"&#62;\"      -- greater than       -->\n"+
"<!ENTITY lt CDATA \"&#60;\"      -- less than          -->\n"+
"<!ENTITY quot CDATA \"&#34;\"    -- double quote       -->\n"+
"\n"+
"<!ENTITY reg  CDATA \"&#174;\"    -- registered trademark -->\n"+
"<!ENTITY copy CDATA \"&#169;\"    -- copyright            -->\n"+
"\n"+
"<!--=================== Text Markup =======================================-->\n"+
"\n"+
"<![ %HTML.Highlighting [\n"+
"\n"+
"<!ENTITY % font \" TT | B | I | FONT\">\n"+
"\n"+
"<!ENTITY % phrase \"EM | STRONG | CODE | SAMP | KBD | VAR | CITE \">\n"+
"\n"+
"<!ENTITY % text \"#PCDATA | A | IMG | BR | WBR | NOBR | CENTER | BASEFONT\n"+
"		 | BLINK | %phrase | %font | APPLET | APP\">\n"+
"\n"+
"<!ENTITY % pre.content \"#PCDATA | A | HR | BR | IMG | %font | %phrase\">\n"+
"\n"+
"<!ELEMENT (%font;|%phrase) - - (%text)+>\n"+
"\n"+
"<!ELEMENT basefont - - ANY>\n"+
"<!ATTLIST (font|basefont)\n"+
"	SIZE CDATA #REQUIRED -- should be NUTOKEN, using size=plus3, e.g.-->\n"+
"]]>\n"+
"\n"+
"<!ENTITY % text \"#PCDATA | A | IMG | BR | WBR | NOBR | CENTER\">\n"+
"\n"+
"<!ELEMENT BLINK - - ANY>\n"+
"\n"+
"<!ELEMENT CENTER - - ANY>\n"+
"\n"+
"<!ELEMENT BR    - O EMPTY>\n"+
"<!ATTLIST BR\n"+
"	CLEAR (left|right|all) #IMPLIED>\n"+
"\n"+
"<!ELEMENT NOBR - - (%text)+>\n"+
"<!ELEMENT WBR  - O EMPTY>\n"+
"\n"+
"<!--================== Link Markup ========================================-->\n"+
"\n"+
"<![ %HTML.Recommended [\n"+
"	<!ENTITY % linkName \"ID\">\n"+
"]]>\n"+
"\n"+
"<!ENTITY % linkName \"CDATA\">\n"+
"\n"+
"<!ENTITY % linkType \"NAME\"\n"+
"	-- a list of these will be specified at a later date -->\n"+
"\n"+
"<!ENTITY % linkExtraAttributes\n"+
"        \"REL %linkType #IMPLIED -- forward relationship type --\n"+
"        REV %linkType #IMPLIED -- reversed relationship type\n"+
"                              to referent data --\n"+
"        URN CDATA #IMPLIED -- universal resource number --\n"+
"\n"+
"        TITLE CDATA #IMPLIED -- advisory only --\n"+
"        METHODS NAMES #IMPLIED -- supported public methods of the object:\n"+
"                                        TEXTSEARCH, GET, HEAD, ... --\n"+
"        \">\n"+
"\n"+
"<![ %HTML.Recommended [\n"+
"	<!ENTITY % A.content   \"(%text)+\"\n"+
"	-- <H1><a name=\"xxx\">Heading</a></H1>\n"+
"		is preferred to\n"+
"	   <a name=\"xxx\"><H1>Heading</H1></a>\n"+
"	-->\n"+
"]]>\n"+
"\n"+
"<!ENTITY % A.content   \"(%heading|%text)+\">\n"+
"\n"+
"<!ELEMENT A     - - %A.content -(A)>\n"+
"\n"+
"<!ATTLIST A\n"+
"	HREF %URI #IMPLIED\n"+
"	NAME %linkName #IMPLIED\n"+
"        %linkExtraAttributes;\n"+
"        >\n"+
"\n"+
"<!--=================== Images ============================================-->\n"+
"\n"+
"<!ENTITY % img.alt.default \"#IMPLIED\"\n"+
"	-- ALT attribute required in Level 0 docs -->\n"+
"\n"+
"<!ELEMENT IMG    - O EMPTY --  Embedded image -->\n"+
"<!ATTLIST IMG\n"+
"        SRC %URI;  #REQUIRED     -- URI of document to embed --\n"+
"	ALT CDATA %img.alt.default;\n"+
"	ALIGN (left|right|top|texttop|middle|\n"+
"		absmiddle|baseline|bottom|absbottom) baseline\n"+
"	WIDTH NUMBER #IMPLIED\n"+
"	HEIGHT NUMBER #IMPLIED\n"+
"	BORDER NUMBER #IMPLIED\n"+
"	VSPACE NUMBER #IMPLIED\n"+
"	HSPACE NUMBER #IMPLIED\n"+
"        ISMAP (ISMAP) #IMPLIED\n"+
"        >\n"+
"\n"+
"\n"+
"<!--=================== Paragraphs=========================================-->\n"+
"\n"+
"<!ELEMENT P     - O (%text)+>\n"+
"\n"+
"\n"+
"<!--=================== Headings, Titles, Sections ========================-->\n"+
"\n"+
"<!ELEMENT HR    - O EMPTY -- horizontal rule -->\n"+
"<!ATTLIST HR\n"+
"	SIZE NUMBER #IMPLIED\n"+
"	WIDTH NUTOKEN #IMPLIED\n"+
"	ALIGN (left|right|center) #IMPLIED\n"+
"	NOSHADE (NOSHADE) #IMPLIED>\n"+
"\n"+
"<!ELEMENT ( %heading )  - -  (%text;)+>\n"+
"\n"+
"<!ELEMENT TITLE - -  (#PCDATA)\n"+
"          -- The TITLE element is not considered part of the flow of text.\n"+
"             It should be displayed, for example as the page header or\n"+
"             window title.\n"+
"          -->\n"+
"\n"+
"\n"+
"<!--=================== Text Flows ========================================-->\n"+
"\n"+
"<![ %HTML.Forms [\n"+
"	<!ENTITY % block.forms \"| FORM | ISINDEX\">\n"+
"]]>\n"+
"\n"+
"<!ENTITY % block.forms \"\">\n"+
"\n"+
"<![ %HTML.Deprecated [\n"+
"	<!ENTITY % preformatted \"PRE | XMP | LISTING\">\n"+
"]]>\n"+
"\n"+
"<!ENTITY % preformatted \"PRE\">\n"+
"\n"+
"<!ENTITY % block \"P | %list | DL\n"+
"	| %preformatted\n"+
"	| BLOCKQUOTE %block.forms\">\n"+
"\n"+
"<!ENTITY % flow \"(%text|%block)*\">\n"+
"\n"+
"<!ENTITY % pre.content \"#PCDATA | A | HR | BR | IMG\">\n"+
"<!ELEMENT PRE - - (%pre.content)+>\n"+
"\n"+
"<!ATTLIST PRE\n"+
"        WIDTH NUMBER #implied\n"+
"        >\n"+
"\n"+
"<![ %HTML.Deprecated [\n"+
"\n"+
"<!ENTITY % literal \"CDATA\"\n"+
"	-- special non-conforming parsing mode where\n"+
"	   the only markup signal is the end tag\n"+
"	   in full\n"+
"	-->\n"+
"\n"+
"<!ELEMENT XMP - -  %literal>\n"+
"<!ELEMENT LISTING - -  %literal>\n"+
"<!ELEMENT PLAINTEXT - O %literal>\n"+
"\n"+
"]]>\n"+
"\n"+
"\n"+
"<!--=================== Lists =============================================-->\n"+
"\n"+
"<!ELEMENT DL    - -  (DT*, DD?)+>\n"+
"<!ATTLIST DL\n"+
"	COMPACT (COMPACT) #IMPLIED>\n"+
"\n"+
"<!ELEMENT DT    - O (%text)+>\n"+
"<!ELEMENT DD    - O %flow>\n"+
"\n"+
"<!ELEMENT (OL|UL) - -  (LI)+>\n"+
"<!ELEMENT (DIR|MENU) - -  (LI)+ -(%block)>\n"+
"<!ATTLIST (UL)\n"+
"	COMPACT (COMPACT) #IMPLIED\n"+
"	TYPE CDATA #IMPLIED\n"+
"        START NUMBER #IMPLIED\n"+
"	>\n"+
"<!ATTLIST (OL)\n"+
"	COMPACT (COMPACT) #IMPLIED\n"+
"	TYPE CDATA \"1\"\n"+
"	>\n"+
"\n"+
"<!ELEMENT LI    - O %flow>\n"+
"<!ATTLIST LI\n"+
"	TYPE CDATA #IMPLIED\n"+
"	VALUE CDATA #implied\n"+
"        START NUMBER #IMPLIED\n"+
">\n"+
"\n"+
"<!--=================== Document Body =====================================-->\n"+
"\n"+
"<![ %HTML.Recommended [\n"+
"	<!ENTITY % body.content \"(%heading|%block|HR|ADDRESS)*\"\n"+
"	-- <h1>Heading</h1>\n"+
"	   <p>Text ...\n"+
"		is preferred to\n"+
"	   <h1>Heading</h1>\n"+
"	   Text ...\n"+
"	-->\n"+
"]]>\n"+
"\n"+
"<!ENTITY % body.content \"(%heading | %text | %block | HR | ADDRESS)*\">\n"+
"\n"+
"<!ELEMENT BODY O O  %body.content>\n"+
"\n"+
"<!ELEMENT BLOCKQUOTE - - %body.content>\n"+
"\n"+
"<![ %HTML.Recommended [\n"+
"	<!ENTITY % address.content \"(%text)*\">\n"+
"]]>\n"+
"<!ENTITY % address.content \"(%text|P)*\">\n"+
"<!ELEMENT ADDRESS - - %address.content>\n"+
"\n"+
"\n"+
"<!--================ Forms ===============================================-->\n"+
"\n"+
"<![ %HTML.Forms [\n"+
"\n"+
"<!ELEMENT FORM - - %body.content -(FORM) +(INPUT|SELECT|TEXTAREA)>\n"+
"<!ATTLIST FORM\n"+
"	ACTION %URI #REQUIRED\n"+
"	METHOD (%HTTP-Method) GET\n"+
"	ENCTYPE %Content-Type; \"application/x-www-form-urlencoded\"\n"+
"	>\n"+
"\n"+
"<!ENTITY % InputType \"(TEXT | PASSWORD | CHECKBOX |\n"+
"			RADIO | SUBMIT | RESET |\n"+
"			IMAGE | HIDDEN )\">\n"+
"<!ELEMENT INPUT - O EMPTY>\n"+
"<!ATTLIST INPUT\n"+
"	TYPE %InputType TEXT\n"+
"	NAME CDATA #IMPLIED -- required for all but submit and reset --\n"+
"	VALUE CDATA #IMPLIED\n"+
"	SRC %URI #IMPLIED -- for image inputs -- \n"+
"	CHECKED (CHECKED) #IMPLIED\n"+
"	SIZE CDATA #IMPLIED -- like NUMBERS,\n"+
"				 but delimited with comma, not space --\n"+
"	MAXLENGTH NUMBER #IMPLIED\n"+
"	ALIGN (top|middle|bottom) #IMPLIED\n"+
"	>\n"+
"\n"+
"<!ELEMENT SELECT - - (OPTION+)>\n"+
"<!ATTLIST SELECT\n"+
"	NAME CDATA #REQUIRED\n"+
"	SIZE NUMBER #IMPLIED\n"+
"	MULTIPLE (MULTIPLE) #IMPLIED\n"+
"	>\n"+
"\n"+
"<!ELEMENT OPTION - O (#PCDATA)>\n"+
"<!ATTLIST OPTION\n"+
"	SELECTED (SELECTED) #IMPLIED\n"+
"	VALUE CDATA #IMPLIED\n"+
"	>\n"+
"\n"+
"<!ELEMENT TEXTAREA - - (#PCDATA)>\n"+
"<!ATTLIST TEXTAREA\n"+
"	NAME CDATA #REQUIRED\n"+
"	ROWS NUMBER #REQUIRED\n"+
"	COLS NUMBER #REQUIRED\n"+
"	>\n"+
"\n"+
"]]>\n"+
"\n"+
"\n"+
"<!--================ Document Head ========================================-->\n"+
"\n"+
"<!ENTITY % head.link \"& LINK*\">\n"+
"\n"+
"<![ %HTML.Recommended [\n"+
"	<!ENTITY % head.nextid \"\">\n"+
"]]>\n"+
"<!ENTITY % head.nextid \"& NEXTID?\">\n"+
"\n"+
"<!ENTITY % head.content \"TITLE & ISINDEX? & BASE? & META*\n"+
"			 %head.nextid\n"+
"			 %head.link\">\n"+
"\n"+
"<!ELEMENT HEAD O O  (%head.content)>\n"+
"\n"+
"<!ELEMENT LINK - O EMPTY>\n"+
"<!ATTLIST LINK\n"+
"	HREF %URI #REQUIRED\n"+
"        %linkExtraAttributes; >\n"+
"\n"+
"<!ELEMENT ISINDEX - O EMPTY>\n"+
"<!ATTLIST ISINDEX\n"+
"	PROMPT CDATA \"This is a searchable index. Enter search keywords:\">\n"+
"\n"+
"<!ELEMENT BASE - O EMPTY>\n"+
"<!ATTLIST BASE\n"+
"        HREF %URI; #REQUIRED\n"+
"        >\n"+
"\n"+
"<!ELEMENT NEXTID - O EMPTY>\n"+
"<!ATTLIST NEXTID N %linkName #REQUIRED>\n"+
"\n"+
"<!ELEMENT META - O EMPTY    -- Generic Metainformation -->\n"+
"<!ATTLIST META\n"+
"        HTTP-EQUIV  NAME    #IMPLIED  -- HTTP response header name  --\n"+
"        NAME        NAME    #IMPLIED  -- metainformation name       --\n"+
"        CONTENT     CDATA   #REQUIRED -- associated information     --\n"+
"        >\n"+
"\n"+
"\n"+
"<!--================ Document Structure ===================================-->\n"+
"\n"+
"<![ %HTML.Deprecated [\n"+
"	<!ENTITY % html.content \"HEAD, BODY, PLAINTEXT?\">\n"+
"]]>\n"+
"<!ENTITY % html.content \"HEAD, BODY\">\n"+
"\n"+
"<!ELEMENT HTML O O  (%html.content)>\n"+
"<!ENTITY % version.attr \"VERSION CDATA #FIXED &#34;%HTML.Version;&#34;\">\n"+
"\n"+
"<!ATTLIST HTML\n"+
"	%version.attr;-- report DTD version to application --\n"+
"	>\n"+
"\n"+
"\n"+
"<!-- Applets -->\n"+
"\n"+
"<!ELEMENT APPLET - - (PARAM*, (%text;)*)>\n"+
"<!ATTLIST APPLET\n"+
"	BASE CDATA #IMPLIED	-- code base --\n"+
"	SRC CDATA #IMPLIED	-- code name (class name) --\n"+
"	NAME CDATA #IMPLIED	-- the applet name --\n"+
"	WIDTH NUMBER #REQUIRED\n"+
"	HEIGHT NUMBER #REQUIRED\n"+
"	ALIGN (left|right|top|texttop|middle|\n"+
"		absmiddle|baseline|bottom|absbottom) baseline\n"+
"	VSPACE NUMBER #IMPLIED\n"+
"	HSPACE NUMBER #IMPLIED\n"+
">\n"+
"\n"+
"<!ELEMENT PARAM - O EMPTY>\n"+
"<!ATTLIST PARAM\n"+
"	NAME NAME #REQUIRED	-- The name of the parameter --\n"+
"	VALUE CDATA #IMPLIED	-- The value of the parameter --\n"+
">\n"+
"\n"+
"<!ELEMENT APP - O EMPTY>\n"+
"<!ATTLIST APP\n"+
"	CLASS CDATA #IMPLIED\n"+
"	SRC CDATA #IMPLIED\n"+
"	WIDTH NUMBER #REQUIRED\n"+
"	HEIGHT NUMBER #REQUIRED\n"+
">\n";

}
