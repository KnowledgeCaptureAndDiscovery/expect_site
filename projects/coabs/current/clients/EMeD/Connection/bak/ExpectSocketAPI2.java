// Socket Interface to Lisp EXPECT Backend

// Author: Hans Chalupsky
// modified by Jihie Kim

package Connection;

import java.io.*;
import java.net.*;

// TO DO:
// - need to send PowerLoom expressions as strings, so case-sensitive reading
//   will work properly - need to esacpe strings with new Emacs utiltiy.

public class ExpectSocketAPI extends ExpectConnect {
  static boolean debug = false;
  String defaultPackage = "EXPECT";

  Socket serverSocket;
  PrintStream outStream;
  BufferedReader inStream;
  PrintStream o = System.err;

  String machineName;
  String portNumber;
  String authData;
 
  static String terminator = "}";

  public ExpectSocketAPI () {
    createConnectionDialog();
    activateConnectionDialog();
    machineName=machineNameField.getText();
    portNumber=portNumberField.getText();
    try {
      openServerConnection(machineName, Integer.parseInt(portNumber));
    }
    catch (NumberFormatException e) {
      o.println("invalid port number description:"+portNumber);
    }
    catch (FactoryException e2) {
      o.println("Problem: " + e2.getMessage() + "\n");
    }
  }

    void openServerConnection(String serverHost, int serverPort) throws FactoryException {
        if (serverSocket != null)
            return;
        try {
            serverSocket = new Socket(serverHost, serverPort);
            inStream = new BufferedReader
                (new InputStreamReader(serverSocket.getInputStream()));
            outStream = new PrintStream(serverSocket.getOutputStream(), true);
            //outStream.println(":lisp-server\n\"Lisp Server\"42");
            //outStream.println("(:terminator \"" + terminator + "\")");
            //inStream.readLine();
            //inStream.readLine();
        }
        catch ( UnknownHostException e ) {
            throw new FactoryException
                ("Unknown Lisp server host",
                 "Unknown Lisp server host `"
                 + serverHost + ":" + serverPort + "'");
	}
        catch ( IOException e ) {
            throw new FactoryException
                ("Lisp server host connection failure",
                 "Can't connect to Lisp server host `"
                 + serverHost + ":" + serverPort + "'");
	}
    }
        
    public void closeServerConnection() {
        if (serverSocket != null) {
            // outStream.println("(:close)");
            // readLispResult();
            try {serverSocket.close();}
            catch ( IOException e ) {}
            serverSocket = null;
        }
    }

    void sendLispCommand(String command) {
      //System.out.println("send command:"+command);
      outStream.println(command);
      //outStream.println("(:eval " + command + ")");
    }

  StringBuffer delete (StringBuffer in, int i1, int i2) {
    String input = in.toString();
    String current = input.substring(0,i1)+input.substring(i2);
    return new StringBuffer(current);
  }
  StringBuffer deleteCharAt (StringBuffer in, int i1) {
    String input = in.toString();
    String current = input.substring(0,i1)+input.substring(i1+1);
    return new StringBuffer(current);
  }

  public String readLispResult() throws FactoryException {
      StringBuffer result = new StringBuffer();
      String line;
      boolean isError = false;
      boolean firstLine = true;
      try {
	line = inStream.readLine();
	//System.out.println("<< |" + line+"|");
           
	                                    
	line = inStream.readLine();
	//System.out.println("<< " + line+"|");
	while (!line.equals(terminator)) {
	  if (line.equals("")) {
	    line = inStream.readLine(); // skip blank lines
	    continue;
	  }
	  if (!firstLine) 
	    result.append("\n");
	  else firstLine = false;
	  result.append(line);
	  line = inStream.readLine();
	  //System.out.println("<< |" + line+"|");
	}
      }
      catch ( IOException e ) {
	throw new FactoryException
	  ("Lisp result read error",
	   "Error reading Lisp evaluation result.");
      }
       
      return(result.toString());
        
  }
 

    public String evaluateLispCommand (String command) throws FactoryException {
        return evaluateLispCommand(command, "CL-USER");
    }

    public String evaluateLispCommand (String command, String lispPackage) {
        String result = null;

        if (serverSocket != null) {
	  try {
            //sendLispCommand("(CL:IN-PACKAGE \"" + lispPackage + "\")");
            //readLispResult();
            sendLispCommand(command+"$");
            result = readLispResult();
	  }
	  catch (FactoryException e2) {
	    o.println("Error in evaluating command:"+command);
	    o.println("Problem: " + e2.getMessage() + "\n");
	  }
        }
        return result;
    }

