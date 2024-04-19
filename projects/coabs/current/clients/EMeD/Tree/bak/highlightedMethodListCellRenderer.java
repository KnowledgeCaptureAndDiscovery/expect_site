/*
  Jihie Kim
 */
package Tree;

import com.sun.java.swing.Icon;
import com.sun.java.swing.ImageIcon;
import com.sun.java.swing.JLabel;
import com.sun.java.swing.JTree;
import com.sun.java.swing.tree.TreeCellRenderer;
import com.sun.java.swing.tree.DefaultMutableTreeNode;
import java.awt.Component;
import java.awt.Color;
import java.awt.Font;
import java.awt.Graphics;
import java.awt.Image;
import java.awt.Rectangle;
import java.awt.Dimension;
import com.sun.java.swing.JTextField;
import com.sun.java.swing.JTextArea;
import com.sun.java.swing.text.JTextComponent;
import com.sun.java.swing.Scrollable;

public class highlightedMethodListCellRenderer extends myTextArea implements TreeCellRenderer
{
    /** Font used if the string to be displayed isn't a font. */
    static protected Font             defaultFont;
    /** Icon to use when the item is collapsed. */
    static protected ImageIcon        collapsedIcon;
    /** Icon to use when the item is expanded. */
    static protected ImageIcon        expandedIcon;
    static protected ImageIcon        lockIcon;

  static protected ImageIcon        leftIcon;
  static protected ImageIcon       rightIcon;
  static protected final Color SelectedBackgroundColor = Color.yellow;//new Color(0, 0, 128);

    /** Color to use for the background when selected. */
  
  private boolean highlight = false;
  static Icon theIcon = null;
    static
    {
      leftIcon =new ImageIcon("images/bracket.gif");
      rightIcon =new ImageIcon("images/bracket2.gif");
	try {
	    defaultFont = new Font("Dialog", Font.BOLD, 12);
	    collapsedIcon =new ImageIcon("images/collapsed.gif");
	    expandedIcon = new ImageIcon("images/expanded.gif");
	    lockIcon = null;//new ImageIcon("images/foot.gif");
	} catch (Exception e) {}
	try {
	  collapsedIcon =new ImageIcon("images/collapsed.gif");
	  expandedIcon = new ImageIcon("images/expanded.gif");
	  lockIcon = null;//new ImageIcon("images/foot.gif");
	} catch (Exception e) {
	    System.out.println("Couldn't load images: " + e);
	}
    }

    /** Whether or not the item that was last configured is selected. */
    protected boolean            selected;

    /**
      * This is messaged from JTree whenever it needs to get the size
      * of the component or it wants to draw it.
      * This attempts to set the font based on value, which will be
      * a TreeNode.
      */

  String lines[] = new String[50];
  int rowIdx=0;
  int colIdx=0;

  public void setIcon (ImageIcon ic) {
    theIcon = ic;
  }
  public Icon getIcon () {
    return theIcon;
  }
  public int getIconTextGap () {
    return 4;
  }
  public Component getTreeCellRendererComponent(JTree tree, Object value,
						boolean selected, boolean expanded,
						boolean leaf, int row,
						boolean hasFocus) {
	Font            font;
	String          stringValue = tree.convertValueToText(value, selected,
					   expanded, leaf, row, hasFocus);
	
	/* Set the text. */
	
	//System.out.println(" stringValue:"+stringValue+":");
	String messages = "";
	int mi = stringValue.indexOf("\nMESSAGES");

	if (mi>= 0) {
	  messages = stringValue.substring(mi+9);
	  stringValue = stringValue.substring(0,mi);
	  //System.out.println(" message for node:" + messages+":");
	  String msgs = ""; // messages except the ones for unused vars
	  int ti = messages.indexOf("\n");
	  while (ti >=0) {
	    if (messages.substring (0, ti).indexOf("is not used") < 0)
	      msgs = msgs + messages.substring(0, ti);
	    if (messages.length() > ti+1) {
	      messages = messages.substring (ti+1);
	      ti = messages.indexOf("\n");
	    }
	    else ti = -1;
	  }
	  if (!msgs.equals("")) {
	    //System.out.println(" msgs:" + msgs+":");
	    highlight = true;
	  }
	  else highlight = false;
	  
	}
	setText(stringValue);
	/* Tooltips used by the tree. */
	//setToolTipText(stringValue);

	int idx;
	colIdx = 0;
	rowIdx = 0;
	String temp = stringValue;
	while ((idx = temp.indexOf("\n")) >= 0) {
	  lines[rowIdx] = temp.substring(0,idx);
	  //System.out.println("new string:"+lines[rowIdx]+"**"+lines[rowIdx].length());
	  temp = temp.substring(idx+1);
	  colIdx = Math.max(colIdx, lines[rowIdx].length());
	  rowIdx++;
	}
	lines[rowIdx] = temp;
	colIdx = Math.max(colIdx, lines[rowIdx].length());
	rowIdx++;

	/* Set the image. */
	if(expanded)
	    setIcon(expandedIcon);
	else if(!leaf)
	    setIcon(collapsedIcon);
	else
	    setIcon(lockIcon);
	    
	/* Set the color and the font based on the SampleData userObject. */
	setFont(defaultFont);
	/* Update the selected flag for the next paint. */
	this.selected = selected;
	setRows(rowIdx);
	setColumns(colIdx*11/20);
	//System.out.println("set size:"+rowIdx+","+colIdx);

	return this;
    }
   Image offscreen;
    Dimension offscreensize;
    public void paint(Graphics g) {
	Color            bColor;
	Icon             currentI = getIcon();

	
	Dimension d = getSize();
	//System.out.println("size:"+d.width+","+d.height);

	if (selected)
	  bColor = SelectedBackgroundColor;
	else if(getParent() != null)
	    bColor = getParent().getBackground();
	else
	    bColor = getBackground();

	//  bColor = new Color(255, 230, 230);

	g.setColor(bColor);
	int  offset;
	if(currentI != null && getText() != null) {
	  //System.out.println(" == with icon");
	  offset = currentI.getIconWidth() + getIconTextGap();
	  //System.out.println("offset:"+ offset);
	  g.fillRect(offset, 0, (colIdx)*8,(getHeight() - 1)*rowIdx);
	  
	}
	else {
	  //System.out.println("fill rect2: "+"0,0,"+(colIdx)*8+","+(getHeight() - 1)*rowIdx);
	  g.fillRect(16, 0, colIdx*8, (getHeight()-1)*rowIdx);
	  offset = 15;
	  
	}
	int w = colIdx;
	int h = getHeight();
	int hoff = 14;
	
	if (currentI !=null)  g.drawImage(((ImageIcon)currentI).getImage(), 0, rowIdx*7, null);
	if (rowIdx == 1) { // label 
	  g.setFont(new Font("Dialog", Font.BOLD, 12)); 
	  g.setColor(Color.blue);
	  g.drawString(lines[0], offset, hoff);
	}
	else { // method
	  int gap=0;
	  for (int i=0; i<rowIdx;i++) {

	    gap = i*(h/rowIdx) + hoff;
	    if (highlight) g.setColor(new Color(200,0,0));
	    else g.setColor(Color.black);
	    
	    g.setFont(new Font("Dialog", Font.BOLD, 12));
	    g.drawString(lines[i], offset, gap);
	      //}
	    g.setColor(bColor);	
	  }  
	}
	
    }
    
  
}
