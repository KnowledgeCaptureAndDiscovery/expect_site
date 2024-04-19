package org.w3c.dom;


public interface EntityDeclaration {
   public String            getReplacementString();
   public void              setReplacementString(String arg);

   public DocumentFragment  getReplacementSubtree();
   public void              setReplacementSubtree(DocumentFragment arg);

}

