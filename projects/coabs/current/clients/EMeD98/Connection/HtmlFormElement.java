package Connection;

import java.util.*;
import java.net.*;

class HtmlFormElement {
  private Hashtable properties = new Hashtable();

  HtmlFormElement(SimpleNode n)
  {
    Vector attributes = new Vector();
    HtmlForm.collect(n,"attribute",attributes);
    Enumeration e = attributes.elements();
    while(e.hasMoreElements()) {
      NodeAttribute a = (NodeAttribute) e.nextElement();
      properties.put(a.getName().toLowerCase(),a.getValue());
    }
  }

  Hashtable getProperties() {
    return properties;
  }

  void setValue(String v) {
    properties.put("value",v);
  }

  String generateQueryAttribute() {
    String type = (String) properties.get("type");
    if(type.equalsIgnoreCase("submit")) {
      return "submit=submit";//seems otherwise an empty form won't work
    } else if(type.equalsIgnoreCase("checkbox")) {
//       String checked = (String) properties.get("CHECKED");
//       if(checked==null) {
// 	return "";
//       } else {
// 	String name = (String) properties.get("name");
// 	return URLEncoder.encode(name)+"="+URLEncoder.encode("CHECKED");
//       }
      String name = (String) properties.get("name");
      String value = (String) properties.get("value");
      return URLEncoder.encode(name)+"="+URLEncoder.encode(value);
    } else if(type.equalsIgnoreCase("text")) {
      String name = (String) properties.get("name");
      String value = (String) properties.get("value");
      return URLEncoder.encode(name)+"="+URLEncoder.encode(value);
    } else {
      System.out.println("Warning: unknown HTML form element \""+type+"\"");
      return "";
    }
  }

  public String toString() {
    StringBuffer x = new StringBuffer();
    x.append("HtmlFormElement-");
    String type = (String) properties.get("type");
    x.append(type+"(");
    Enumeration e=properties.keys();
    while(e.hasMoreElements()) {
      String n = (String) e.nextElement();
      String v = (String) properties.get(n);
      x.append(n);
      if(!(v==null||v.equals("#DEFAULT"))) {
	x.append("=");
	x.append(v);
      }
      x.append(" ");
    }
    x.append(")");
    return x.toString();
  }
}
