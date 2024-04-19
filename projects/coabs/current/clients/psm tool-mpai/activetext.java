//
// This class is a textPane that has a pointer to its internal data as a
// structured form. It can highlight elements of the form when you pass
// the mouse over them and call a function on the element when you click
// over it.
//
// It also has a search facility so that all instances provide a uniform
// search interface. If you call the highlightMatches(String) method,
// the matches are highlighted with matchHighlightStyle, and you can
// step through them selecting them one by one by calling
// selectNextMatch().
//

import javax.swing.*;
import javax.swing.text.*;
import javax.swing.event.*;
import java.awt.*;
import java.awt.event.*;

import Connection.*;

public class ActiveText extends JTextPane implements MouseInputListener {

    LayedData lData = null, lastHighlighted = null, selected = null;
    public Style normalStyle, highlightStyle, selectedStyle,
        matchHighlightStyle;
    public StyleContext sc;
    public StyledDocument doc;
    public String itemSeparator = " ";

    public ActiveText() {
        sc = new StyleContext();
        makeWidget();
    }

    public ActiveText(StyleContext passed_sc) {
        sc = passed_sc;
        makeWidget();
    }

    public void makeWidget() {

        doc = new DefaultStyledDocument();
        setDocument(doc);

        // By default, flash things red when the mouse passes over them,
        // and add a yellow background when the item is selected.

        // The styles are made with submethods so they can be specialised.
        makeNormalStyle();
        makeHighlightStyle();
        makeSelectedStyle();
        makeMatchHighlightStyle();

        addMouseMotionListener(this);
        addMouseListener(this);
    }

    public void makeNormalStyle() {
        Style def = sc.getStyle(StyleContext.DEFAULT_STYLE);
        normalStyle = sc.addStyle("normal", def);
        StyleConstants.setFontFamily(normalStyle, "SansSerif");
        StyleConstants.setFontSize(normalStyle, 12);
        StyleConstants.setForeground(normalStyle, Color.black);
        StyleConstants.setLeftIndent(normalStyle, 10);
        StyleConstants.setRightIndent(normalStyle, 10);
        StyleConstants.setSpaceAbove(normalStyle, 4);
        StyleConstants.setSpaceBelow(normalStyle, 4);
    }

    public void makeHighlightStyle() {
        highlightStyle = sc.addStyle("highlight", normalStyle);
        StyleConstants.setForeground(highlightStyle, Color.red);
    }

    public void makeSelectedStyle() {
        selectedStyle = sc.addStyle("selected", normalStyle);
        StyleConstants.setUnderline(selectedStyle, true);
    }

    public void makeMatchHighlightStyle() {
        matchHighlightStyle = sc.addStyle("match", normalStyle);
        StyleConstants.setForeground(matchHighlightStyle, Color.yellow);
    }

    public void append(String s) {
        append(s, normalStyle);
    }

    public void append(String string, Style style) {
        try {
	  doc.insertString(doc.getLength(), string, style);
        } catch (BadLocationException ble) {}
    }

    // Testing whether making the background explicit transparent
    // would help.
    public Color makeTransparent(Color opaqueColor) {
        return new Color(opaqueColor.getRed(),
		     opaqueColor.getGreen(),
		     opaqueColor.getBlue(),
		     0);  // 0 means transparent, 255 means opaque
    }

    public void displayLayedData() {
        displayLayedData(lData);
    }

    public void displayLayedData(LayedData ld) {

        ld.start = doc.getLength();
        if (ld.text != null) {
	  try {
	      if (ld.normalStyle != null) {
		doc.insertString(ld.start, ld.text + itemSeparator,
			       ld.normalStyle);
	      } else {
		doc.insertString(ld.start, ld.text + itemSeparator,
			       normalStyle);
	      }
	  } catch (BadLocationException ble) {}
        }
        if (ld.children != null) {
	  for (int i = 0; i < ld.children.size(); i++) {
	      displayLayedData((LayedData)ld.children.elementAt(i));
	  }
        }
        // save the end of the run
        ld.length = doc.getLength() - ld.start;
    }

    

