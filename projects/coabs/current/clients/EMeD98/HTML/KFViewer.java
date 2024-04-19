/*
 * @(#)KFViewer.java	1.7 98/02/02
 *
 * by Jihie Kim
 *
 */
package HTML;

import com.sun.java.swing.*;
import com.sun.java.swing.event.*;
import com.sun.java.swing.text.*;
import com.sun.java.accessibility.*;
import com.sun.java.swing.border.*;
import java.awt.*;
import java.net.*;
import java.io.IOException;
import java.io.FileWriter;

import java.awt.BorderLayout;
import java.awt.TextArea;
import java.awt.event.*;

import Connection.ExpectServer;

import Connection.Base64;
import java.io.*;

public class KFViewer extends JPanel implements HyperlinkListener{
  JEditorPane html;
  public final static Border loweredBorder = new SoftBevelBorder(BevelBorder.LOWERED);
  public final static Border emptyBorder10 = new EmptyBorder(10,10,10,10);
  ExpectServer es;

  static int UNAUTHORIZED = 401;

  JTextField inputField = new JTextField(20);
  JLabel inputLabel;
  JPanel inputPanel;
  JButton findButton;
  String baseLoc;
    public KFViewer(ExpectServer theServer, String baseURL, String initURL) {
      es = theServer;
      setLayout(new BorderLayout());
      baseLoc = baseURL;

      inputPanel = new JPanel();
      inputLabel = new JLabel ("concept name:");
      //inputField.setText(input);
      inputPanel.add(inputLabel,BorderLayout.WEST);
      inputPanel.add(new JScrollPane(inputField),BorderLayout.EAST);

      findButton = new JButton("Find");
      findButton.addActionListener(new findListener());
      inputPanel.add(findButton, BorderLayout.SOUTH);
      add(inputPanel, BorderLayout.SOUTH);

      getAccessibleContext().setAccessibleName("HTML panel");
      getAccessibleContext().setAccessibleDescription("A panel for viewing HTML documents, and following their links");

      String htmlString="";
      String fname="";
      if ((initURL != null) && (!initURL.equals(""))) try {
        URL url = new URL(baseURL+initURL);

	System.out.println(" connect? : "+baseURL+initURL);
	HttpURLConnection c = (HttpURLConnection) url.openConnection();
	String auth_data = "Basic " +Base64.Base64EncodeString("hpkb:hpkb411");
	c.setRequestProperty("Authorization",auth_data);
	if (c.getResponseCode() == UNAUTHORIZED) {
	  System.out.println(" Unauthorized access");
	}      
	else {
	  InputStream raw = c.getInputStream();
	  BufferedReader inStream = new BufferedReader(new InputStreamReader(raw));
	  System.out.println(c.getContentType());
	  String inputLine;
	 
	  while(true) {
	    inputLine = inStream.readLine();
	    if(inputLine==null){break;}
	    inputLine = inputLine + "\n";
	    htmlString = htmlString + inputLine;
	  }
	  try { 
	    fname = "/nfs/v2/jihie/expect/EMeD/Client/kf.html";
	    FileWriter fw = new FileWriter(fname);
	    fw.write(htmlString);
	    fw.close();
	  }
	  catch (IOException ioe) {
	    System.out.println("failed to open file:"+fname);
	  }
	}

        html = new JEditorPane("file:"+fname);
        html.setEditable(false);
        html.addHyperlinkListener(this);
        JScrollPane scroller = new JScrollPane();
        scroller.setBorder(loweredBorder);
        JViewport vp = scroller.getViewport();
        vp.add(html);
        vp.setBackingStoreEnabled(true);
        add(scroller, BorderLayout.CENTER);
      } catch (MalformedURLException e) {
        System.out.println("Malformed URL: " + e);
      } catch (IOException e) {
        System.out.println("IOException: " + e);
      }
	
    }

    /**
     * Notification of a change relative to a 
     * hyperlink.
     */
  
    public void hyperlinkUpdate(HyperlinkEvent e) {
	if (e.getEventType() == HyperlinkEvent.EventType.ACTIVATED) {
	    linkActivated(e.getURL());
	}
    }

    /**
     * Follows the reference in an
     * link.  The given url is the requested reference.
     * By default this calls <a href="#setPage">setPage</a>,
     * and if an exception is thrown the original previous
     * document is restored and a beep sounded.  If an 
     * attempt was made to follow a link, but it represented
     * a malformed url, this method will be called with a
     * null argument.
     *
     * @param u the URL to follow
     */
    protected void linkActivated(URL u) {
	Cursor c = html.getCursor();
	Cursor waitCursor = Cursor.getPredefinedCursor(Cursor.WAIT_CURSOR);
	html.setCursor(waitCursor);
	SwingUtilities.invokeLater(new PageLoader(u, c));
    }

    /**
     * temporary class that loads synchronously (although
     * later than the request so that a cursor change
     * can be done).
     */
  
