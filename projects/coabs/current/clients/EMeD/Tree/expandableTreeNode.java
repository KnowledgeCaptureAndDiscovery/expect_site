package Tree;
import javax.swing.tree.DefaultMutableTreeNode;
import javax.swing.tree.TreeNode;
import editor.*;
import java.awt.*;
import java.awt.event.*;
public class expandableTreeNode extends DefaultMutableTreeNode implements TreeNode{
  String id="";
  String packageName="";
  String type="";
  String message;
  boolean processed;
  boolean expand=true;
  Color displayColor = Color.black;
  Container editor = null;
  Object userObject;
  public expandableTreeNode () {
    super();
    id = "";
    message = "";
    processed = true;
  }  
  public expandableTreeNode (String content) {
    super(content);
    id = null;
  }

  public void setID (String name) {
    this.id = name;
  }
  public void setType (String name) {
    this.type = name;
  }
  public void setPackage (String name) {
    this.packageName = name;
  }
  public void setMessage (String info) {
    message = info;
  }
  public String getMessage () {
    return message;
  }

  public void setEditorUsed (Container me) {
    editor = me;
  }
  public Container getEditorUsed () {
    return editor;
  }

  public void setProcessed (boolean val) {
    processed  = val;
  }
  public boolean processed() {
    return processed;
  }
  public String getID () {
    return id;
  }
  public String getType () {
    return type;
  }
  public String getPackage () {
    return packageName;
  }

  /* node color */
  public Color getColor () {
    return displayColor;
  }
  public void setColor (Color colorValue) {
    displayColor = colorValue;
  }
  public boolean getExpand () {
    return expand;
  }
  public void setExpand (boolean expandValue) {
    expand = expandValue;
  }

  /*
  public TreeNode getParent() {
    return super();
  }
  public void add (expandableTreeNode node) {
    super(node);
  }*/

 
}
