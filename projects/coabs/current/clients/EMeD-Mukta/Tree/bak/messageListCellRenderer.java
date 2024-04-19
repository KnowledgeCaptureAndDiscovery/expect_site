/*
 * @(#)methodListCellRenderer.java	1.8 98/01/07
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
import java.awt.Rectangle;
import java.awt.Dimension;
import com.sun.java.swing.JTextField;
import com.sun.java.swing.JTextArea;
import com.sun.java.swing.text.JTextComponent;
import com.sun.java.swing.Scrollable;

public class messageListCellRenderer extends myTextArea implements TreeCellRenderer
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
	setText(stringValue);

	int idx;
	colIdx = 0;
	rowIdx = 0;
	String temp = stringValue;
	while ((idx = temp.indexOf("\n")) >= 0) {
	  lines[rowIdx] = temp.substring(0,idx);
	  if (lines[rowIdx].length() >70) {
	    String tmp = lines[rowIdx];
	    lines[rowIdx] = tmp.substring(0,70);
	    rowIdx++;
	    lines[rowIdx] = "   "+tmp.substring(70);
	  }
	  temp = temp.substring(idx+1);
	  colIdx = Math.max(colIdx, lines[rowIdx].length());
	  rowIdx++;
	}
	lines[rowIdx] = temp;
	if (lines[rowIdx].length() >70) {
	  String tmp = lines[rowIdx];
	  lines[rowIdx] = tmp.substring(0,70);
	  rowIdx++;
	  lines[rowIdx] = "   "+tmp.substring(70);
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
	setColumns(colIdx*1/2);

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
	  offset = currentI.getIconWidth() + getIconTextGap();
	  g.fillRect(offset, 0, (colIdx)*8,(getHeight() - 1)*rowIdx);
	  
	}
	else {
	  g.fillRect(16, 0, colIdx*8, (getHeight()-1)*rowIdx);
	  offset = 30;
	  
	}
	int w = colIdx;
	int h = getHeight();
	int hoff = 14;

	g.setColor(Color.blue);
	g.setFont(new Font("Dialog", Font.PLAIN, 12)); 

	g.drawString(lines[0], offset, hoff);

	if (currentI !=null)  g.drawImage(((ImageIcon)currentI).getImage(), 0, rowIdx*7, null);

	int gap=0;
	for (int i=0; i<rowIdx;i++) {

	  gap = i*(h/rowIdx) + hoff;
	  g.setColor(Color.red);
	  g.setFont(new Font("Dialog", Font.PLAIN, 12));
	  g.drawString(lines[i], offset, gap);
	  System.out.println("offset:"+offset+"|gap:"+gap+"|"+lines[i]);
	}
	
    }
    
  
}
