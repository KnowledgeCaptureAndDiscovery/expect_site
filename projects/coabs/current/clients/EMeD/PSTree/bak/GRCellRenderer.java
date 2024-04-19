/*
 * GRCellRenderer.java	99/03/07
 *
 * by Jihie Kim
 *
 */
package PSTree;

import javax.swing.*;
import java.awt.*;
import javax.swing.tree.*;
import Tree.*;

public class GRCellRenderer extends expandableTreeCellRenderer implements TreeCellRenderer
{
   
  static protected final Color potentialMatchColor = new Color(250, 50,50);
    /** Color to use for the background when selected. */
  boolean isLeaf;
  String stringValue;
  GRObject data;
  Color objectColor;
  public Component getTreeCellRendererComponent(JTree tree, Object value,
						boolean selected, boolean expanded,
						boolean leaf, int row,
						boolean hasFocus) {
	Font            font;
	//String          stringValue = tree.convertValueToText(value, selected,
	//				   expanded, leaf, row, hasFocus);
	data = (GRObject) ((expandableTreeNode)value).getUserObject();
	stringValue = data.getContent();
	objectColor = data.getColor();
	isLeaf = leaf;
	
	int idx;
	colIdx = 0;
	rowIdx = 0;
	inputWidth = 0;
	int offsetToEOL=0;
	String temp = stringValue;
	while ((idx = temp.indexOf("\n")) >= 0) {
	  //remove duplicate info because there is 'Expected-Result already
	  offsetToEOL=0;
	  if (temp.startsWith(" How")) {
	    int tempIdx;

	    while ((tempIdx = temp.indexOf("#"))> 0) {
	      if (offsetToEOL > 0)
		lines[rowIdx] = "          "+temp.substring(0,tempIdx);
	      else lines[rowIdx] = temp.substring(0,tempIdx);
	      //System.out.println("new line:"+lines[rowIdx]);
	      inputWidth = Math.max(inputWidth, fm.stringWidth(lines[rowIdx]));
	      colIdx = Math.max(colIdx, lines[rowIdx].length());
	      rowIdx++;
	      temp = temp.substring(tempIdx+1);
	      offsetToEOL = offsetToEOL+tempIdx+1;
	    }
	    if (offsetToEOL > 0) 
	      lines[rowIdx] = "          "+temp.substring(0,idx-offsetToEOL);
	    else lines[rowIdx] = temp.substring(0,idx-offsetToEOL);
	    //System.out.println("new line2:"+lines[rowIdx]);
	    inputWidth = Math.max(inputWidth, fm.stringWidth(lines[rowIdx]));
	    colIdx = Math.max(colIdx, lines[rowIdx].length());
	    rowIdx++;
	  }
	  else if (!temp.startsWith(" Expected Result")) {
	    lines[rowIdx] = temp.substring(0,idx);
	    //System.out.println("new string:"+lines[rowIdx]+"**"+lines[rowIdx].length());
	    inputWidth = Math.max(inputWidth, fm.stringWidth(lines[rowIdx]));
	    colIdx = Math.max(colIdx, lines[rowIdx].length());
	    rowIdx++;
	  }
	  temp = temp.substring(idx+1-offsetToEOL);
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
	    
	/* Update the selected flag for the next paint. */
	this.selected = selected;
	setRows(rowIdx);
	setColumns(colIdx*13/20);
	//System.out.println(" size:"+rowIdx+","+colIdx);
	//System.out.println(" fm size:"+inputWidth);

	return this;
    }
  public GRCellRenderer () {
    super();
  }
    public void paint(Graphics g) {
	super.paint(g);
	int w = colIdx;
	int h = getHeight();
	int hoff = 14;
	
	int gap=0;
	boolean allRed = false;
	
	for (int i=0; i<rowIdx;i++) {
	  g.setFont(defaultFont);
	  //System.out.println (" h:"+h);
	  gap = i*(h/rowIdx) + hoff;
	  
	  if (allRed) g.setColor (Color.red);
	  else g.setColor(Color.black);
	  if ((i==0) || (i== (rowIdx-1))) {
	    if (lines[i].startsWith("[UNDEFINED")) {
	      g.setColor(Color.red);
	      allRed = true;
	    }
	    else if (objectColor != Color.black)
	      g.setColor(objectColor);
	    else if (!allRed) g.setColor(Color.blue);
	  }
	  else if (i==1) {
	    if (lines[i].startsWith(" rfml"))
	        g.setColor(rfmlColor);
	  }
	  else if (lines[i].startsWith(" Result-OBTAINED") ||
		   lines[i].startsWith(" Result-DECLARED") ||
		   lines[i].endsWith("UNDEFINED) ") ||
		   lines[i].startsWith("Potential") ||
		   lines[i].startsWith(" Potential")) {
	    g.setColor(Color.red);
	  }
	  else if (lines[i].startsWith("                              for subgoal")) {
	    g.setColor(Color.red);
	    g.setFont(new Font("Dialog", Font.PLAIN, 12));
	  }
	  else {
	    g.setFont(new Font("Dialog", Font.PLAIN, 12));
	  }
	  if (isLeaf) {
	    g.drawString(lines[i], offset, gap);
	    //System.out.println ("   $$ draw:"+lines[i]+"|"+offset+"|"+gap);
	  }
	  else 
	    g.drawString("  "+lines[i], offset, gap);

	}
	
    }
    
  
}