  /*************************************************************
   set of Lisp APIs
  **************************************************************/
  public String LoadKB(String KBname) {
    return evaluateLispCommand("(load-expect-kb \""+KBname+"\")",
			defaultPackage);
  }
  public String SaveKB(String KBname) {
    return evaluateLispCommand("(save-expect-kb \""+KBname+"\")",
			defaultPackage);
  }
  public String CreateKB(String KBname) {
    return evaluateLispCommand("(create-kb \""+KBname+"\")",
			defaultPackage);
  }
  public String summarizeKB(String KBname) {
    return evaluateLispCommand("(summarize-kb \""+KBname+"\")",
			defaultPackage);
  }
  public String listKBs () {
    return evaluateLispCommand("(list-kbs)",
			defaultPackage);
  }
  public String setTopGoal (String goal) {
    return evaluateLispCommand("(set-kb-top-level-goal \""+goal+"\")",
			defaultPackage);
  }
  public String getTopGoal () {
    return evaluateLispCommand("(generate-top-level-goal)",
			defaultPackage);
  }
  public String solveGoal () {
    return evaluateLispCommand("(solve-top-level-goal)",
			defaultPackage);
  }
  public String setTopProblem (String problem) {
    return evaluateLispCommand("(set-kb-top-level-problem \""+problem+"\")",
			defaultPackage);
  }
  public String getTopProblem (String problem) {
    return evaluateLispCommand("(generate-top-level-problem)",
			defaultPackage);
  }
  public String solveProblem () {
    return evaluateLispCommand("(solve-top-level-problem)",
			defaultPackage);
  }

  public String getConceptInfo (String name) {
    return evaluateLispCommand("(generate-xml-concept-description \""+name+"\")",
			defaultPackage);
  }
  public String getRelationInfo (String name) {
    return evaluateLispCommand("(generate-xml-relation-description \""+name+"\")",
			defaultPackage);
  }
  public String getInstanceInfo (String name) {
    return evaluateLispCommand("(generate-xml-instance-description \""+name+"\")",
			defaultPackage);
  }
  public String getInstancesInfo (String name) { // given concept
    return evaluateLispCommand("(generate-xml-instances \""+name+"\")",
			defaultPackage);
  }
  public String getMethodInfo (String name) {
    return evaluateLispCommand("(generate-xml-method-description \""+name+"\")",
			defaultPackage);
  }
  public String getConceptDef (String name) {
    return evaluateLispCommand("(generate-concept-definition \""+name+"\")",
			defaultPackage);
  }
  public String getRelationDef (String name) {
    return evaluateLispCommand("(generate-relation-definition \""+name+"\")",
			defaultPackage);
  }
  public String getInstanceDef (String name) {
    return evaluateLispCommand("(generate-instance-definition \""+name+"\")",
			defaultPackage);
  }
  public String getMethodDef (String name) {
    int packageIndex = name.indexOf ("::");
    if (packageIndex >0) 
      return evaluateLispCommand("(generate-method-definition \""+name.substring(packageIndex+2)+"\" :package (find-package \"" + name.substring(0,packageIndex)+"\"))",
			defaultPackage);
      
    else return evaluateLispCommand("(generate-method-definition \""+name+"\")",
			defaultPackage);
  }

  public String getPSNode (String node) { // given concept
    return evaluateLispCommand("(generate-xml-psnode-description \""+node+"\")",
			defaultPackage);
  }
  public String getEXENode (String node) { // given concept
    return evaluateLispCommand("(generate-xml-exenode-description \""+node+"\")",
			defaultPackage);
  }
  public String getAgenda (String item) {
    return evaluateLispCommand("(generate-xml-agenda-item-description \""+item+"\")",
			defaultPackage);
  }
  public String getTree (String type) {
    return evaluateLispCommand("(generate-xml-tree \""+type+"\")",
			defaultPackage);
  }
  public String getSearchElement (String name, String type,
				  String matchCase, String wholeWord,
				  String where) {
    return evaluateLispCommand("(search-expect-element \""+name+"\" \""+type+"\" \""+
			matchCase+"\" \""+wholeWord+"\" \""+where+"\")",
			defaultPackage);
  }


