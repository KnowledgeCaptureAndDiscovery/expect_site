package org.w3c.dom;


public interface ElementToken extends Node {
   // OccurrenceType
   public static final int            OPT                  = 1;
   public static final int            PLUS                 = 2;
   public static final int            REP                  = 3;

   public String            getName();
   public void              setName(String arg);

   public int               getOccurrence();
   public void              setOccurrence(int arg);

}

