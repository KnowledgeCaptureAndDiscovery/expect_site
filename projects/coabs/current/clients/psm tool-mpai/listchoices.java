//Mahindra B. Pai (mpai@usc.edu)

import java.awt.*;

public class ListChoices extends Frame implements ResultProcessor
{  
   // routine
   private void add(Component c, GridBagLayout gbl, GridBagConstraints gbc,
      int x, int y, int w, int h)
   {  gbc.gridx = x;
      gbc.gridy = y;
      gbc.gridwidth = w;
      gbc.gridheight = h;
      gbl.setConstraints(c, gbc);
      add(c);
   }

   public java.util.Vector options;

   // constructor
   public ListChoices(java.util.Vector vectorChoices)
   {  
      System.out.println("In ListChoices constructor");

      //copy the reference to the parameter passed so that modifications
      // to the parameter reflect in the callee 
      options = vectorChoices;
      
      // convert the vector parameter to an awt list
      java.awt.List choices = new java.awt.List();
      for(int i=0; i< options.size(); i++)
	  choices.add(options.get(i).toString());

      //Create the layout of the frame
      setTitle("List of Choices");
      GridBagLayout gbl = new GridBagLayout();
      setLayout(gbl);
      
      //  the instructions for the users
      statement = new ListCanvas();

      // this panel contains the buttons for confirming the actions of the user
      Panel pButton = new Panel();
      pButton.setLayout(new GridLayout(1, 3));
      pButton.add(new Button("New"));
      pButton.add(new Button("Done"));
      pButton.add(new Button("Cancel"));
      
      GridBagConstraints gbc = new GridBagConstraints();

      gbc.fill = GridBagConstraints.BOTH;
      gbc.anchor = GridBagConstraints.CENTER;
      gbc.weightx = 100;
      gbc.weighty = 10;
      add(statement, gbl, gbc, 0, 0, 2, 1);
      
      gbc.fill = GridBagConstraints.BOTH;
      gbc.anchor = GridBagConstraints.NORTH;
      add(choices, gbl, gbc, 0, 1, 2, 4);
      
      gbc.fill = GridBagConstraints.NONE;
      gbc.anchor = GridBagConstraints.CENTER;
      add(pButton, gbl, gbc, 0, 5, 2, 1);
   }
   
   // routine 
   public boolean handleEvent(Event evt)
   {  
      if (evt.id == Event.LIST_SELECT || evt.id == Event.LIST_DESELECT)
      {  
         if (evt.target.equals(choices))
         {
            statement.setAttributes(choices.getSelectedItems());
         }
      }
      else if (evt.id == Event.WINDOW_DESTROY && evt.target == this)
      {
         System.exit(0);
      }
      else 
      {
         return super.handleEvent(evt);
      }
      return true;
   }

   // routine    
   public boolean action(Event evt, Object arg)
   {
      NewEntryInfo info = new NewEntryInfo("Enter Data here.");
     
      if(arg.equals("New"))
      {
         NewEntryDialog pDialog = new NewEntryDialog(this, info);
         pDialog.show();
      }
      else if(arg.equals("Done"))
      {  
         choices.add(info.newname);    
	 options.addElement(info.newname);
      }
      else if(arg.equals("Cancel"))
      {
         return true;
      }
      else
      {
         return super.action(evt, arg);
      }
      return true;
   }

   // routine 
   public void processResult(Dialog source, Object result)
   {  
      if (source instanceof NewEntryDialog)
      {  
         NewEntryInfo info = (NewEntryInfo)result;
         System.out.println("In processResult" + info.newname);
         choices.addItem(info.newname);
	 options.addElement(info.newname);
         System.out.println(info.newname);  
      }
   }
   
   ListCanvas statement;
   List choices;
   
   //main routine from where the appplication begins
   //public static void main(String[] args)
   //{  
   //   Frame f = new ListChoices();
   //   f.resize(300, 300);
   //   f.show();  
   //}
}

class ListCanvas extends Canvas
{  
   // constructor
   public ListCanvas() 
   {  
      setAttributes(new String[0]); 
   }

   // routine    
   public void setAttributes(String[] w)
   {  
      text = "\nYou have chosen the following";
      for (int i = 0; i < w.length; i++)
         text += w[i] + "\n";
      repaint();
   }
   
   // routine 
   public void paint(Graphics g)
   {  
      g.drawString(text, 0, 30);
      g.drawString("Please choose from the list below.", 0, 15);
   }
   
   private String text;
}

interface ResultProcessor
{  
   public void processResult(Dialog source, Object obj);
}

class NewEntryInfo
{  
   public String newname;

   // constructor
   public NewEntryInfo(String name) 
   { 
      newname = name;
   }
}   
                        
class NewEntryDialog extends Dialog
{  

   // constructor
   public NewEntryDialog(ListChoices parent, NewEntryInfo name)
   {  
      super(parent, "NewEntry", true);         

      Panel p1 = new Panel();
      p1.setLayout(new GridLayout(1, 1));
      p1.add(new Label("Name of New Entry : "));
      p1.add(newname = new TextField(name.newname, 25));
      add("Center", p1);
      
      Panel p2 = new Panel();
      p2.add(new Button("Ok"));
      p2.add(new Button("Cancel"));
      add("South", p2);
      resize(240, 120);
   }

   // routine 
   public boolean action(Event evt, Object arg)
   {  
      if(arg.equals("Ok"))
      {  
         dispose();
         ((ResultProcessor)getParent()).processResult(this, 
               new NewEntryInfo(newname.getText())); 
      }
      else if (arg.equals("Cancel"))
      {
         dispose();
      }
      else 
      {
         return super.action(evt, arg);
      }
      return true;
   }
        
   // routine 
   public boolean handleEvent(Event evt)
   {  
      if (evt.id == Event.WINDOW_DESTROY)
      {
         dispose();
      }
      else 
      {
         return super.handleEvent(evt);
      }
      return true;
   }

   private TextField newname;
}
