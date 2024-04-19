package org.w3c.dom;


public interface DocumentType {
   public String            getName();
   public void              setName(String arg);

   public Node              getExternalSubset();
   public void              setExternalSubset(Node arg);

   public Node              getInternalSubset();
   public void              setInternalSubset(Node arg);

   public Node              getGeneralEntities();
   public void              setGeneralEntities(Node arg);

   public Node              getParameterEntities();
   public void              setParameterEntities(Node arg);

   public Node              getNotations();
   public void              setNotations(Node arg);

   public Node              getElementTypes();
   public void              setElementTypes(Node arg);

}

