package Tree;

import javax.swing.JTree;
import javax.swing.tree.TreeNode;
import javax.swing.tree.TreePath;
import java.util.Enumeration;

public class searchMethodList extends JTree {
  private JTree inputTree;
  private JTree methodList;
  private String key;
  private expandableTreeNode top = new expandableTreeNode("Search Method Result"); 

  public searchMethodList (JTree theTree) {
    inputTree = theTree;
  }

  public JTree searchOn(String inputString) {
    key = inputString.toUpperCase();
    methodList = new JTree(top);
    buildNodes (key, inputTree.getModel.getRoot());
    return methodTree;
  }

  private void buildNodes (String key, expandableTreeNode node) {
    if (node == null) return;
    String content =  (String) node.getUserObject();
    String contentInUpperCase = content.toUpperCase();
    if (contentInUpperCase.indexOf("\n") >= 0 // it is a method
	&& contetInUpperCase.indexOf(key) >=0) {
      expandableTreeNode newNode = new expandableTreeNode();
      newNode.setUserObject(content);
      newNode.setID((String) node.getID());
      top.add(content);
    }
    Enumeration children = node.children();
    while (children.hasMoreElements()) {
      expandableTreeNode child = (expandableTreeNode) children.nextElement();
      buildNodes (key, child);
    }
  }


}
