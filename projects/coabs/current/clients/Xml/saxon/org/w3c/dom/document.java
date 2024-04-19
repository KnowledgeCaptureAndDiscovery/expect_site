package org.w3c.dom;

/**
The Document object represents the entire HTML or XML document.
Conceptually, it is the root of the document tree, and provides
the primary access to the document's data. Since Document 
inherits from DocumentFragment, its children are contents of the 
Document, e.g., the root Element, the XML prolog, any processing 
instructions and or comments, etc.<p>
Since Elements, Text nodes, Comments, PIs, etc. cannot exist 
outside a Document, the Document interface also anchors the 
"factory" methods that create these objects. 
*/

public interface Document extends DocumentFragment
{
   public Node              getDocumentType();
   public void              setDocumentType(Node arg);

   public Element           getDocumentElement();
   public void              setDocumentElement(Element arg);

   public DocumentContext   getContextInfo();
   public void              setContextInfo(DocumentContext arg);

   public DocumentContext   createDocumentContext();
   public Element           createElement(String tagName, 
                                          AttributeList attributes);
   public Text              createTextNode(String data);
   public Comment           createComment(String data);
   public PI                createPI(String name, 
                                     String data);
   public Attribute         createAttribute(String name, 
                                            String value);
   public AttributeList     createAttributeList();
   public TreeIterator      createTreeIterator(Node node);
   public NodeIterator      getElementsByTagName(String tagname);
}

