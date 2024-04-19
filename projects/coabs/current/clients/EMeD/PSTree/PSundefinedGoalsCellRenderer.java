/*
 * PSundefinedGoalsCellRenderer.java
 *
 * by Jihie Kim

 *
 */
package PSTree;

import javax.swing.*;
import java.awt.*;
import javax.swing.tree.*;
import Tree.expandableTreeCellRenderer;

public class PSundefinedGoalsCellRenderer extends expandableTreeCellRenderer implements TreeCellRenderer
{
   
    /** Color to use for the background when selected. */
    
  public Component getTreeCellRendererComponent(JTree tree, Object value,
						boolean selected, boolean expanded,
						boolean leaf, int row,
						boolean hasFocus) {
	Font            font;
	String          stringValue = tree.convertValueToText(value, selected,
					   expanded, leaf, row, hasFocus);

	/* Set the text. */
	//System.out.println(" stringValue:"+stringValue);

	setText(stringValue);
	/* Tooltips used by the tree. */
	//setToolTipText(stringValue);

	int idx;
	colIdx = 0;
	rowIdx = 0;inputWidth = 0;
	String temp = stringValue;
	while ((idx = temp.indexOf("\n")) >= 0) {
	  lines[rowIdx] = temp.substring(0,idx);
	  //System.out.println("new string:"+lines[rowIdx]+"**"+lines[rowIdx].length());
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
	setColumns(colIdx*11/20);

	return this;
    }

    public void paint(Graphics g) {
	super.paint(g);
	int w = colIdx;
	int h = getHeight();
	int hoff = 14;
	
	int gap=0;
	for (int i=0; i<rowIdx;i++) {
	  gap = i*(h/rowIdx) + hoff;
	  g.setColor(Color.black);
	  //System.out.println ("   $$ draw:"+lines[i]+"|"+offset+"|"+gap);
	  if ((i==0) || (i== 2)) {
	    g.setFont(new Font("Dialog", Font.BOLD, 12));
	    g.drawString(lines[i], offset, gap);
	  }
	  else if (i == 1) {
	    g.setFont(new Font("Dialog", Font.PLAIN, 12));
	    g.setColor(Color.red);
	    g.drawString(lines[i], offset, gap);

	  }
	  else if (!lines[i].startsWith("Capability"))
	    g.drawString(lines[i], offset, (i-1)*(h/rowIdx) + hoff);
	}
	
    }
    
  
}

