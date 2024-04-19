/*
 * GRSmallCellRenderer.java	 99/03/07
 *
 * by Jihie Kim

 *
 */
package PSTree;

import javax.swing.*;
import java.awt.*;
import javax.swing.tree.*;
import Tree.*;

public class GRSmallCellRenderer extends expandableTreeCellRenderer implements TreeCellRenderer
{
   
  boolean isLeaf;
  String stringValue;
  GRObject data;
  Color objectColor;
  public Component getTreeCellRendererComponent(JTree tree, Object value,
						boolean selected, boolean expanded,
						boolean leaf, int row,
						boolean hasFocus) {
	Font            font;
	
	data = (GRObject) ((expandableTreeNode)value).getUserObject();
	stringValue = data.getContent();
	objectColor = data.getColor();
	isLeaf = leaf;
	int idx;
	colIdx = 0;
	rowIdx = 0;
	inputWidth = 0;
	String temp = stringValue;
	int offsetToEOL=0;
	while ((rowIdx < 2) && ((idx = temp.indexOf("\n")) >= 0)){
	//while ((idx = temp.indexOf("\n")) >= 0){
	  //display NL description or rfml only
	  offsetToEOL=0;
	  if (temp.startsWith(" How")) {
	    int tempIdx;
	    while ((tempIdx = temp.indexOf("#"))> 0) {
	      if (offsetToEOL > 0)
		lines[rowIdx] = "          "+temp.substring(0,tempIdx);
	      else lines[rowIdx] = temp.substring(0,tempIdx);
	      inputWidth = Math.max(inputWidth, fm.stringWidth(lines[rowIdx]));
	      colIdx = Math.max(colIdx, lines[rowIdx].length());
	      rowIdx++;
	      temp = temp.substring(tempIdx+1);
	      offsetToEOL = offsetToEOL+tempIdx+1;
	    }
	    if (offsetToEOL > 0)
	      lines[rowIdx] = "          "+temp.substring(0,idx-offsetToEOL);
	    else lines[rowIdx] = temp.substring(0,idx-offsetToEOL);
	    inputWidth = Math.max(inputWidth, fm.stringWidth(lines[rowIdx]));
	    colIdx = Math.max(colIdx, lines[rowIdx].length());
	    rowIdx++;
	  }
	  else if (rowIdx ==0 || temp.startsWith(" reformulate")
	       || temp.startsWith(" Result-Declared") ||temp.startsWith(" Expected Result") ) { 
	    // System.out.println("new line:"+temp.substring(0,idx));
	    lines[rowIdx] = temp.substring(0,idx);
	    inputWidth = Math.max(inputWidth, fm.stringWidth(lines[rowIdx]));
	    colIdx = Math.max(colIdx, lines[rowIdx].length());
	    rowIdx++;
	  }
	  temp = temp.substring(idx+1-offsetToEOL);
	}

	String lastRow = temp.substring(temp.lastIndexOf("\n")+1);
	if (lastRow.length() == 1) {
	  // primitive info is collapsed into one line 
	  if (rowIdx == 1 && lastRow.equals("]")) { 
	    rowIdx--;
	    lines[rowIdx] = lines[rowIdx] + lastRow;
	  }
	  else lines[rowIdx] = lastRow;
	}
	else 
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
	setColumns(colIdx*13/20);
	//System.out.println("set size:"+rowIdx+","+colIdx);
	Dimension d = this.getSize();
	return this;
    }

    public void paint(Graphics g) {
	super.paint(g);

	int w = colIdx;
	int h = getHeight();
	int hoff = 14;

	int gap=0;
	boolean allRed = false;

        // checking if the node should be highlighted
	if (stringValue.indexOf("DECLARED")>0) allRed = true;

	for (int i=0; i<rowIdx;i++) {
	
	  gap = i*(h/rowIdx) + hoff;
	  
	  g.setColor(normalColor);
	  if (i==1) {
	    if (lines[i].startsWith(" reformulate"))
	      g.setColor(rfmlColor);
	    else if (objectColor != Color.black)
	      g.setColor(objectColor);
	    //else if (lines[i].startsWith(" How"))
	    //  g.setColor (normalColor);
	    //else if (lines[i].startsWith("]"))
	    //  g.setColor(highlightColor);
	  }
	  else if ((i==0) || (i== (rowIdx-1))) {
	    
	    if (allRed) g.setColor (Color.red);
	    else if (lines[i].startsWith("[UNDEFINED")) {
	      g.setColor(Color.red);
	      allRed = true;
	    }
	    else if (objectColor != Color.black)
	      g.setColor(objectColor);
	    else g.setColor(Color.blue);

	  }
	  if (isLeaf) g.drawString(lines[i], offset, gap);
	  else g.drawString("   "+lines[i], offset, gap);
	}
	
    }
    
  
}