  public String editConcept (String concept) {
    return evaluateLispCommand("(add-or-change-concept \""+concept+"\")",
			defaultPackage);
  }
  public String editRelation (String relation) {
    return evaluateLispCommand("(add-or-change-concept \""+relation+"\")",
			defaultPackage);
  }
  public String editInstance (String instance) {
    return evaluateLispCommand("(add-or-change-concept \""+instance+"\")",
			defaultPackage);
  }
  public String editMethod (String method) {
    return evaluateLispCommand("(add-or-change-concept \""+method+"\")",
			defaultPackage);
  }
  
  // To support Method Editor

  public String checkAndCreateMethod (String method) {
    return evaluateLispCommand("(check-and-create-plan \""+method+"\")",
			defaultPackage);
  }
  public String checkAndModifyMethod (String method) {
    return evaluateLispCommand("(check-and-modify-plan \""+method+"\")",
			defaultPackage);
  }
  public String modifyOrCreateMethod (String method) {
    return evaluateLispCommand("(modify-or-create-plan \""+method+"\")",
			defaultPackage);
  }
  public String deleteMethod (String method) {
    return evaluateLispCommand("(delete-plan \""+method+"\")",
			defaultPackage);
  }
  public String removeMethod (String method) {//using ka directly
    return evaluateLispCommand("(remove-plan \""+method+"\")",
			defaultPackage);
  }
  public String checkMethod (String method) {
    return evaluateLispCommand("(get-errors-for-plan \""+method+"\")",
			defaultPackage);
  }
  
  public String initializeIA () {
    return evaluateLispCommand("(generate-xml-init-ia)",
			defaultPackage);
  }
  public String getMethodCapabilityTree (String type) {
    return evaluateLispCommand("(get-method-capability-tree)",
			defaultPackage);
  }
  public String getMethodRelationTree (String type) {
    return evaluateLispCommand("(get-method-relation-tree)",
			defaultPackage);
  }
  public String getUndefinedGoalList (String type) {
    return evaluateLispCommand("(get-undefined-goal-list)",
			defaultPackage);
  }
  public String getPSUndefinedGoalList (String type) {
    return evaluateLispCommand("(get-undefined-goal-list-from-ps)",
			defaultPackage);
  }
  public String getMethodNameList (String type) {
    return evaluateLispCommand("(get-method-name-list)",
			defaultPackage);
  }
  public String getSystemDefinedMethodNameList (String type) {
    return evaluateLispCommand("(get-system-defined-method-name-list)",
			defaultPackage);
  }
  public String getUserDefinedMethodNameList (String type) {
    return evaluateLispCommand("(get-user-defined-method-name-list)",
			defaultPackage);
  }
  public String getSearchedMethodNameList (String type, String key) {
    return evaluateLispCommand("(get-searched-method-name-list \""+key+"\")",
			defaultPackage);
  }
  public String getMethodsWithSubsumers (String type, String key) {
    return evaluateLispCommand("(get-methods-with-subsumers \""+key+"\")",
			defaultPackage);
  }
  public String getMethodsWithSubsumees (String type, String key) {
    return evaluateLispCommand("(get-methods-with-subsumees \""+key+"\")",
			defaultPackage);
  }  
  public String getSearchedOnRMFLMethodNameList (String type, String key) {
    return evaluateLispCommand("(xml-get-rfmls-in-search \""+key+"\")",
			defaultPackage);
  }

  // for match maker /////////
  public String getMethodNamesMatchingGoal (String goalDesc) {
    return evaluateLispCommand("(xml-get-methods-matching-goal \""+goalDesc+"\")",
			defaultPackage);
  }
  public String getMethodNamesMatchingRFMLTGoal (String goalDesc) {
    return evaluateLispCommand("(xml-get-method-matching-rfmlt-goal \""+goalDesc+"\")",
			defaultPackage);
  }
  public String getMethodNamesSubsumedByGoal (String goalDesc) {
    return evaluateLispCommand("(xml-get-methods-subsumed-by-goal \""+goalDesc+"\")",
			defaultPackage);
  }

  // end of match maker

