/*
 * undefinedGoalListCellRenderer.java
 *
 *  Jihie Kim
 */
package Tree;

import javax.swing.*;
import java.awt.*;
import javax.swing.tree.*;

public class undefinedGoalListCellRenderer extends expandableTreeCellRenderer implements TreeCellRenderer
{


  boolean isLeaf;

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
	inputWidth = 0;
	String temp = stringValue;
	while ((idx = temp.indexOf("\n")) >= 0) {
	  lines[rowIdx] = temp.substring(0,idx);
	  //System.out.println("new string:"+rowIdx+":"+lines[rowIdx]);
	  temp = temp.substring(idx+1);
	  inputWidth = Math.max(inputWidth, fm.stringWidth(lines[rowIdx]));
	  colIdx = Math.max(colIdx, lines[rowIdx].length());
	  rowIdx++;
	}
	// ignore the last line
	lines[rowIdx] = temp;
	if (rowIdx == 0) { //one line cell
	  inputWidth = Math.max(inputWidth, fm.stringWidth(lines[rowIdx]));
	  colIdx = Math.max(colIdx, lines[rowIdx].length());
	}
	rowIdx++;

	/* Set the image. */
	if(expanded)
	    setIcon(expandedIcon);
	else if(!leaf)
	    setIcon(collapsedIcon);
	else
	    setIcon(lockIcon);
	    
	/* Update the selected flag for the next paint. */
	this.selected = selected;
	//setRows(rowIdx);
	if (rowIdx == 1) setColumns(colIdx);
	else setColumns(colIdx*11/20);

	return this;
    }
 
    public void paint(Graphics g) {
	super.paint(g);
	
	int w = colIdx;
	int h = getHeight();
	int hoff = 14;
	
	int gap=0;
	boolean rfml = false;

	if (rowIdx > 1 &&
	    lines[0].startsWith("More Special")) rfml = true;

	for (int i=0; i<rowIdx;i++) {
	  gap = i*(h/rowIdx) + hoff;
	  if (rfml) g.setColor(rfmlColor);
	  else g.setColor(Color.black);

	  if ((i==0) || (i== 2)) {
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

