package org.w3c.dom;


public interface ModelGroup extends Node {
   // OccurrenceType
   public static final int            OPT                  = 1;
   public static final int            PLUS                 = 2;
   public static final int            REP                  = 3;

   // ConnectionType
   public static final int            OR                   = 1;
   public static final int            SEQ                  = 2;
   public static final int            AND                  = 3;

   public int               getOccurrence();
   public void              setOccurrence(int arg);

   public int               getConnector();
   public void              setConnector(int arg);

   public Node              getTokens();
   public void              setTokens(Node arg);

}

