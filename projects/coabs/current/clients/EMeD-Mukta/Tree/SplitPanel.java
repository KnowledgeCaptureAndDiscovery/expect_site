/*
 * @(#)SplitPanel.java	1.9 98/02/02
 *
 * Copyright (c) 1997 Sun Microsystems, Inc. All Rights Reserved.
 *
 * This software is the confidential and proprietary information of Sun
 * Microsystems, Inc. ("Confidential Information").  You shall not
 * disclose such Confidential Information and shall use it only in
 * accordance with the terms of the license agreement you entered into
 * with Sun.
 *
 * SUN MAKES NO REPRESENTATIONS OR WARRANTIES ABOUT THE SUITABILITY OF THE
 * SOFTWARE, EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
 * PURPOSE, OR NON-INFRINGEMENT. SUN SHALL NOT BE LIABLE FOR ANY DAMAGES
 * SUFFERED BY LICENSEE AS A RESULT OF USING, MODIFYING OR DISTRIBUTING
 * THIS SOFTWARE OR ITS DERIVATIVES.
 *
 */

import javax.swing.*;
import javax.swing.event.*;
import javax.accessibility.*;

import java.awt.*;
import java.awt.event.*;

/*
 * An example of using a JSplitPane. The key thing to remember about using
 * a JSplitPane is that it used the minimum size to determine where the
 * components can be resize to! Some of the components in swing will return
 * the current size as the minimum size, meaning JSplitPane will not allow
 * you to resize it. Luckily JComponent has methods for setting the
 * preferred/min sizes.
 *
 * @version 1.9 02/02/98
 * @author Scott Violet
 * @author Peter Korn (accessibility support)
 */
public class SplitPanel extends JPanel
{
    /** JSplitPane being shown to the user. */
    protected JSplitPane             splitPane;
    /** Left component being split. */
    protected GridComponent          leftGrid;
    /** Right component being split. */
    protected GridComponent          rightGrid;

    public SplitPanel() {
	super();
	setDoubleBuffered(true);
	setLayout(new BorderLayout());
	createSplitPane();
	createInformationControls();
    }

    /**
     * Creates the JSplitPane.
     */
    protected void createSplitPane() {
	leftGrid = new GridComponent(4);
	leftGrid.setPreferredSize(10);
	rightGrid = new GridComponent(4);
	rightGrid.setPreferredSize(10);
	splitPane = new JSplitPane(JSplitPane.HORIZONTAL_SPLIT, leftGrid,
				   rightGrid);
	splitPane.setContinuousLayout(true);
	splitPane.setPreferredSize(new Dimension(400, 100));
	splitPane.getAccessibleContext().setAccessibleName("Split pane example");
	add(splitPane, BorderLayout.CENTER);
    }

    /**
     * Creates controls to alter the JSplitPane.
     */
    protected void createInformationControls() {
	JPanel                wrapper = new JPanel();
	ButtonGroup           group = new ButtonGroup();
	JRadioButton          button;

	Box                   buttonWrapper = new Box(BoxLayout.X_AXIS);

	wrapper.setLayout(new GridLayout(0, 1));

	/* Create a radio button to vertically split the split pane. */
	button = new JRadioButton("Vertically split");
	button.setMnemonic('V');
	button.addActionListener(new ActionListener() {
	    public void actionPerformed(ActionEvent e) {
		splitPane.setOrientation(JSplitPane.VERTICAL_SPLIT);
	    }
	});
	group.add(button);
	buttonWrapper.add(button);

	/* Create a radio button the horizontally split the split pane. */
	button = new JRadioButton("Horizontally split");
	button.setMnemonic('r');
	button.setSelected(true);
	button.addActionListener(new ActionListener() {
	    public void actionPerformed(ActionEvent e) {
		splitPane.setOrientation(JSplitPane.HORIZONTAL_SPLIT);
	    }
	});
	group.add(button);
	buttonWrapper.add(button);

	/* Create a check box as to whether or not the split pane continually
	   lays out the component when dragging. */
	JCheckBox checkBox = new JCheckBox("Continuous Layout");
	checkBox.setMnemonic('C');
	checkBox.setSelected(true);

	checkBox.addChangeListener(new ChangeListener() {
	    public void stateChanged(ChangeEvent e) {
		splitPane.setContinuousLayout(((JCheckBox)e.getSource()).isSelected());
	    }
	});
	buttonWrapper.add(checkBox);
	wrapper.add(buttonWrapper);

	/* Create a text field to change the divider size. */
	Box                      tfWrapper;
	JTextField               tf;
	JLabel                   label;

	tf = new JTextField();
        tf.setText(new Integer(splitPane.getDividerSize()).toString());
	tf.setColumns(5);
	tf.getAccessibleContext().setAccessibleName("Divider Size");
	tf.addActionListener(new ActionListener() {
	    public void actionPerformed(ActionEvent e) {
		String           value = ((JTextField)e.getSource()).getText();
		int              newSize;

		try {
		    newSize = Integer.parseInt(value);
		} catch (Exception ex) {
		    newSize = -1;
		}
		if(newSize > 0)
		    splitPane.setDividerSize(newSize);
		else
		    JOptionPane.showMessageDialog(splitPane, "Invalid Divider Size", "Error", JOptionPane.ERROR_MESSAGE);
	    }
	});
	label = new JLabel("Divider Size");
	tfWrapper = new Box(BoxLayout.X_AXIS);
	tfWrapper.add(label);
	tfWrapper.add(Box.createHorizontalStrut(10));
	tfWrapper.add(tf);
        label.setLabelFor(tf);
	label.setDisplayedMnemonic('z');
	tfWrapper.add(Box.createHorizontalStrut(Short.MAX_VALUE));
	wrapper.add(tfWrapper);

	/* Create a text field that will change the preferred/minimum size
	   of the left component. */
	tf = new JTextField(String.valueOf(leftGrid.getPreferredSize().width));
	tf.setColumns(5);
	tf.getAccessibleContext().setAccessibleName("First Component minimum size");
	tf.addActionListener(new ActionListener() {
	    public void actionPerformed(ActionEvent e) {
		String           value = ((JTextField)e.getSource()).getText();
		int              newSize;

		try {
		    newSize = Integer.parseInt(value);
		} catch (Exception ex) {
		    newSize = -1;
		}
		if(newSize > 10)
		    leftGrid.setPreferredSize(newSize);
		else
		    JOptionPane.showMessageDialog(splitPane, "Invalid Minimum Size, must be greater than 10", "Error", JOptionPane.ERROR_MESSAGE);
	    }
	});
	label = new JLabel("First Components Minimum Size");
	tfWrapper = new Box(BoxLayout.X_AXIS);
	tfWrapper.add(label);
	tfWrapper.add(Box.createHorizontalStrut(10));
	tfWrapper.add(tf);
	tfWrapper.add(Box.createHorizontalStrut(Short.MAX_VALUE));
        label.setLabelFor(tf);
	label.setDisplayedMnemonic('i');
	wrapper.add(tfWrapper);
	
	/* Create a text field that will change the preferred/minimum size
	   of the right component. */
	tf = new JTextField(String.valueOf(rightGrid.getPreferredSize().
					   width));
	tf.setColumns(5);
	tf.getAccessibleContext().setAccessibleName("Second Component minimum size");
	tf.addActionListener(new ActionListener() {
	    public void actionPerformed(ActionEvent e) {
		String           value = ((JTextField)e.getSource()).getText();
		int              newSize;

		try {
		    newSize = Integer.parseInt(value);
		} catch (Exception ex) {
		    newSize = -1;
		}
		if(newSize > 10)
		    rightGrid.setPreferredSize(newSize);
		else
		    JOptionPane.showMessageDialog(splitPane, "Invalid Minimum Size, must be greater than 10", "Error", JOptionPane.ERROR_MESSAGE);
	    }
	});
	label = new JLabel("Second Components Minimum Size");
	tfWrapper = new Box(BoxLayout.X_AXIS);
	tfWrapper.add(label);
	tfWrapper.add(Box.createHorizontalStrut(10));
	tfWrapper.add(tf);
	tfWrapper.add(Box.createHorizontalStrut(Short.MAX_VALUE));
        label.setLabelFor(tf);
	label.setDisplayedMnemonic('n');
	wrapper.add(tfWrapper);

	add(wrapper, BorderLayout.SOUTH);
    }
}

