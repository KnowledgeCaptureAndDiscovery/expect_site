import java.awt.*;
import java.awt.event.*;
import javax.swing.*;

/** @author ges */

public class testPanel extends JFrame {
    protected JMenuBar menuBar;

    public testPanel() {
        super("MenuLayoutDemo");
        menuBar = new JMenuBar();
        menuBar.setLayout(new BoxLayout(menuBar, BoxLayout.Y_AXIS));
        addNewMenu("Menu 1");
        addNewMenu("Menu 2");
        addNewMenu("Menu 3");
        getContentPane().add(menuBar, BorderLayout.WEST);

        addWindowListener(new WindowAdapter() {
            public void windowClosing(WindowEvent e) {
                System.exit(0);
            }
        });
    }

    public void addNewMenu(String title) {
        JMenu m = (JMenu)menuBar.add(new HorizontalMenu(title));
        m.add("Menu item");
        m.add("Menu item");
        m.add("Menu item");
        JMenu m1 = (JMenu)m.add(new HorizontalMenu("Submenu"));
        m1.add("Submenu item");
        m1.add("Submenu item");
    }

    public static void main(String args[]) {
        testPanel f = new testPanel();
        f.pack();
        f.setVisible(true);
    }

    class HorizontalMenu extends JMenu {
        HorizontalMenu(String label) {
            super(label);
            JPopupMenu pm = getPopupMenu();
            pm.setLayout(new BoxLayout(pm, BoxLayout.X_AXIS));
            setMinimumSize(getPreferredSize());
        }
        
        public void setPopupMenuVisible(boolean b) {
            boolean isVisible = isPopupMenuVisible();
            if (b != isVisible) {
                if ((b==true) && isShowing()) {
                    // Set location of popupMenu (pulldown or pullright)
                    // Perhaps this should be dictated by L&F
                    int x = 0;
                    int y = 0;
                    Container parent = getParent();
                    if (parent instanceof JPopupMenu) {
                        x = 0;
                        y = getHeight();
                    } else {
                        x = getWidth();
                        y = 0;
                    }
                    getPopupMenu().show(this, x, y);
                } else {
                    getPopupMenu().setVisible(false);
                }
            }
        }
    }
}
