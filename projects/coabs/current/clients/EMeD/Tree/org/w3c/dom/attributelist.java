package org.w3c.dom;


public interface AttributeList
{
		public Attribute         
	getAttribute(String attrName);
	
		public Attribute         
	setAttribute(Attribute attr);
	
		public Attribute         
	remove(String attrName)
		throws NoSuchAttributeException;
	
		public Attribute         
	item(int index)
		throws NoSuchAttributeException;

		public int               
	getLength();
}

