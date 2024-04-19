/*
  Jihie Kim
 */
package Tree;

import javax.swing.*;
import java.util.Vector;
import javax.swing.tree.*;
import java.awt.*;
import javax.swing.text.JTextComponent;

public class highlightedMethodListCellRenderer extends expandableTreeCellRenderer implements TreeCellRenderer
{

    /** Color to use for the background when selected. */

  private boolean highlight = false;

  public highlightedMethodListCellRenderer () {
    super();
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
	rowIdx = 0;colIdx = 100;
	String temp = stringValue;
	inputWidth = 0;
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
	
	//setRows(rowIdx);
	if (rowIdx == 1) // label
	  setColumns(colIdx);
	
	//setColumns((int)Math.sqrt((double)colIdx));
	return this;
    }

    public void paint(Graphics g) {
	super.paint(g);

	int h = getHeight();
	int hoff = 15;

	if (rowIdx == 1) { // label 
	  g.setColor(Color.blue);
	  g.drawString(lines[0], offset, hoff);
	}
	else { // method
	  int gap=0;
	  for (int i=0; i<rowIdx;i++) {

	    gap = i*(h/rowIdx) + hoff;
	    if (highlight) g.setColor(new Color(200,0,0));
	    else g.setColor(Color.black);
	    
	    g.drawString(lines[i], offset, gap);
	    g.setColor(bColor);	
	  }  
	}
	
    }
    
  
}