class GridComponent extends Component
{
    /** Number of grids to show. */
    protected int            gridCount;
    /** Size of each grid. */
    protected int            gridSize;
    /** Color for lines. */
    protected Color          currentColor;
    /** Preferred size. */
    protected int            preferredSize;

    public GridComponent(int gridCount) {
	this.gridCount = gridCount;
	gridSize = 10;
	currentColor = Color.lightGray;
    }

    /**
     * Sets the preferred size to value.
     */
    public void setPreferredSize(int value) {
	preferredSize = value;
    }

    /**
     * Returns the preferred size, which is the value of setPreferredSize
     * as a Dimension.
     */
    public Dimension getPreferredSize() {
	return new Dimension(preferredSize, preferredSize);
    }

    /**
     * Returns the minimum size. JSplitPane keys of the minimum size to
     * determine where the divider can drag to. If the minimum size of the
     * two components being split are greater than the current size of the
     * splitpane, the splitpane will not allow you to drag the divider 
     * around.
     */
    public Dimension getMinimumSize() {
	return getPreferredSize();
    }

    /**
     * Resets the <code>currentColor</code> and messages super.
     */
    public void setBounds(int x, int y, int width, int height) {
	int          minSize = Math.min(width, height);

	if(minSize < 100)
	    currentColor = Color.red;
	else if(minSize < 200)
	    currentColor = Color.blue;
	else if(minSize < 300)
	    currentColor = Color.yellow;
	else
	    currentColor = Color.white;

	gridSize = Math.max(1, minSize / gridCount);

	super.setBounds(x, y, width, height);
    }

    /**
     * Paints the grid.
     */
    public void paint(Graphics g) {
	Rectangle        paintBounds = g.getClipBounds();

	// g.setColor(Color.lightGray);
	// g.fillRect(paintBounds.x, paintBounds.y, paintBounds.width,
	// 	   paintBounds.height);
	if(gridSize > 0) {
	    g.setColor(currentColor);

	    int              maxY = paintBounds.y + paintBounds.height;
	    int              maxX = paintBounds.x + paintBounds.width;
	    int              drawMinY = paintBounds.y / gridSize * gridSize;
	    int              drawMaxY = maxY / gridSize * gridSize;
	    int              drawMinX = paintBounds.x / gridSize * gridSize;
	    int              drawMaxX = maxX / gridSize * gridSize;
	    int              counter;

	    for(counter = drawMinX; counter <= drawMaxX; counter += gridSize)
		g.drawLine(counter, paintBounds.y, counter, maxY);
	    for(counter = drawMinY; counter <= drawMaxY; counter += gridSize)
		g.drawLine(paintBounds.x, counter, maxX, counter);
	}
    }
   public static void main(String[] args) {
      JFrame frame = new JFrame("split panel test Frame");
      frame.addWindowListener(new WindowAdapter() {
        public void windowClosing(WindowEvent e) {
                  System.exit(0);
        }
      });
      
      frame.getContentPane().add("Center", new SplitPanel(es));
      frame.setSize(400, 500);
      frame.setVisible(true);
    }
}
