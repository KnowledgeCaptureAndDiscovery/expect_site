/*  
 * Client.java  7/14/98
 */

/*
 * Main program for client: 
 * @author Jihie Kim
 */
package Connection;

import java.lang.*;
import java.io.*;
import java.util.*;
import java.net.*;
import java.lang.Boolean;

public class Client {
  public Client() {
      
  }
    public static void main(String[] args) {
      PrintStream o = System.err;

      String output ="";
      ExpectServer server = new ExpectServer();

      output = server.getMethodInfo("narrow-gap");
      o.print("\n*******results is: " + output+"\n*****\n   ");

      //output = server.getConceptInfo("thing");
      //o.print("\n*******results is: " + output+"\n*****\n   ");

      output = server.getSearchInfo("gap","any","T","F","");
      o.print("\n*******results is: " + output+"\n*****\n   ");

      output = server.summarizeKB();
      o.print("\n*******results is: " + output+"\n*****\n   ");

      output = server.listKBs();
      o.print("\n*******results is: " + output+"\n*****\n   ");

      //output = server.createKB("jihie2");
      //o.print("\n*******results is: " + output+"\n*****\n   ");

      //output = server.getPSNode("ps-en1");
      //o.print("\n*******results is: " + output+"\n*****\n   ");

      //output = server.getEXENode("exe-en1");
      // o.print("\n*******results is: " + output+"\n*****\n   ");

      // output = server.getInstancesInfo("workaround-step");
      //o.print("\n*******results is: " + output+"\n*****\n   ");
     
      // output = server.checkMethod("((name emplace-mgb-step) (capability (estimate (obj (?t is (spec-of time)))                     (for (?s is (inst-of emplace-mgb))))) (result-type (inst-of number))  (method (find (obj (spec-of time-for-emplacement))	       (for (bridge-of ?q)))) )");
      //o.print("\n*******results is: " + output+"\n*****\n   ");

      // output = server.getTree("concept");
      // o.print("\n*******results is: " + output+"\n*****\n   ");

       output = server.getInstanceInfo("mgb1");
       o.print("\n*******results is: " + output+"\n*****\n   ");

    }

    
}
