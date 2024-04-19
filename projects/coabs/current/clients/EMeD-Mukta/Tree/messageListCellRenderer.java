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

import javax.swing.*;
import java.util.Vector;
import javax.swing.tree.*;
import java.awt.*;

public class messageListCellRenderer extends expandableTreeCellRenderer implements TreeCellRenderer
{
  int childCount;
  public Component getTreeCellRendererComponent(JTree tree, Object value,
						boolean selected, boolean expanded,
						boolean leaf, int row,
						boolean hasFocus) {
	Font            font;
	String          stringValue = tree.convertValueToText(value, selected,
					   expanded, leaf, row, hasFocus);

	/* Set the text. */
	setText(stringValue);
	childCount = ((expandableTreeNode)value).getChildCount();

	int idx;
	colIdx = 0;
	rowIdx = 0;
	String temp = stringValue;
	inputWidth = 0;
	while ((idx = temp.indexOf("\n")) >= 0) {
	  lines[rowIdx] = temp.substring(0,idx);
	  /*if (lines[rowIdx].length() >70) {
	    String tmp = lines[rowIdx];
	    lines[rowIdx] = tmp.substring(0,70);
	    rowIdx++;
	    lines[rowIdx] = "   "+tmp.substring(70);
	  }*/
	  temp = temp.substring(idx+1);
	  inputWidth = Math.max(inputWidth, fm.stringWidth(lines[rowIdx]));
	  colIdx = Math.max(colIdx, lines[rowIdx].length());
	  rowIdx++;
	}
	lines[rowIdx] = temp;
	inputWidth = Math.max(inputWidth, fm.stringWidth(lines[rowIdx]));
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
	if (rowIdx == 1) setColumns(colIdx);
	else setColumns(colIdx*13/20);
	return this;
    }

    public void paint(Graphics g) {
      super.paint(g);
	int w = colIdx;
	int h = getHeight();
	int hoff = 14;
	int gap;

	//g.drawString(lines[0], offset, hoff);
	g.setFont(new Font("Dialog", Font.BOLD, 12)); 

	if (lines[0].startsWith("<Warnings")) {
	  gap = 0;
	  for (int i=0; i<rowIdx;i++) {
	    gap = i*(h/rowIdx) + hoff;
	    g.setColor(Color.black);
	    if (lines[i].startsWith("Blue"))
	      g.setColor (Color.blue);
	    else if (lines[i].startsWith("Red"))
	      g.setColor (Color.red);
	    g.drawString(lines[i], offset, gap);
	  }
	  /*
	  rowIdx = 5;
	  g.setColor(Color.black);
	  g.drawString(lines[0], offset, gap);
	  if (childCount >0) {
	    gap = (h/rowIdx) + hoff;
	    g.drawString("--------------------", offset, gap);

	    gap = 2*(h/rowIdx) + hoff;
	    g.setColor(Color.red);
	    g.drawString("Red: Warning", offset, gap);
	    gap = 3*(h/rowIdx) + hoff;
	    g.setColor(Color.blue);
	    g.drawString("Blue: Proposed Fixes", offset, gap);
	    
	    gap = 4*(h/rowIdx) + hoff;
	    g.setColor(Color.black);
	    g.drawString("--------------------", offset, gap);
	  }*/

	}
	else {
	  if (lines[0].startsWith("problems")) g.setColor(Color.black);
	  else if (lines[0].startsWith("== "))
	    g.setColor (highlightColor);
	  else g.setColor (Color.red);
	  
	  gap=0;
	  for (int i=0; i<rowIdx;i++) {
	    gap = i*(h/rowIdx) + hoff;
	    g.drawString(lines[i], offset, gap);
	    //System.out.println("offset:"+offset+"|gap:"+gap+"|"+lines[i]);
	  }
	}
	
    }
    
  
}
