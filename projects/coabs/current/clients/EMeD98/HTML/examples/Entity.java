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
"<!ENTITY AElig  SDATA \"�\" -- capital AE diphthong (ligature) -->\n"+
"<!ENTITY Aacute SDATA \"�\" -- capital A, acute accent -->\n"+
"<!ENTITY Acirc  SDATA \"�\" -- capital A, circumflex accent -->\n"+
"<!ENTITY Agrave SDATA \"�\" -- capital A, grave accent -->\n"+
"<!ENTITY Aring  SDATA \"�\" -- capital A, ring -->\n"+
"<!ENTITY Atilde SDATA \"�\" -- capital A, tilde -->\n"+
"<!ENTITY Auml   SDATA \"�\" -- capital A, dieresis or umlaut mark -->\n"+
"<!ENTITY Ccedil SDATA \"�\" -- capital C, cedilla -->\n"+
"<!ENTITY ETH    SDATA \"�\" -- capital Eth, Icelandic -->\n"+
"<!ENTITY Eacute SDATA \"�\" -- capital E, acute accent -->\n"+
"<!ENTITY Ecirc  SDATA \"�\" -- capital E, circumflex accent -->\n"+
"<!ENTITY Egrave SDATA \"�\" -- capital E, grave accent -->\n"+
"<!ENTITY Euml   SDATA \"�\" -- capital E, dieresis or umlaut mark -->\n"+
"<!ENTITY Iacute SDATA \"�\" -- capital I, acute accent -->\n"+
"<!ENTITY Icirc  SDATA \"�\" -- capital I, circumflex accent -->\n"+
"<!ENTITY Igrave SDATA \"�\" -- capital I, grave accent -->\n"+
"<!ENTITY Iuml   SDATA \"�\" -- capital I, dieresis or umlaut mark -->\n"+
"<!ENTITY Ntilde SDATA \"�\" -- capital N, tilde -->\n"+
"<!ENTITY Oacute SDATA \"�\" -- capital O, acute accent -->\n"+
"<!ENTITY Ocirc  SDATA \"�\" -- capital O, circumflex accent -->\n"+
"<!ENTITY Ograve SDATA \"�\" -- capital O, grave accent -->\n"+
"<!ENTITY Oslash SDATA \"�\" -- capital O, slash -->\n"+
"<!ENTITY Otilde SDATA \"�\" -- capital O, tilde -->\n"+
"<!ENTITY Ouml   SDATA \"�\" -- capital O, dieresis or umlaut mark -->\n"+
"<!ENTITY THORN  SDATA \"�\" -- capital THORN, Icelandic -->\n"+
"<!ENTITY Uacute SDATA \"�\" -- capital U, acute accent -->\n"+
"<!ENTITY Ucirc  SDATA \"�\" -- capital U, circumflex accent -->\n"+
"<!ENTITY Ugrave SDATA \"�\" -- capital U, grave accent -->\n"+
"<!ENTITY Uuml   SDATA \"�\" -- capital U, dieresis or umlaut mark -->\n"+
"<!ENTITY Yacute SDATA \"�\" -- capital Y, acute accent -->\n"+
"<!ENTITY aacute SDATA \"�\" -- small a, acute accent -->\n"+
"<!ENTITY acirc  SDATA \"�\" -- small a, circumflex accent -->\n"+
"<!ENTITY aelig  SDATA \"�\" -- small ae diphthong (ligature) -->\n"+
"<!ENTITY agrave SDATA \"�\" -- small a, grave accent -->\n"+
"<!ENTITY aring  SDATA \"�\" -- small a, ring -->\n"+
"<!ENTITY atilde SDATA \"�\" -- small a, tilde -->\n"+
"<!ENTITY auml   SDATA \"�\" -- small a, dieresis or umlaut mark -->\n"+
"<!ENTITY ccedil SDATA \"�\" -- small c, cedilla -->\n"+
"<!ENTITY eacute SDATA \"�\" -- small e, acute accent -->\n"+
"<!ENTITY ecirc  SDATA \"�\" -- small e, circumflex accent -->\n"+
"<!ENTITY egrave SDATA \"�\" -- small e, grave accent -->\n"+
"<!ENTITY eth    SDATA \"�\" -- small eth, Icelandic -->\n"+
"<!ENTITY euml   SDATA \"�\" -- small e, dieresis or umlaut mark -->\n"+
"<!ENTITY iacute SDATA \"�\" -- small i, acute accent -->\n"+
"<!ENTITY icirc  SDATA \"�\" -- small i, circumflex accent -->\n"+
"<!ENTITY igrave SDATA \"�\" -- small i, grave accent -->\n"+
"<!ENTITY iuml   SDATA \"�\" -- small i, dieresis or umlaut mark -->\n"+
"<!ENTITY ntilde SDATA \"�\" -- small n, tilde -->\n"+
"<!ENTITY oacute SDATA \"�\" -- small o, acute accent -->\n"+
"<!ENTITY ocirc  SDATA \"�\" -- small o, circumflex accent -->\n"+
"<!ENTITY ograve SDATA \"�\" -- small o, grave accent -->\n"+
"<!ENTITY oslash SDATA \"�\" -- small o, slash -->\n"+
"<!ENTITY otilde SDATA \"�\" -- small o, tilde -->\n"+
"<!ENTITY ouml   SDATA \"�\" -- small o, dieresis or umlaut mark -->\n"+
"<!ENTITY szlig  SDATA \"�\" -- small sharp s, German (sz ligature) -->\n"+
"<!ENTITY thorn  SDATA \"�\" -- small thorn, Icelandic -->\n"+
"<!ENTITY uacute SDATA \"�\" -- small u, acute accent -->\n"+
"<!ENTITY ucirc  SDATA \"�\" -- small u, circumflex accent -->\n"+
"<!ENTITY ugrave SDATA \"�\" -- small u, grave accent -->\n"+
"<!ENTITY uuml   SDATA \"�\" -- small u, dieresis or umlaut mark -->\n"+
"<!ENTITY yacute SDATA \"�\" -- small y, acute accent -->\n"+
"<!ENTITY yuml   SDATA \"�\" -- small y, dieresis or umlaut mark -->\n"+
"\n"+
"<!--* the following were omitted in the HTML definition but are found\n"+
"    * in ISO Latin 1 and in ISO 8859-1, the stated character set of HTML.\n"+
"    * They were added by SoftQuad Inc.\n"+
"    *-->\n"+
"<!ENTITY iexcl SDATA \"�\" --= inverted exclamation mark -->\n"+
"<!ENTITY cent SDATA \"�\" --= cent sign -->\n"+
"<!ENTITY pound SDATA \"�\" --= pound sign -->\n"+
"<!ENTITY curren SDATA \"�\" --= general currency sign -->\n"+
"<!ENTITY yen SDATA \"�\" --= /yen =yen sign -->\n"+
"<!ENTITY brvbar SDATA \"�\" --= broken (vertical) bar -->\n"+
"<!ENTITY sect SDATA \"�\" --= section sign -->\n"+
"<!ENTITY die    SDATA \"�\"--=dieresis-->\n"+
"<!ENTITY uml    SDATA \"�\"--=umlaut mark-->\n"+
"<!ENTITY copy SDATA \"�\" --= copyright sign -->\n"+
"<!ENTITY ordf SDATA \"�\" --= ordinal indicator, feminine -->\n"+
"<!ENTITY laquo SDATA \"�\" --= angle quotation mark, left -->\n"+
"<!ENTITY reg SDATA \"�\" --= /circledR =registered sign -->\n"+
"<!ENTITY macr   SDATA \"�\"--=macron-->\n"+
"<!ENTITY deg SDATA \"�\" --= degree sign -->\n"+
"<!ENTITY ring   SDATA \"�\"--=ring-->\n"+
"<!ENTITY plusmn SDATA \"�\" --= /pm B: =plus-or-minus sign -->\n"+
"<!ENTITY sup2 SDATA \"�\" --= superscript two -->\n"+
"<!ENTITY sup3 SDATA \"�\" --= superscript three -->\n"+
"<!ENTITY dblac  SDATA \"��\"--=double acute accent-->\n"+
"<!ENTITY acute  SDATA \"�\"--=acute accent-->\n"+
"<!ENTITY micro SDATA \"�\" --= micro sign -->\n"+
"<!ENTITY para SDATA \"�\" --= pilcrow (paragraph sign) -->\n"+
"<!ENTITY middot SDATA \"�\" --= /centerdot B: =middle dot -->\n"+
"<!ENTITY cedil  SDATA \"�\"--=cedilla-->\n"+
"<!ENTITY sup1 SDATA \"�\" --= superscript one -->\n"+
"<!ENTITY ordm SDATA \"�\" --= ordinal indicator, masculine -->\n"+
"<!ENTITY raquo SDATA \"�\" --= angle quotation mark, right -->\n"+
"<!ENTITY frac14 SDATA \"�\" --= fraction one-quarter -->\n"+
"<!ENTITY frac12 SDATA \"�\" --= fraction one-half -->\n"+
"<!ENTITY half SDATA \"�\" --= fraction one-half -->\n"+
"<!ENTITY frac34 SDATA \"�\" --= fraction three-quarters -->\n"+
"<!ENTITY iquest SDATA \"�\" --= inverted question mark -->\n";

}
