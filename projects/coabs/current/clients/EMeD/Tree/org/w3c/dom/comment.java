package org.w3c.dom;

/**
Represents the content of a comment, i.e. all the characters between the starting
'<!--' and *ending '-->'. Note that this is the definition of a comment in XML,
and, in practice, HTML, although some HTML tools may implement the full SGML
comment structure.
*/

public interface Comment extends Node
{
		public String
	getData();
	
		public void
	setData(String arg);
}

