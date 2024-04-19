//File: expandableTreeModel.java
//
// Copyright (C) 1998 by Jihie Kim
// All Rights Reserved
//

package Tree;
import javax.swing.tree.DefaultTreeModel;
import javax.swing.tree.TreeNode;
import javax.swing.tree.TreePath;
import javax.swing.tree.DefaultMutableTreeNode;
import java.awt.Color;

/**
  * expandableTreeModel extends JTreeModel to extends valueForPathChanged.
  * This method is called as a result of the user editing a value in
  * the tree.  If you allow editing in your tree, are using TreeNodes
  * and the user object of the TreeNodes is not a String, then you're going
  * to have to subclass JTreeModel as this example does.
  *
  * modified by Jihie Kim 12/14/98
  *
  * @version 1.3 09/23/97
  * @author Scott Violet
  */

public class expandableTreeModel extends DefaultTreeModel
{
    /**
      * Creates a new instance of expandableTreeModel with newRoot set
      * to the root of this model.
      */
  public expandableTreeModel(expandableTreeNode newRoot) {
    super(newRoot);
  }

    /**
      * Subclassed to message setString() to the changed path item.
      */
  public void valueForPathChanged(TreePath path, Object newValue) {
    /* Update the user object. */
    expandableTreeNode      aNode = (expandableTreeNode)path.getLastPathComponent();
    //String data = (String)aNode.getUserObject();

    //nodeChanged(aNode);
  }
}
