package org.w3c.dom;

public interface Attribute extends Node
{
		public String
	getName();
	
		public String
	getValue();
	
		public boolean
	getSpecified();
	
		public void              
	setSpecified(boolean arg);

		public String            
	toString();
}

