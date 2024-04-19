package Tree;
import com.sun.java.swing.tree.DefaultMutableTreeNode;
import com.sun.java.swing.tree.TreeNode;
import editor.*;
public class expandableTreeNode extends DefaultMutableTreeNode implements TreeNode{
  String id;
  String message;
  boolean processed;
  MEditor editor = null;
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
  public void setMessage (String info) {
    message = info;
  }
  public String getMessage () {
    return message;
  }

  public void setEditorUsed (MEditor me) {
    editor = me;
  }
  public MEditor getEditorUsed () {
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
  /*
  public TreeNode getParent() {
    return super();
  }
  public void add (expandableTreeNode node) {
    super(node);
  }
  public void setUserObject (Object object) {
    super(object);
  }*/
}
