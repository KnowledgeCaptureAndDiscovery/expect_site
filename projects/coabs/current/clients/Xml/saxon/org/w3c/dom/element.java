package org.w3c.dom;


public interface Element extends Node {
   public String            getTagName();
   public NodeIterator      getAttributes();
   public String            getAttribute(String name);
   public void              setAttribute(String name, 
                                         String value);
   public void              removeAttribute(String name);
   public Attribute         getAttributeNode(String name);
   public void              setAttributeNode(Attribute newAttr);
   public void              removeAttributeNode(Attribute oldAttr);
   public NodeIterator		getElementsByTagName(String tagname);
   public void              normalize();
}

