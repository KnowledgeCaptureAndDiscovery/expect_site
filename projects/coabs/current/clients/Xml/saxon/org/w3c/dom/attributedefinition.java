package org.w3c.dom;


public interface AttributeDefinition extends Node {
   // DeclaredValueType
   public static final int            CDATA                = 1;
   public static final int            ID                   = 2;
   public static final int            IDREF                = 3;
   public static final int            IDREFS               = 4;
   public static final int            ENTITY               = 5;
   public static final int            ENTITIES             = 6;
   public static final int            NMTOKEN              = 7;
   public static final int            NMTOKENS             = 8;
   public static final int            NOTATION             = 9;
   public static final int            NAME_TOKEN_GROUP     = 10;

   // DefaultValueType
   public static final int            FIXED                = 1;
   public static final int            REQUIRED             = 2;
   public static final int            IMPLIED              = 3;

   public String            getName();
   public void              setName(String arg);

   public String            getAllowedTokens();
   public void              setAllowedTokens(String arg);

   public int               getDeclaredType();
   public void              setDeclaredType(int arg);

   public int               getDefaultType();
   public void              setDefaultType(int arg);

   public Node              getDefaultValue();
   public void              setDefaultValue(Node arg);

}