  public String getAllMessages () {
    return evaluateLispCommand("(get-all-messages)",
			defaultPackage);
  }
  public String getOtherMessages () {
    return evaluateLispCommand("(get-other-error-messages)",
			defaultPackage);
  }
  public String getMethodRelationMessages () {
    return evaluateLispCommand("(get-method-relation-errors)",
			defaultPackage);
  }
  public String deleteAllMethods (String type) {
    return evaluateLispCommand("(delete-all-plans)",
			defaultPackage);
  }
  public String getTopResult (String type) {
    return evaluateLispCommand("(get-top-exe-result)",
			defaultPackage);
  }
  public String getPSMethodRelation (String type) {
    return evaluateLispCommand("(get-ps-method-relation-tree)",
			defaultPackage);
  }
  public String getPSMethodRelAll (String type) {
    return evaluateLispCommand("(get-ps-method-rel-tree-all)",
			defaultPackage);
  }
  public String getNLOfCapability (String key) {
    return evaluateLispCommand("(get-nl-of-capability \""+key+"\")",
			defaultPackage);
  }
  public String getNLOfMethod (String key) {
    return evaluateLispCommand("(get-nl-description-of-method \""+key+"\")",
			defaultPackage);
  }
  public String getNLOfResult (String key) {
    return evaluateLispCommand("(get-nl-description-of-data-type \""+key+"\")",
			defaultPackage);
  }
  public String getNLOfMethodResult (String key) {
    return evaluateLispCommand("(get-nl-description-of-method-result \""+key+"\")",
			defaultPackage);
  }

  public String getSimplifiedGoal (String key) {
    return evaluateLispCommand("(get-simplified-goal \""+key+"\")",
			defaultPackage);
  }
  public String getPartialMatch () {
    return evaluateLispCommand("(get-partial-match-for-incomplete-goals)",
			defaultPackage);
  }
  public String applyPartialMatch (String id) {
    return evaluateLispCommand("(propagate-constraint-from-potential-match \""+id+"\")",
			defaultPackage);
  }
  public String getPSTreeAll () {
    return evaluateLispCommand("(get-ps-tree-all)",
			defaultPackage);
  }
  public String getPSTreeSuccess () {
    return evaluateLispCommand("(get-ps-tree-success)",
			defaultPackage);
  }
  public String getPSTreeShort () {
    return evaluateLispCommand("(get-ps-tree-short)",
			defaultPackage);
  }
  public String getPSTreeGoals () {
    return evaluateLispCommand("(get-ps-tree-goals)",
			defaultPackage);
  }
  public String getPSTreePretty () {
    return evaluateLispCommand("(get-ps-tree-pretty)",
			defaultPackage);
  }
  public String getPSTreePrettyNL () {
    return evaluateLispCommand("(get-ps-tree-pretty-nl)",
			defaultPackage);
  }
  public String getPSTreeVeryDetail () {
    return evaluateLispCommand("(get-ps-tree-very-detail)",
			defaultPackage);
  }
  public String getEXEGoals () {
    return evaluateLispCommand("(get-exe-tree-goals)",
			defaultPackage);
  }
  public String getEXEPretty ()  {
    return evaluateLispCommand("(get-exe-tree-pretty)",
			defaultPackage);
  }
  public String getEditAlts (String nt, String cap, String name)  {
    return evaluateLispCommand("(get-edit-alternatives \""+nt+
			"\" :cap \""+cap+"\" :method-name \""+name+"\")",
			defaultPackage);
  }
  public String getEditAlts (String nt)  {
    return evaluateLispCommand("(get-edit-alternatives \""+nt+"\")",
			defaultPackage);
  }
  public String getEditVars (String desc)  {
    return evaluateLispCommand("(get-edit-vars \""+desc+"\")",
			defaultPackage);
  }
  public String getVarForType (String desc, String type)  {
    return evaluateLispCommand("(get-var-for-type \""+desc+"\" \""+type+"\")",
			defaultPackage);
  }
  public String getEditMethod (String name)  {
    return evaluateLispCommand("(get-edit-method \""+name+"\")",
			defaultPackage);
  }
  public String getEditCapOrBody (String code, String flag)  {
    return evaluateLispCommand("(get-edit-cap-or-body \""+code+"\" \""+flag+"\")",
			defaultPackage);
  }
  public String getSearchedCapability (String name) {
    return evaluateLispCommand("(get-searched-capability \""+name+"\")",
			defaultPackage);
  }
 
  

  /*************************************************************
   end of Lisp APIs
  **************************************************************/

  public static void main(String[] args) {
   ExpectSocketAPI api = new ExpectSocketAPI();

   String result = api.getAllMessages ();
   //System.out.println(" The result:"+ result);
   api.closeServerConnection();
 }
}
