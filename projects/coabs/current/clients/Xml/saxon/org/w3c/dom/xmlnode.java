package org.w3c.dom;


public interface XMLNode {
   public Node              getParentXMLNode(boolean expandEntities);
   public NodeIterator      getChildXMLNodes(boolean expandEntities);
   public boolean           hasChildXMLNodes(boolean expandEntities);
   public Node              getFirstXMLChild(boolean expandEntities);
   public Node              getPreviousXMLSibling(boolean expandEntities);
   public Node              getNextXMLSibling(boolean expandEntities);
   public EntityReference   getEntityReference();
   public EntityDeclaration getEntityDeclaration();
}

