import netscape.javascript.*;
import java.lang.*;
import java.applet.*;
import java.awt.Graphics;

public class array extends Applet{

        String testStr;
        Integer testInt;  /*integer */
        Character testChar; /*character*/
        JSObject win;

        public void init(){
                win = JSObject.getWindow(this);
        }

        void create(){
            Object testArray[]; /*array to hold int, char and string*/

            testArray = new Object[3];

            testStr = new String("Test string");
            testInt = new Integer(1);
            testChar = new Character('a');


            testArray[0] = testStr; /*assign array elements*/
            testArray[1] = testInt;
            testArray[2] = testChar;

            win.call("extractArray", testArray);  /*pass the arguments to JS*/
        }

        public void paint(Graphics g){
            g.drawString("Here's an Applet which will " +
                             "deliver an array of Objects to " +
                             "Javascript on clicking the button", 50, 25);
        }
}

