package org.w3c.dom;


public interface ElementDefinition extends Node {
   // ContentType
   public static final int            EMPTY                = 1;
   public static final int            ANY                  = 2;
   public static final int            PCDATA               = 3;
   public static final int            MODEL_GROUP          = 4;

   public String            getName();
   public void              setName(String arg);

   public int               getContentType();
   public void              setContentType(int arg);

   public ModelGroup        getContentModel();
   public void              setContentModel(ModelGroup arg);

   public Node              getAttributeDefinitions();
   public void              setAttributeDefinitions(Node arg);

   public Node              getInclusions();
   public void              setInclusions(Node arg);

   public Node              getExceptions();
   public void              setExceptions(Node arg);

}

