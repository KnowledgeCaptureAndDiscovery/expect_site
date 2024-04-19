/*
 * @(#)expectTreeCellRenderer.java	1.8 98/01/07
 *
 * Copyright (c) 1997 Sun Microsystems, Inc. All Rights Reserved.
 *
 * This software is the confidential and proprietary information of Sun
 * Microsystems, Inc. ("Confidential Information").  You shall not
 * disclose such Confidential Information and shall use it only in
 * accordance with the terms of the license agreement you entered into
 * with Sun.
 *
 * SUN MAKES NO REPRESENTATIONS OR WARRANTIES ABOUT THE SUITABILITY OF THE
 * SOFTWARE, EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
 * PURPOSE, OR NON-INFRINGEMENT. SUN SHALL NOT BE LIABLE FOR ANY DAMAGES
 * SUFFERED BY LICENSEE AS A RESULT OF USING, MODIFYING OR DISTRIBUTING
 * THIS SOFTWARE OR ITS DERIVATIVES.
 *
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
import java.awt.Dimension;
import com.sun.java.swing.JTextField;
import com.sun.java.swing.JTextArea;
import com.sun.java.swing.text.JTextComponent;
import com.sun.java.swing.Scrollable;
public class undefinedGoalListCellRenderer extends myTextArea implements TreeCellRenderer
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
  static protected final Color rfmlColor = new Color(150, 50,50);

    /** Color to use for the background when selected. */
  boolean isLeaf;
    
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
	isLeaf = leaf;
	/* Set the text. */
	//System.out.println(" stringValue:"+stringValue);

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

	return this;
    }
   Image offscreen;
    Dimension offscreensize;
    public void paint(Graphics g) {
	Color            bColor;
	Icon             currentI = getIcon();

	
	Dimension d = getSize();
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
	
	int gap=0;
	boolean rfml = false;
	if (rowIdx > 1 &&
	    lines[0].startsWith("More Special")) rfml = true;

	g.setFont(new Font("Dialog", Font.BOLD, 12));
	for (int i=0; i<rowIdx;i++) {
	  gap = i*(h/rowIdx) + hoff;
	  //System.out.println ("   $$ draw:"+lines[i]+"|"+offset+"|"+gap);
	  if (rfml) g.setColor(rfmlColor);
	  else g.setColor(Color.black);

	  if ((i==0) || (i== 2)) {
	    //if (rfml) g.drawString("     "+lines[i], offset, gap);
	    //else 
	    if (isLeaf) g.drawString(lines[i], offset, gap);
	    else g.drawString("  "+lines[i], offset, gap);
	  }
	  else if (i == 1) {
	    if (!rfml) g.setColor(Color.red);
	    if (isLeaf) g.drawString(lines[i], offset, gap);
	    else g.drawString("  "+lines[i], offset, gap);
	  }
	}
	
    }
    
  
}

