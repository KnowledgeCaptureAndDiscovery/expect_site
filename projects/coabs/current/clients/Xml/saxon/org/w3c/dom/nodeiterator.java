package org.w3c.dom;


public interface NodeIterator {
   public int               getLength();
   public int               getCurrentPos();
   public boolean           atFirst();
   public boolean           atLast();
   public Node              toNextNode();
   public Node              toPrevNode();
   public Node              toFirstNode();
   public Node              toLastNode();
   public Node              moveTo(int n);
}

