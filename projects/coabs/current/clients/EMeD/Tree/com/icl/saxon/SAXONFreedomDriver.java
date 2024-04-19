package com.icl.saxon;

import java.io.*;
import java.net.*;
import java.util.*;
import org.w3c.dom.*;
import org.xml.sax.*;
import com.docuverse.freedom.*;

/**
* SAXONFreedomDriver: an implementation of FreedomDriver based on Free-dom's
* SAXDriver. This is used by Free-dom when it calls a parser (via SAX interfaces)
* to parse the source document and build the DOM. We override Free-dom's standard
* Driver for two reasons: firstly, to take advantage of SAXON's ParserManager,
and secondly, to take advantage of SAXON's ExtendedInputSource.
*
*/

public class SAXONFreedomDriver extends com.docuverse.freedom.SAXDriver
{
	private Parser				parser;

	public FreedomDocument read (Object source)
	{
        Parser parser = ParserManager.makeParser();

		FreedomDocument	result = null;
		try
		{
			context = new FreedomDriverContext();

			parser.setDocumentHandler(this);
			parser.parse((InputSource)source);
			
			result = context.getDocument();
		}
		catch (Exception ex)
		{
			setError(ex);
		}
		finally
		{
			context = null;
		}
		return result;
	}

}
