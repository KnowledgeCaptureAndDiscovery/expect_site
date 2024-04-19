package org.w3c.dom;


public interface Notation extends Node {
   public String            getName();
   public void              setName(String arg);

   public boolean           getIsPublic();
   public void              setIsPublic(boolean arg);

   public String            getPublicIdentifier();
   public void              setPublicIdentifier(String arg);

   public String            getSystemIdentifier();
   public void              setSystemIdentifier(String arg);

}

