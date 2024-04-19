package Connection;

import java.util.*;

class HtmlForm {
  String method;
  String action;
  Vector contents=new Vector();//of HtmlFormElements

  static Node find(Node n,String s) {
    for(int i=0;i<n.jjtGetNumChildren();i++) {
      Node c=n.jjtGetChild(i);
      if(c.toString().equalsIgnoreCase(s)) {
	return c;
      } else {
	Node x=find(c,s);
	if(x!=null) {return x;}
      }
    }
    return null;
  }

  static void collect(Node f,String s,Vector result) {
    for(int i=0;i<f.jjtGetNumChildren();i++) {
      Node c=f.jjtGetChild(i);
      if(c.toString().startsWith(s)) {result.addElement(c);}
      collect(c,s,result);
    }
  }

  // extract the first form from the given HTML parse tree
  HtmlForm(Node n,String urlpath) {
    // First find the node that represents the form.
    Node f=find(n,"form");
    if(f==null) {
      System.out.println("Hey! This HTML page contains no form!");
      return;
    }

    // Now find the attribute list of the form tag.
    SimpleNode fa = (SimpleNode) f.jjtGetChild(0);
    Node mn = find(fa,"attribute: METHOD=");
    if(mn==null) {method="POST";} else {method=((NodeAttribute)mn).getValue();}
    Node ma = find(fa,"attribute: ACTION=");
    if(ma==null) {action=urlpath;} else {action=((NodeAttribute)ma).getValue();}

    // Find all the input fields within that form.
    Vector inputTags = new Vector();
    collect(f,"input",inputTags);

    // Then make a class for each form element encountered.
    Enumeration e = inputTags.elements();
    while(e.hasMoreElements()) {
      Node x = (Node)e.nextElement();
      SimpleNode sn = (SimpleNode) x;
      HtmlFormElement fe = new HtmlFormElement(sn);
      contents.addElement(fe);
    }
  }
  
  void set(String n,String v) {
    HtmlFormElement e = find(n);
    if(e==null) {
      System.out.println("Warning: no form element \""+n+"\"!");
    } else {
      e.setValue(v);
    }
  }

  HtmlFormElement find(String n) {
    Enumeration e = contents.elements();
    while(e.hasMoreElements()) {
      HtmlFormElement fe = (HtmlFormElement) e.nextElement();
      Object o = fe.getProperties().get("name");
      if(o==null) {continue;}
      String c = (String) o;
      if(c.equalsIgnoreCase(n)) {return fe;}
    }
    return null;
  }

  String generateQuery() {
    StringBuffer b = new StringBuffer();
    Enumeration e = contents.elements();
    while(e.hasMoreElements()) {
      HtmlFormElement fe = (HtmlFormElement) e.nextElement();
      String a  = fe.generateQueryAttribute();
      if(!a.equals("")) {
	if(!b.toString().equals("")) {b.append("&");}
	b.append(a);
      }
    }
    return b.toString();
  }

  public String toString() {
    StringBuffer x = new StringBuffer();
    x.append("HtmlForm(\"" + method + "\",\"" + action +"\",\n");
    Enumeration e = contents.elements();
    while(e.hasMoreElements()) {
      HtmlFormElement fe = (HtmlFormElement) e.nextElement();
      x.append("  ");
      x.append(fe.toString());
      x.append("\n");
    }
    x.append(")\n");
    return x.toString();
  }
}
  
	
