/*
 * by Jihie Kim
 *
 */
package editor;
import javax.swing.*;
import java.awt.*;
class editListCellRenderer extends JLabel implements ListCellRenderer {
     public editListCellRenderer() {
         setOpaque(true);
     }
     public Component getListCellRendererComponent(
         JList list, 
         Object value, 
         int index, 
         boolean isSelected, 
         boolean cellHasFocus) 
     {
         setText(value.toString());
         setBackground(isSelected ? Color.red : Color.white);
         setForeground(isSelected ? Color.white : Color.black);
         return this;
     }
 }
 
