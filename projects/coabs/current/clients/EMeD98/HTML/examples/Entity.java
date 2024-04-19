/*
 * @(#)Entity.java	1.2 95/05/03  
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

import java.util.Hashtable;
import java.io.File;
import java.io.InputStream;
import java.io.FileInputStream;
import java.io.StringBufferInputStream;
//import java.io.InputStreamBuffer;             //??dk
import java.io.BufferedInputStream;
//import net.www.html.URL;
import java.io.ByteArrayInputStream;            //??dk
import java.net.URL;                            //??dk
import java.io.FileNotFoundException;           //??dk

/**
 * An entity in a DTD.
 *
 * @version 	1.2, 03 May 1995
 * @author Arthur van Hoff
 * @modified Dmitri Kondratiev for JDK Beta 2 05/01/96 //??dk
 */
public
class Entity implements DTDConstants {
    String name;
    int type;
    byte data[];

    /**
     * Create an entity.
     */
    Entity(String name, int type, byte data[]) {
	this.name = name;
	this.type = type;
	this.data = data;
    }

    /**
     * Get the name of the entity.
     */
    public String getName() {
	return name;
    }

    /**
     * Get the type of the entity.
     */
    public int getType() {
	return type & 0xFFFF;
    }

    /**
     * Return true if it is a parameter entity.
     */
    public boolean isParameter() {
	return (type & PARAMETER) != 0;
    }

    /**
     * Return true if it is a parameter entity.
     */
    public boolean isGeneral() {
	return (type & GENERAL) != 0;
    }

    /**
     * Return the data.
     */
    public byte getData()[] {
	return data;
    }

    /**
     * Return the data as a string.
     */
    public String getString() {
	return new String(data, 0, 0, data.length);
    }

    /**
     * Return the data as a stream.
     */
    public InputStream getInputStream() throws FileNotFoundException {    //??dk
	if ((type & PUBLIC) != 0) {
	    return DTD.mapping.get(getString());
	}
	if ((type & SYSTEM) != 0) {
          return new StringBufferInputStream (ENTDATA);

//	    return new BufferedInputStream(new FileInputStream(DTD.mapping.dir + File.separator + getString()));
	}
//	return new InputStreamBuffer(data);                                   //??dk
    return new ByteArrayInputStream(data);                                 //??dk
    }

    /**
     * Print (for debugging only).
     */
    public void print() {
	if (isParameter()) {
	    return;
	}
	System.out.print("<!ENTITY ");
	System.out.print(name);
	switch (getType()) {
	  case PUBLIC:  System.out.print(" PUBLIC"); break;
	  case CDATA:   System.out.print(" CDATA"); break;
	  case SDATA:   System.out.print(" SDATA"); break;
	  case PI:	System.out.print(" PI"); break;
	  case STARTTAG:System.out.print(" STARTTAG"); break;
	  case ENDTAG:  System.out.print(" ENDTAG"); break;
	  case MS:	System.out.print(" MS"); break;
	  case MD:	System.out.print(" MD"); break;
	}
//	System.out.print(" \"" + getString() + "\"");
//	System.out.println(">");
    }

    static Hashtable entityTypes = new Hashtable();

    static {
	entityTypes.put("PUBLIC", new Integer(PUBLIC));
	entityTypes.put("CDATA", new Integer(CDATA));
	entityTypes.put("SDATA", new Integer(SDATA));
	entityTypes.put("PI", new Integer(PI));
	entityTypes.put("STARTTAG", new Integer(STARTTAG));
	entityTypes.put("ENDTAG", new Integer(ENDTAG));
	entityTypes.put("MS", new Integer(MS));
	entityTypes.put("MD", new Integer(MD));
	entityTypes.put("SYSTEM", new Integer(SYSTEM));
    }
    
    static int name2type(String nm) {
	Integer i = (Integer)entityTypes.get(nm);
	return (i == null) ? CDATA : i.intValue();
    }

