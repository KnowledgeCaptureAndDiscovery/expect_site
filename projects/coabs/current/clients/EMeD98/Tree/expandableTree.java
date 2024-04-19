package Tree;

import com.sun.java.swing.JTree;
import com.sun.java.swing.tree.TreeNode;
import com.sun.java.swing.tree.TreePath;
import java.util.Enumeration;
import java.util.Stack;

public class expandableTree extends JTree {
  expandableTreeNode root = null;
  Object path[];
  Stack nodeStack = new Stack();
  expandableTreeModel treeModel;

  public expandableTree(expandableTreeNode node) {
    super(node);
    root = node;
  }

  public expandableTree(expandableTreeModel model) {
    super(model);
    root = (expandableTreeNode) model.getRoot();
    treeModel = model;
  }

  public expandableTreeNode getRoot () {
    return root;
  }

  public void expandTree () {
    expandSubTree (root);
  }

  public void expandSubTree (expandableTreeNode node) {
    if (null == node) return;
    TreePath path = findPath(node);
    if (path != null) expandPath(path);
    int NofChild = node.getChildCount();
    for (int i = 0; i < NofChild; i++) {
      expandSubTree ((expandableTreeNode) node.getChildAt(i));
    }
  }

  public expandableTreeNode getSelectedNode() {
    TreePath   selPath = getSelectionPath();

    if(selPath != null)
      return (expandableTreeNode)selPath.getLastPathComponent();
    return null;
  }

  public String getSelectedName() {
    expandableTreeNode current = getSelectedNode();
    if (current != null) {
      String id = current.getID();
      if (id != null) return id;
      else return current.toString();
    }
    return null;
  }

  public TreePath findPath(String id) {
    int i = 0;
    seekNode(root, id.trim());
    path = new Object[nodeStack.size()];

    while (!nodeStack.empty()) {
      path[i] = nodeStack.pop();
      i++;
    }
    if (i == 0) return null;
    else return new TreePath(path);
    
  }

  public TreePath findPath(expandableTreeNode givenNode) {
    expandableTreeNode node = givenNode;
    int i = 0;
    while (node != null) {
      nodeStack.push (node); 
      node = (expandableTreeNode) node.getParent();
    }
    path = new Object[nodeStack.size()];
    while (!nodeStack.empty()) {
      path[i] = nodeStack.pop();
      i++;
    }
    if (path != null) return new TreePath(path);
    else return null;
  }

  public String getContent(expandableTreeNode node) {
    String nodeID = node.getID();
    if (nodeID == null) nodeID = node.toString();
    return nodeID.trim();
  }

  public boolean seekNode (expandableTreeNode node, String id) {
    if (node == null) return false;
    if (id.equals(getContent(node))) {
      nodeStack.push (node); 
      return true;
    }
    Enumeration children = node.children();
    while (children.hasMoreElements()) {
      expandableTreeNode child = (expandableTreeNode) children.nextElement();
      if (seekNode(child, id)) {
	nodeStack.push (node); 
	return true;
      }
    }
    return false;
  }
  
}