    class PageLoader implements Runnable {
	
	PageLoader(URL u, Cursor c) {
	    url = u;
	    cursor = c;
	}

      private boolean putInfo (URL u) {
        String fname;



        int idx = u.toString().lastIndexOf("/");
        if (idx >= 0) fname = url.toString().substring(idx+1); // get file name
        else fname = url.toString();

        idx = fname.lastIndexOf(".");
        if (idx < 0) {
	System.out.println("unrecognized file name");
	return false;
        }
        else {
	String type = fname.substring(idx+1);
	String name = fname.substring(0,idx);
	String htmlString;

	if (type.equals("concept")) {
	  conceptRenderer defRenderer = new conceptRenderer();
	  System.out.println("xml:"+es.getConceptInfo(name));
	  htmlString = defRenderer.toHtml(es.getConceptInfo(name));
	}
	/*	else if (type.equals("relation")) {
	  relationRenderer defRenderer = new relationRenderer();
	  htmlString = defRenderer.toHtml(es.getRelationInfo(name));
	}
	else if (type.equals("instance")) {
	  instanceRenderer defRenderer = new instanceRenderer();
	  htmlString = defRenderer.toHtml(es.getInstanceInfo(name));
	}
	else if (type.equals("method")) {
	  methodRenderer defRenderer = new methodRenderer();
	  htmlString = defRenderer.toHtml(es.getMethodInfo(name));
	}
	else if (type.equals("ps-node")) {
	  PSNodeRenderer defRenderer = new PSNodeRenderer();
	  htmlString = defRenderer.toHtml(es.getPSNode(name));
	}
	else if (type.equals("exe-node")) {
	  EXENodeRenderer defRenderer = new EXENodeRenderer();
	  htmlString = defRenderer.toHtml(es.getEXENode(name));
	  }*/
	else return false;
	
	
	try {
	  FileWriter fw = new FileWriter(fname);
	  fw.write(htmlString);
	  fw.close();
	}
	catch (IOException ioe) {
	  System.out.println("failed to open file:"+fname);
	}
	System.out.println("wrote file:"+fname);
	return true;
        }
      }


      public void run() {
        if (url == null) {
	// restore the original cursor
	html.setCursor(cursor);

	// PENDING(prinz) remove this hack when 
	// automatic validation is activated.
	Container parent = html.getParent();
	parent.repaint();
        } else { 
	Document doc = html.getDocument();
	try {
	  System.out.println("document:"+doc.getText(0,doc.getLength()));
	}
	catch (BadLocationException e) {
	  System.out.println("bad location for document");
	}
	putInfo (url);
	try {
	  html.setPage(url);
	} catch (IOException ioe) {
	  html.setDocument(doc);
	  getToolkit().beep();
	  System.out.println("cannot set page for "+url.toString());
	} finally {
	  // schedule the cursor to revert after
	  // the paint has happended.
	  url = null;
	  SwingUtilities.invokeLater(this);
	}
        }
      }

      URL url;
      Cursor cursor;
    }
  
  
  class findListener implements ActionListener {
    public void actionPerformed(ActionEvent e) {   
      find();
    }
  }
  
  private void find() {

    String input = inputField.getText();
    //conceptRenderer defRenderer = new conceptRenderer();
    //htmlString = defRenderer.toHtml(es.getConceptInfo(input));
    try {
      URL url = new URL(baseLoc+input.trim().toUpperCase()+".concept");
      /*if (null==html) {
	putInfo(url);
	System.out.println("put info for url" +url.toString());
	html = new JEditorPane(url);
        html.setEditable(false);
        html.addHyperlinkListener(this);
        JScrollPane scroller = new JScrollPane();
        scroller.setBorder(loweredBorder);
        JViewport vp = scroller.getViewport();
        vp.add(html);
        vp.setBackingStoreEnabled(true);
        add(scroller, BorderLayout.CENTER);
      }
      else */ linkActivated(url);
    } catch (MalformedURLException e) {
      System.out.println("Malformed URL: " + e);
    }  catch (IOException e) {
      System.out.println("IOException: " + e);
    }
  }

  
  public static void main(String[] args) { 
    ExpectServer es = new ExpectServer();

    //JPanel tpanel = new KFViewer(es,"http://www.alphatech.com/protected/hpkb/ikd/sources/Knowledge_Fragments/","KF_7.html");
    JPanel tpanel = new KFViewer(es,"http://www.alphatech.com/protected/hpkb/ikd/sources/Knowledge_Fragments/","KF_7.html#713.1");


    JFrame frame = new JFrame("Expect HTML Panel");
     frame.addWindowListener(new WindowAdapter() {
        public void windowClosing(WindowEvent e) {
                  System.exit(0);
        }
      });
     frame.getContentPane().add(tpanel);
     frame.setSize(700, 500);
     frame.setVisible(true);

  }
}