  final static String ENTDATA =

"<!-- (C) International Organization for Standardization 1986\n"+
"     Permission to copy in any form is granted for use with\n"+
"     conforming SGML systems and applications as defined in\n"+
"     ISO 8879, provided this notice is included in all copies.\n"+
"-->\n"+
"<!-- Character entity set. Typical invocation:\n"+
"     <!ENTITY % ISOlat1 PUBLIC\n"+
"       \"ISO 8879:1986//ENTITIES Added Latin 1//EN\">\n"+
"     %ISOlat1;\n"+
"-->\n"+
"\n"+
"\n"+
"<!--	Modified for use in HTML\n"+
"	$Id: ISOlat1.sgml,v 1.4 1994/05/17 21:07:42 connolly Exp \"$\" -->\n"+
"<!ENTITY AElig  SDATA \"Æ\" -- capital AE diphthong (ligature) -->\n"+
"<!ENTITY Aacute SDATA \"Á\" -- capital A, acute accent -->\n"+
"<!ENTITY Acirc  SDATA \"Â\" -- capital A, circumflex accent -->\n"+
"<!ENTITY Agrave SDATA \"À\" -- capital A, grave accent -->\n"+
"<!ENTITY Aring  SDATA \"Å\" -- capital A, ring -->\n"+
"<!ENTITY Atilde SDATA \"Ã\" -- capital A, tilde -->\n"+
"<!ENTITY Auml   SDATA \"Ä\" -- capital A, dieresis or umlaut mark -->\n"+
"<!ENTITY Ccedil SDATA \"Ç\" -- capital C, cedilla -->\n"+
"<!ENTITY ETH    SDATA \"Ð\" -- capital Eth, Icelandic -->\n"+
"<!ENTITY Eacute SDATA \"É\" -- capital E, acute accent -->\n"+
"<!ENTITY Ecirc  SDATA \"Ê\" -- capital E, circumflex accent -->\n"+
"<!ENTITY Egrave SDATA \"È\" -- capital E, grave accent -->\n"+
"<!ENTITY Euml   SDATA \"Ë\" -- capital E, dieresis or umlaut mark -->\n"+
"<!ENTITY Iacute SDATA \"Í\" -- capital I, acute accent -->\n"+
"<!ENTITY Icirc  SDATA \"Î\" -- capital I, circumflex accent -->\n"+
"<!ENTITY Igrave SDATA \"Ì\" -- capital I, grave accent -->\n"+
"<!ENTITY Iuml   SDATA \"Ï\" -- capital I, dieresis or umlaut mark -->\n"+
"<!ENTITY Ntilde SDATA \"Ñ\" -- capital N, tilde -->\n"+
"<!ENTITY Oacute SDATA \"Ó\" -- capital O, acute accent -->\n"+
"<!ENTITY Ocirc  SDATA \"Ô\" -- capital O, circumflex accent -->\n"+
"<!ENTITY Ograve SDATA \"Ò\" -- capital O, grave accent -->\n"+
"<!ENTITY Oslash SDATA \"Ø\" -- capital O, slash -->\n"+
"<!ENTITY Otilde SDATA \"Õ\" -- capital O, tilde -->\n"+
"<!ENTITY Ouml   SDATA \"Ö\" -- capital O, dieresis or umlaut mark -->\n"+
"<!ENTITY THORN  SDATA \"Þ\" -- capital THORN, Icelandic -->\n"+
"<!ENTITY Uacute SDATA \"Ú\" -- capital U, acute accent -->\n"+
"<!ENTITY Ucirc  SDATA \"Û\" -- capital U, circumflex accent -->\n"+
"<!ENTITY Ugrave SDATA \"Ù\" -- capital U, grave accent -->\n"+
"<!ENTITY Uuml   SDATA \"Ü\" -- capital U, dieresis or umlaut mark -->\n"+
"<!ENTITY Yacute SDATA \"Ý\" -- capital Y, acute accent -->\n"+
"<!ENTITY aacute SDATA \"á\" -- small a, acute accent -->\n"+
"<!ENTITY acirc  SDATA \"â\" -- small a, circumflex accent -->\n"+
"<!ENTITY aelig  SDATA \"æ\" -- small ae diphthong (ligature) -->\n"+
"<!ENTITY agrave SDATA \"à\" -- small a, grave accent -->\n"+
"<!ENTITY aring  SDATA \"å\" -- small a, ring -->\n"+
"<!ENTITY atilde SDATA \"ã\" -- small a, tilde -->\n"+
"<!ENTITY auml   SDATA \"ä\" -- small a, dieresis or umlaut mark -->\n"+
"<!ENTITY ccedil SDATA \"ç\" -- small c, cedilla -->\n"+
"<!ENTITY eacute SDATA \"é\" -- small e, acute accent -->\n"+
"<!ENTITY ecirc  SDATA \"ê\" -- small e, circumflex accent -->\n"+
"<!ENTITY egrave SDATA \"è\" -- small e, grave accent -->\n"+
"<!ENTITY eth    SDATA \"ð\" -- small eth, Icelandic -->\n"+
"<!ENTITY euml   SDATA \"ë\" -- small e, dieresis or umlaut mark -->\n"+
"<!ENTITY iacute SDATA \"í\" -- small i, acute accent -->\n"+
"<!ENTITY icirc  SDATA \"î\" -- small i, circumflex accent -->\n"+
"<!ENTITY igrave SDATA \"ì\" -- small i, grave accent -->\n"+
"<!ENTITY iuml   SDATA \"ï\" -- small i, dieresis or umlaut mark -->\n"+
"<!ENTITY ntilde SDATA \"ñ\" -- small n, tilde -->\n"+
"<!ENTITY oacute SDATA \"ó\" -- small o, acute accent -->\n"+
"<!ENTITY ocirc  SDATA \"ô\" -- small o, circumflex accent -->\n"+
"<!ENTITY ograve SDATA \"ò\" -- small o, grave accent -->\n"+
"<!ENTITY oslash SDATA \"ø\" -- small o, slash -->\n"+
"<!ENTITY otilde SDATA \"õ\" -- small o, tilde -->\n"+
"<!ENTITY ouml   SDATA \"ö\" -- small o, dieresis or umlaut mark -->\n"+
"<!ENTITY szlig  SDATA \"ß\" -- small sharp s, German (sz ligature) -->\n"+
"<!ENTITY thorn  SDATA \"þ\" -- small thorn, Icelandic -->\n"+
"<!ENTITY uacute SDATA \"ú\" -- small u, acute accent -->\n"+
"<!ENTITY ucirc  SDATA \"û\" -- small u, circumflex accent -->\n"+
"<!ENTITY ugrave SDATA \"ù\" -- small u, grave accent -->\n"+
"<!ENTITY uuml   SDATA \"ü\" -- small u, dieresis or umlaut mark -->\n"+
"<!ENTITY yacute SDATA \"ý\" -- small y, acute accent -->\n"+
"<!ENTITY yuml   SDATA \"ÿ\" -- small y, dieresis or umlaut mark -->\n"+
"\n"+
"<!--* the following were omitted in the HTML definition but are found\n"+
"    * in ISO Latin 1 and in ISO 8859-1, the stated character set of HTML.\n"+
"    * They were added by SoftQuad Inc.\n"+
"    *-->\n"+
"<!ENTITY iexcl SDATA \"¡\" --= inverted exclamation mark -->\n"+
"<!ENTITY cent SDATA \"¢\" --= cent sign -->\n"+
"<!ENTITY pound SDATA \"£\" --= pound sign -->\n"+
"<!ENTITY curren SDATA \"¤\" --= general currency sign -->\n"+
"<!ENTITY yen SDATA \"¥\" --= /yen =yen sign -->\n"+
"<!ENTITY brvbar SDATA \"¦\" --= broken (vertical) bar -->\n"+
"<!ENTITY sect SDATA \"§\" --= section sign -->\n"+
"<!ENTITY die    SDATA \"¨\"--=dieresis-->\n"+
"<!ENTITY uml    SDATA \"¨\"--=umlaut mark-->\n"+
"<!ENTITY copy SDATA \"©\" --= copyright sign -->\n"+
"<!ENTITY ordf SDATA \"ª\" --= ordinal indicator, feminine -->\n"+
"<!ENTITY laquo SDATA \"«\" --= angle quotation mark, left -->\n"+
"<!ENTITY reg SDATA \"®\" --= /circledR =registered sign -->\n"+
"<!ENTITY macr   SDATA \"¯\"--=macron-->\n"+
"<!ENTITY deg SDATA \"°\" --= degree sign -->\n"+
"<!ENTITY ring   SDATA \"°\"--=ring-->\n"+
"<!ENTITY plusmn SDATA \"±\" --= /pm B: =plus-or-minus sign -->\n"+
"<!ENTITY sup2 SDATA \"²\" --= superscript two -->\n"+
"<!ENTITY sup3 SDATA \"³\" --= superscript three -->\n"+
"<!ENTITY dblac  SDATA \"´´\"--=double acute accent-->\n"+
"<!ENTITY acute  SDATA \"´\"--=acute accent-->\n"+
"<!ENTITY micro SDATA \"µ\" --= micro sign -->\n"+
"<!ENTITY para SDATA \"¶\" --= pilcrow (paragraph sign) -->\n"+
"<!ENTITY middot SDATA \"·\" --= /centerdot B: =middle dot -->\n"+
"<!ENTITY cedil  SDATA \"¸\"--=cedilla-->\n"+
"<!ENTITY sup1 SDATA \"¹\" --= superscript one -->\n"+
"<!ENTITY ordm SDATA \"º\" --= ordinal indicator, masculine -->\n"+
"<!ENTITY raquo SDATA \"»\" --= angle quotation mark, right -->\n"+
"<!ENTITY frac14 SDATA \"¼\" --= fraction one-quarter -->\n"+
"<!ENTITY frac12 SDATA \"½\" --= fraction one-half -->\n"+
"<!ENTITY half SDATA \"½\" --= fraction one-half -->\n"+
"<!ENTITY frac34 SDATA \"¾\" --= fraction three-quarters -->\n"+
"<!ENTITY iquest SDATA \"¿\" --= inverted question mark -->\n";

}
