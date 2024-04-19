package com.icl.saxon;
import java.util.*;
import java.text.*;

// Copyright © International Computers Limited 1998
// See conditions of use

/*
 * class BinaryTree()
 * supports the java.util.Dictionary interface except that the
 * keys must be Strings rather than general Objects.
 * 
 * The methods keys() and elements() return values in ascending order
 * of key.
 *
 * Author Michael H. Kay, ICL (M.H.Kay@eng.icl.co.uk)
 * 23 January 1998
 *
 */

class BinaryTree {

    private BinaryTreeNode root;       // the root node of the tree; null if tree is empty
    private Collator collator;         // collator used for comparing key values
    private boolean changed;           // true if tree has changed since chain was last made
    private BinaryTreeNode prev;       // temporary variable used while making new chain
    private BinaryTreeNode header;     // dummy node to point to first "real" entry in chain

    // The implementation of the binary tree uses a classic structure with
    // nodes containing a left pointer, a right pointer, and a key/value pair.
    // In addition there is scope for a one-way chain to link the nodes in
    // ascending key order. This is maintained in a "lazy" way: it is built
    // only when needed, and only if the tree has changed since it was last
    // built.
    // Removal of entries is handled by setting the value to null: the node
    // itself remains in the tree.

/*
 * Constructor: creates and empty tree
 */
    
    public BinaryTree ()
    {
        root = null;
        collator = Collator.getInstance();
        changed = false;
        header = new BinaryTreeNode(null, null, null); // dummy node
        header.next = null;        
    }
/* 
 * elements()
 * returns an enumeration of the values in this BinaryTree (in key order).
 */
 
    public Enumeration elements()
    {
        if (changed) makeChain();
        return new BinaryTreeValueEnumeration(header.next);
    }
 
 /*
  * get(String) 
  * Returns the value to which the key is mapped in this binary tree. 
  */

    public Object get(String o)
    {
        BinaryTreeNode n = find(o);
        return (n==null ? null : n.value);
    };

  /*
   * isEmpty() 
   * Tests if this binary tree maps no keys to a value.
   */

   public boolean isEmpty()
   {
       return (size()==0);
   }
 
  /* 
   * keys() 
   * Returns an enumeration of the keys in this binary tree (in order).
   */

    public Enumeration keys()
    {
        if (changed) makeChain();
        return new BinaryTreeKeyEnumeration(header.next);
    }

  /* 
   * put(String, Object) 
   * Maps the specified key to the specified value in this dictionary. 
   */

   public Object put(String key, Object value)
   {
        if (key==null || value==null) throw new NullPointerException();

        BinaryTreeNode node = root;
        CollationKey c = collator.getCollationKey(key);

        changed = true;

        if (root==null) {
            root = new BinaryTreeNode(c, key, value);
            return null;
        }
        while (true) {
            int w = node.ckey.compareTo(c);
            if ( w > 0 ) {
                if (node.left==null) {
                    node.left = new BinaryTreeNode(c, key, value);
                    return null;
                }                
                node = node.left;               
            }
            if ( w == 0 ) {
                Object old = node.value; 
                node.value = value;
                return old;
            }
            if ( w < 0 ) {
                if (node.right==null) {
                   node.right = new BinaryTreeNode(c, key, value);
                   return null;
                }
                node = node.right;
            }
        }
    }
        

   /*
    * remove(Object) 
    * Removes the key (and its corresponding value) from this Binary Tree. 
    */
    public Object remove(String key)
    {
         // implemented by setting a logical delete marker in the node
         BinaryTreeNode n = find(key);
 
         if (n==null) return null;
         Object val = n.value;
         n.delete();
         changed = true;
         return(val);
    }


    /*
     * size() 
     * Returns the number of keys in this binary tree. 
     */
    public int size()
    {
        return count(root);
    }

    /*
     * private method to count the nodes subordinate to a given node
     */

    private int count ( BinaryTreeNode here )
    {
        if (here==null) return 0;
        return count(here.left) + (here.isDeleted() ? 0 : 1) + count(here.right);
    }

