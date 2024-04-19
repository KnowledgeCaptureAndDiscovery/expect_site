/*
 *  expandableTreeCellRenderer.java
 *  Jihie Kim
 
 */
package Tree;

import javax.swing.*;
import java.util.Vector;
import java.awt.*;

public class expandableTreeCellRenderer extends JTextArea 
{
    /** Font used if the string to be displayed isn't a font. */
    static public Font             defaultFont;
    static public Font             highlightFont;
    /** Icon to use when the item is collapsed. */
    static public ImageIcon        collapsedIcon;
    /** Icon to use when the item is expanded. */
    static public ImageIcon        expandedIcon;
    static public ImageIcon        lockIcon;

  static public ImageIcon        leftIcon;
  static public ImageIcon       rightIcon;
  static public final Color SelectedBackgroundColor = Color.yellow;
  static public final Color rfmlColor = new Color(0,150,20);
  static public final Color warningColor = Color.gray;//new Color(150,50,50);
  static public final Color highlightColor = Color.blue;
  static public final Color normalColor = Color.black;

  static public final Color newMethodColor= new Color (160,120,20);

  boolean partitionInfo;
  boolean potentialInfo;
    /** Color to use for the background when selected. */
  static public FontMetrics fm;
  Vector highlightedWords;
  static Icon theIcon = null;
  static
    {
      leftIcon =new ImageIcon("images/bracket.gif");
      rightIcon =new ImageIcon("images/bracket2.gif");
	try {
	    defaultFont = new Font("Dialog", Font.BOLD, 12);
	    highlightFont = new Font("Dialog", Font.BOLD, 12);
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
    public boolean            selected;

    /**
      * This is messaged from JTree whenever it needs to get the size
      * of the component or it wants to draw it.
      * This attempts to set the font based on value, which will be
      * a TreeNode.
      */

  public String lines[] = new String[50];
  public int rowIdx;
  public int colIdx;
  public int inputWidth = 0;
  public int  offset;

  public Color            bColor;
  


  public expandableTreeCellRenderer () {
    fm = getFontMetrics(defaultFont);  
  }

  public void setHighlightedWords(Vector words) {
    highlightedWords = words;
  }

  public void setIcon (ImageIcon ic) {
    theIcon = ic;
  }
  public Icon getIcon () {
    return theIcon;
  }
  public int getIconTextGap () {
    return 4;
  }

  public void drawStringWithHighlights (Graphics g, String line, int offset, int gap) {
    String word;
    int wordLocation, currentInputWidth, currentLoc;
    Color oldColor = g.getColor();
    Font oldFont = g.getFont();
    boolean foundKeyword;

    
    currentLoc = 0;
    if (highlightedWords == null) {
      g.drawString(line,offset,gap);
      return;
    }
    while (currentLoc <line.length()) {
      foundKeyword = false;
      currentInputWidth = fm.stringWidth(line.substring(0,currentLoc));
      for (int i=0; i<highlightedWords.size(); i++) {
	word = (String) highlightedWords.elementAt(i);
	if (line.toLowerCase().startsWith(word, currentLoc)) {
	  foundKeyword = true;
	  g.setColor (highlightColor);
	  g.setFont (highlightFont);
	  g.drawString(line.substring(currentLoc, currentLoc+word.length()),
		       offset+currentInputWidth,gap);
	  g.setFont (oldFont);
	  g.setColor (oldColor);
	  currentLoc = currentLoc+ word.length();
	  break;
	}
      }
      if (!foundKeyword) {
	g.drawString(line.substring(currentLoc, currentLoc+1),
		     offset+currentInputWidth,gap);
	currentLoc++;
      }
    }
  }
  
    public void paint(Graphics g) {
	Icon             currentI = getIcon();

	if(selected)
	    bColor = SelectedBackgroundColor;
	else if(getParent() != null)
	    bColor = getParent().getBackground();
	else
	    bColor = getBackground();
	g.setColor(bColor);
	g.setFont(defaultFont);

	if(currentI != null && getText() != null) {
	  offset = currentI.getIconWidth() + getIconTextGap();
	  g.fillRect(offset+10, 0, inputWidth, (getHeight() - 1)*rowIdx);
	}
	else {
	  offset = 15;
	  g.fillRect(offset, 0, inputWidth, (getHeight()-1)*rowIdx);

	}

	if (currentI !=null)  
	  g.drawImage(((ImageIcon)currentI).getImage(), 0, rowIdx*7, null);
	
    }
   
  
}