    // return the lowest-level LayedData element containing the given
    // offset.
    public LayedData findLayedForOffset(int off) {
        LayedData res = lData, child;
        boolean childFound = false;

        if (lData == null) return null;

        // repeatedly pick the child that contains the offset until
        // there is none.
        do {
	  childFound = false;
	  if (res.children != null) {
	      // This searches all the children even though their
	      // indices are in increasing order, but it's probably
	      // fast enough.
	      for (int i = 0;
		 childFound == false && i < res.children.size();
		 i++) {
		child = (LayedData)res.children.elementAt(i);
		if (child.start <= off &&
		    child.start + child.length >= off) {
		    res = child;
		    childFound = true;
		}
	      }
	  }
        } while (childFound == true);
        
        // If there is none found, return null rather than the whole
        // thing.
        if (res == lData) {
	  return null;
        } else {
	  return res;
        }
    }

    public void highlightMatches(String pattern) {
        int i;
        String wholeDoc;
        try {
	  wholeDoc = doc.getText(0, doc.getLength());
        } catch (BadLocationException ble) {
	  return;
        }

        for (i = 0; i < wholeDoc.length(); ) {
	  int match = wholeDoc.indexOf(pattern, i) + 1;
	  if (match == -1) break;
	  LayedData layedPlace = findLayedForOffset(match);
	  if (layedPlace != null && layedPlace.active == true) {
	      doc.setCharacterAttributes(layedPlace.start,
				   layedPlace.length,
				   matchHighlightStyle, true);
	  }
	  i = layedPlace.start + layedPlace.length + 1;
        }
    }


    // Takes a place in the document. Makes the text of the surrounding
    // LayedData object highlighted. Also makes the last highlighted
    // place normal.
    public void highlightAround(int place) {
    //System.out.println("Inside HighlightAround");
        LayedData layedPlace = findLayedForOffset(place);
        if (lastHighlighted != null) {
	  doc.setCharacterAttributes(lastHighlighted.start,
			         lastHighlighted.length,
			         normalStyle, true);
	  lastHighlighted = null;
        }
        if (layedPlace != null && layedPlace.active == true &&
	  layedPlace != selected) {
	  doc.setCharacterAttributes(layedPlace.start,
			         layedPlace.length,
			         highlightStyle, true);
	  lastHighlighted = layedPlace;
        }
    }

    public void selectAround(int place) {
    System.out.println("Inside selectAround");
        LayedData layedPlace = findLayedForOffset(place);
        if (selected != null && layedPlace != null && 
	  layedPlace.active == true) {
	  doc.setCharacterAttributes(selected.start, selected.length,
			         normalStyle, true);
	  selected = null;
        }
        if (layedPlace != null && layedPlace.active == true) {
	  doc.setCharacterAttributes(layedPlace.start, layedPlace.length,
			         selectedStyle, true);
	  selected = layedPlace;
	  if (lastHighlighted == layedPlace) {
	      lastHighlighted = null;
	  }
        }
    }

    public void removeSelection() {
        if (selected != null) {
	  doc.setCharacterAttributes(selected.start, selected.length,
			         normalStyle, true);
	  selected = null;
        }
    }

    public void actionPerformed(MouseEvent e) {
        // The default is to call the actionPerformed slot on the
        // selected item. That way, subclasses can either override the
        // method here for the whole text pane or subclass the LayedData
        // and override that.
        System.out.println("Mouse event Detected");
	if (selected != null)
	  selected.actionPerformed();
    }

    // Mouse listener stuff

    public void mouseDragged(MouseEvent e) {
    }

    public void mouseMoved(MouseEvent e) {
        Point p = e.getPoint();
        int place = viewToModel(p);
        highlightAround(place);
    }

    public void mouseClicked(MouseEvent e) {
        Point p = e.getPoint();
        int place = viewToModel(p);

        selectAround(place);
        actionPerformed(e);
    }

    public void mouseEntered(MouseEvent e) {
    }

    public void mouseExited(MouseEvent e) {
        // Kill any highlighting.
        highlightAround(-1);
    }

    public void mousePressed(MouseEvent e) {
    }

    public void mouseReleased(MouseEvent e) {
    }

}
