/*
 * methodListCellRenderer.java	
 *

 *  Jihie Kim
 */
package Tree;

import javax.swing.*;
import java.util.Vector;
import javax.swing.tree.*;
import java.awt.*;

public class methodListCellRenderer extends expandableTreeCellRenderer 
implements TreeCellRenderer
{
  searchMethodsRenderer searchResultsRenderer;
 
  public methodListCellRenderer (searchMethodsRenderer sRenderer) {
    super();
    searchResultsRenderer = sRenderer; 
  }
 
  public Component getTreeCellRendererComponent(JTree tree, Object value,
						boolean selected, boolean expanded,
						boolean leaf, int row,
						boolean hasFocus) {
	Font            font;
	String          stringValue = tree.convertValueToText(value, selected,
					   expanded, leaf, row, hasFocus);
	setText(stringValue);
	/* Tooltips used by the tree. */
	//setToolTipText(stringValue);

	int idx;
	rowIdx = 0;colIdx = 0;inputWidth = 0;
	String temp = stringValue;
	partitionInfo = false;
	potentialInfo = false;
	while ((idx = temp.indexOf("\n")) >= 0) {
	  lines[rowIdx] = temp.substring(0,idx);
	  //System.out.println("new string:"+lines[rowIdx]+"**"+lines[rowIdx].length());
	  
	  temp = temp.substring(idx+1);
	  inputWidth = Math.max(inputWidth, fm.stringWidth(lines[rowIdx]));
	  colIdx = Math.max(colIdx, lines[rowIdx].length());
	  rowIdx++;
	}
	lines[rowIdx] = temp;
	if (lines[rowIdx].indexOf ("can be") > 0)
	  partitionInfo = true;
	else if (lines[0].indexOf ("Potential") >= 0) {
	  potentialInfo = true;
	}
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
	//setRows(rowIdx);
	if (rowIdx == 1) // label
	  setColumns(colIdx);
	return this;
    }

  public void paint(Graphics g) {
	super.paint(g);
	int h = getHeight();
	int hoff = 15;
	g.setFont(new Font("Dialog", Font.PLAIN, 12));
        //g.setFont(defaultFont);


	setHighlightedWords(searchResultsRenderer.getKeywords());
	if (rowIdx == 1) { // label 
	  g.setColor(rfmlColor);
	  //if (partitionInfo) g.setColor(rfmlColor);
	  //else g.setColor(Color.black);
	  drawStringWithHighlights(g,lines[0], offset, hoff);
	}
	else {
	  int gap=0;
	  for (int i=0; i<rowIdx;i++) {
	    gap = i*(h/rowIdx) + hoff;
	    if (i==0 && lines[i].indexOf("no direct match") >=0) { 
	      g.setColor(Color.red);
	    }
	    else if (partitionInfo) {
	      g.setColor(rfmlColor);
	    }
	    else if (potentialInfo) {
	      g.setColor(warningColor);
	    }
	    else {
	      g.setColor(Color.black);
	    }
	   
	    drawStringWithHighlights(g, lines[i], offset, gap);
	
	    g.setColor(bColor);	
	  }  
	}
	
    }
    
  
}
