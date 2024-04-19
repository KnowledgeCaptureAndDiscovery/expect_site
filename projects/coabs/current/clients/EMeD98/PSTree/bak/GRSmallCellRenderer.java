/*
 * @(#)PStreeCellRenderer.java	 99/03/07
 *
 * by Jihie Kim

 *
 */
package PSTree;

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
//import Tree.myTextArea;

public class GRSmallCellRenderer extends JTextArea implements TreeCellRenderer
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

 boolean isLeaf;

 
    /** Color to use for the background when selected. */
  static protected final Color rfmlColor = new Color(0, 150, 0);
  static Icon theIcon = null;
    static
    {
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
  int rowIdx;
  int colIdx;

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

	//setText(stringValue);
	isLeaf = leaf;
	int idx;
	colIdx = 0;
	rowIdx = 0;
	String temp = stringValue;
	while ((rowIdx < 2) && ((idx = temp.indexOf("\n")) >= 0)){
	//while ((idx = temp.indexOf("\n")) >= 0){
	  lines[rowIdx] = temp.substring(0,idx);
	  temp = temp.substring(idx+1);
	  colIdx = Math.max(colIdx, lines[rowIdx].length());
	  rowIdx++;
	}
	if (rowIdx == 2) {
	  String lastRow = temp.substring(temp.lastIndexOf("\n")+1);
	  if (lastRow.length() == 1)
	    lines[rowIdx] = lastRow;
	  else rowIdx--;
	} else {
	  lines[rowIdx] = temp;
	}
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
	Dimension d = this.getSize();
	return this;
    }
   Image offscreen;
    Dimension offscreensize;
    public void paint(Graphics g) {
	Color            bColor;
	Icon             currentI = getIcon();

	//setSize(colIdx*17, rowIdx*20);
	Dimension d = getSize();
	//System.out.println("size:"+d.width+","+d.height);
	//System.out.println("size:"+getWidth()+","+getHeight());
	if(selected)
	    bColor = SelectedBackgroundColor;
	else if(getParent() != null)
	    bColor = getParent().getBackground();
	else
	    bColor = getBackground();
	g.setColor(bColor);

	int  offset;
	if(currentI != null && getText() != null) {
	  //System.out.println(" == with icon");
	  offset = currentI.getIconWidth() + getIconTextGap();
	  //System.out.println("offset:"+ offset);
	  //g.fillRect(offset, 0, (colIdx)*8,(getHeight() - 1)*rowIdx);
	  g.fillRect(offset, 0, getWidth()+offset, getHeight());
	}
	else {
	  //System.out.println("fill rect2: "+"0,0,"+(colIdx)*8+","+(getHeight() - 1)*rowIdx);
	  //g.fillRect(16, 0, colIdx*8, (getHeight()-1)*rowIdx);
	  offset = 15;
	  g.fillRect(offset, 0, getWidth()+offset, getHeight());

	  
	}

	int w = colIdx;
	int h = getHeight();
	int hoff = 14;

	if (currentI !=null)  g.drawImage(((ImageIcon)currentI).getImage(), 0, rowIdx*7, null);
	
	int gap=0;
	boolean allRed = false;
	for (int i=0; i<rowIdx;i++) {
	  //System.out.println (" h:"+h);
	  gap = i*(h/rowIdx) + hoff;
	  //System.out.println ("   $$ draw:"+lines[i]+"|"+offset+"|"+gap);
	  if (allRed) g.setColor (Color.red);
	  else g.setColor(Color.black);
	  if (i==1) {
	    if (lines[i].startsWith(" rfml"))
	        g.setColor(rfmlColor);
	    g.setFont(new Font("Dialog", Font.BOLD, 12));
	  }
	  else if ((i==0) || (i== (rowIdx-1))) {
	    if (lines[i].startsWith("[Method")||
	        lines[i].startsWith("]")) {
	      if (!allRed) g.setColor(Color.blue);
	    }
	    else if (lines[i].startsWith("[UNDEFINED")) {
	      g.setColor(Color.red);
	      allRed = true;
	    }
	    g.setFont(new Font("Dialog", Font.BOLD, 12));

	  }
	  if (isLeaf) g.drawString(lines[i], offset, gap);
	  else g.drawString("   "+lines[i], offset, gap);
	}
	
    }
    
  
}
