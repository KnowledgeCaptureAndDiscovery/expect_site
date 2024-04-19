package PSTree;

import java.awt.Color;
import java.util.Vector;

public class GRObject extends Object {
  private String content="";
  private boolean expand= true;
  private Color objectColor = Color.black;

  public GRObject (String contentValue, boolean expandValue, Color colorValue) {
    super();
    content = contentValue;
    expand = expandValue;
    objectColor = colorValue;
  }
  public GRObject (String contentValue) {
    super();
    content = contentValue;
  }
  public GRObject () {
    super();
  }

  public String getContent () {
    return content;
  }
  public void setContent (String contentValue) {
    content = contentValue;
  }

  public Color getColor () {
    return objectColor;
  }
  public void setColor (Color colorValue) {
    objectColor = colorValue;
  }
  public boolean getExpand () {
    return expand;
  }
  public void setExpand (boolean expandValue) {
    expand = expandValue;
  }

}