    /*
     * private method to find a node given a key value
     */

    private BinaryTreeNode find(String s)
    {
        BinaryTreeNode n = root;
        CollationKey c = collator.getCollationKey(s);
        if (n==null || n.ckey==null) return null;
        while (n!=null) {
            int w = n.ckey.compareTo(c);
            if ( w > 0 ) n = n.left;
            if ( w == 0 ) return (n.isDeleted() ? null : n);
            if ( w < 0 ) n = n.right;
        }
        return null;
     }

    /*
     * walk()
     * walk through the nodes in key order connecting each one to
     * its predecessor
     */

    private void walk ( BinaryTreeNode here )
    {
        if (here!=null) {
           walk(here.left);
           if (!here.isDeleted()) {
               prev.next = here;
               prev = here;
           }
           walk(here.right);
        } 
    }
    
    /*
     * makeChain()
     * makes a chain linking the nodes in ascending order of key
     */
 
    private void makeChain ()
    {
        prev = header;
        walk(root);
        prev.next = null; 
        changed = false;
    }
    
    /*
     * A simple test program
     */

    public static void main (String args[])
    {
        BinaryTree b = new BinaryTree();
        if (!b.isEmpty()) System.out.println("test 1a failed");
        if (b.size()!=0) System.out.println("test 1b failed");
        b.put("FRED", "FRED123");
        String val = (String)b.get("FRED");
        if (!val.equals("FRED123")) System.out.println("test 2a failed");
        if (b.isEmpty()) System.out.println("test 2b failed");
        if (b.size()!=1) System.out.println("test 2c failed");

        b.put("BILL", "BILL123");
        b.put("MARY", "MARY123");
        b.put("JOHN", "JOHN123");
        b.put("MARY", "MARY456");
        Enumeration en = b.keys();
        while(en.hasMoreElements()) System.out.println((String)en.nextElement());
        en = b.elements();
        while(en.hasMoreElements()) System.out.println((String)en.nextElement());
        System.out.println("SIZE = " + b.size());
        b.remove("JOHN");
        en = b.keys();
        while(en.hasMoreElements()) System.out.println((String)en.nextElement());
        System.out.println("SIZE = " + b.size()); 
        System.out.println("Test Complete");
    }    

}   

class BinaryTreeNode {
    BinaryTreeNode left;
    BinaryTreeNode right;
    BinaryTreeNode next;
    CollationKey ckey;
    String key;
    Object value;

    public BinaryTreeNode ( CollationKey c, String k, Object v ) {
        left = null;
        right = null;
        next = null;
        ckey = c;
        key = k;
        value = v;
    }
    
    public boolean isDeleted() {
        return (value==null);
    }
    public void delete() {
        value = null;
    }        
        
}

class BinaryTreeNodeEnumeration implements Enumeration {
    private BinaryTreeNode next;

    public BinaryTreeNodeEnumeration () {
        // I don't know why we need this constructor
        // but it won't compile without it
        next = null;
    }
    public BinaryTreeNodeEnumeration (BinaryTreeNode first) {
        next = first;
    }
    public boolean hasMoreElements() {
        return (next != null);
    }
    public Object nextElement() {
        if (next==null) throw new NoSuchElementException();
        BinaryTreeNode current = next;
        next = current.next;
        return current;
    }
}

class BinaryTreeKeyEnumeration extends BinaryTreeNodeEnumeration
{

    public BinaryTreeKeyEnumeration (BinaryTreeNode first) {
        super(first);
    }
    public Object nextElement() {
        return ((BinaryTreeNode)super.nextElement()).key;
    }
} 

class BinaryTreeValueEnumeration extends BinaryTreeNodeEnumeration
{

    public BinaryTreeValueEnumeration (BinaryTreeNode first) {
        super(first);
    }
    public Object nextElement() {
        return ((BinaryTreeNode)super.nextElement()).value;
    }
} 
