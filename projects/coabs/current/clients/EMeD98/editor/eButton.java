// 
// Jihie Kim, 1999
// 
package editor;

import com.sun.java.swing.JButton;
import java.awt.Insets;

public class eButton extends JButton {
  String idx = "";
  int source = -1;
  boolean forDisplayOnly = false;
  public eButton (String text) {
    super (text);
    setMargin(new Insets(0,0,0,0));
  }
  public eButton (String text, int i) {
    super (text);
    setMargin(new Insets(0,0,0,0));
    source = i;
  }
  public eButton (String text, String index) {
    super (text);
    setMargin(new Insets(0,0,0,0));
    idx = index;
  }
  public eButton (String text, String index, int i) {
    super (text);
    setMargin(new Insets(0,0,0,0));
    idx = index;
    source = i;
  }
  public eButton (String text, boolean displayOnly) {
    super (text);
    setMargin(new Insets(0,0,0,0));
    if (displayOnly) setBorderPainted(false);
    forDisplayOnly = displayOnly;
  }
  public eButton (String text, boolean displayOnly, String index) {
    super (text);
    setMargin(new Insets(0,0,0,0));
    if (displayOnly) setBorderPainted(false);
    forDisplayOnly = displayOnly;
    idx = index;
  }
  public String getIndex () {
    return idx;
  }  
  public void setIndex (String index) {
    idx = index;
  }
  public int getSource () {
    return source;
  }
  public void setSource(int s) {
    source = s;
  }
  public boolean forDisplayOnly () {
    return forDisplayOnly;
  }
}
