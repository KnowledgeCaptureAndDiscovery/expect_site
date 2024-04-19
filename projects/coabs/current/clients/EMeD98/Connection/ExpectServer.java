/*  
 * ExpectServer.java  7/14/98
 */

/**
 * 
 *
 * @author Jihie Kim
 */

package Connection;
  
import java.lang.*;
import java.io.*;
import java.util.*;
import java.net.*;
import com.sun.java.swing.*;
import java.awt.*;

public class ExpectServer extends java.lang.Object
{
  static boolean debug = false;

  String kb = "EXPECT-THEORY";
  PrintStream e = System.err;
  String defaultMachine="tintagel.isi.edu";
  String defaultPort="8002";
  String machineName;
  String portNumber;
  String authData;

  static String[] ConnectOptionNames = { "Connect" };
  static String   ConnectTitle = "Connect EXPECT";
  static JPanel      connectionPanel;

  static JLabel      machineNameLabel; 
  static JTextField  machineNameField; 
  static JLabel      portNumberLabel; 
  static JTextField  portNumberField; 

  static JLabel      userNameLabel; 
  static JTextField  userNameField; 
  static JLabel      passwordLabel; 
  static JPasswordField  passwordField; 

  

  ExpectAPI expectAPI;
  LoomContexts contexts;


  PrintStream o = System.err;


   /**
     * Creates the connectionPanel, which will contain all the fields for
     * the connection information.
     */
  static void activateConnectionDialog() {
    PrintStream out = System.out;

    if (JOptionPane.showOptionDialog(null, connectionPanel, ConnectTitle,
		   JOptionPane.DEFAULT_OPTION, JOptionPane.INFORMATION_MESSAGE,
		   null, ConnectOptionNames, ConnectOptionNames[0]) == 0) {
      if (debug) out.println("option Dialog ok.");
    }
    else { if (debug) out.println("error in option Dialog.");
    }
     
  }

  static void createConnectionDialog() {
    // Create the labels and text fields.
    machineNameLabel = new JLabel("Machine name: ", JLabel.RIGHT);
    machineNameField = new JTextField("tintagel.isi.edu");
	
    portNumberLabel = new JLabel("Port number: ", JLabel.RIGHT);
    portNumberField = new JTextField("8002");
	
    userNameLabel = new JLabel("User name: ", JLabel.RIGHT);
    userNameField = new JTextField("demo");
	
    passwordLabel = new JLabel("Password: ", JLabel.RIGHT);
    passwordField = new JPasswordField("fundme");
	
    connectionPanel = new JPanel(false);
    connectionPanel.setLayout(new BoxLayout(connectionPanel,
					    BoxLayout.X_AXIS));

    JPanel namePanel = new JPanel(false);
    namePanel.setLayout(new GridLayout(0, 1));
    namePanel.add(machineNameLabel);
    namePanel.add(portNumberLabel);
    namePanel.add(userNameLabel); 
    namePanel.add(passwordLabel);


    JPanel fieldPanel = new JPanel(false);
    fieldPanel.setLayout(new GridLayout(0, 1));
    fieldPanel.add(machineNameField);
    fieldPanel.add(portNumberField);
    fieldPanel.add(userNameField); 
    fieldPanel.add(passwordField);

    connectionPanel.add(namePanel);
    connectionPanel.add(fieldPanel);
  }

  public ExpectServer()
  {
 
    createConnectionDialog();
    activateConnectionDialog();

    machineName=machineNameField.getText();
    portNumber=portNumberField.getText();
     
    try {
      authData = "Basic " +Base64.Base64EncodeString(userNameField.getText()+":"+passwordField.getText());
    }
    catch (Exception e) {
      System.out.println("Expect:Error in Base64 encoding.");
      System.out.println(e.getMessage());
      e.printStackTrace();
    }

     
    expectAPI = new ExpectAPI(machineName,portNumber,"/expect/",authData);
    e.println("Using port "+portNumber+" on "+machineName+".");

   
  }

  public void setKB(String KBname) {
   kb = KBname;
  }

  ///////////////////
  ////// KB /////////
  public String summarizeKB() {
    String results="";
    results = expectAPI.summarizeKB(kb);
        return results;
  }

  public String listKBs() {
    String results="";
    results = expectAPI.listKBs();
    return results;
  }

  public String createKB(String kbName) {
    String results="";
    results = expectAPI.createKB(kbName);
    return results;
  }

  public String loadKB (String kbname) {
    String results="";
    results = expectAPI.loadKB (kbname);
    return results;
  }
  public String saveKB (String kbname) {
    String results="";
    results = expectAPI.saveKB (kbname);
    return results;
  }

  ///////////////////
  ////// GOAL ///////

  public String getTopGoal() {
    String results="";
    results = expectAPI.getTopGoal(kb);
    return results;
  }
  public String setTopGoal(String goal) {
    String results="";
    results = expectAPI.setTopGoal(kb,goal);
    return results;
  }
  public String solveGoal() {
    String results="";
    results = expectAPI.solveGoal(kb);
    return results;
  }

  public String getTopProblem() {
    String results="";
    results = expectAPI.getTopProblem(kb);
    return results;
  }
  public String setTopProblem(String problem) {
    String results="";
    results = expectAPI.setTopProblem(kb,problem);
    return results;
  }

  public String solveProblem() {
    String results="";
    results = expectAPI.solveProblem(kb);
    return results;
  }


  /////////////////////////
  ///// domain info ///////
  public String getInfo(String funcName, String input)
  {
    String results ="";

    if (funcName.compareTo("getConcept")==0) 
      results = getConceptInfo(input);
    else if (funcName.compareTo("getInstances")==0) 
      getInstancesInfo(input);

    return results;
        
  }

  public String getMethodInfo(String name) {
    String results="";
    results = expectAPI.getMethod(kb,name);
    
    return results;
  }

  public String getConceptInfo(String name) {
    String results="";
    results = expectAPI.getConcept(kb,name);
    
    return results;
  }

  public String getRelationInfo(String name) {
    String results="";
    results = expectAPI.getRelation(kb,name);
    
    return results;
  }

  public String getInstancesInfo(String conceptName) {
    String results = expectAPI.getInstances(kb,conceptName);
    return results;
  }

  public String getInstanceInfo(String instanceName) {
    String results = expectAPI.getInstance(kb,instanceName);
    return results;
  }

  public String getAgenda(String agendaName) {
    String results = expectAPI.getAgenda(kb,agendaName);
    return results;
  }

  public String getSearchInfo(String name, String type,
			      String matchCase, String wholeWord,
			      String where) {
    String results="";
    results = expectAPI.getSearchElement(kb,name,type,matchCase,wholeWord,where);
    
    return results;
  }

  public String getPSNode(String PSnode) {
    String results="";
    results = expectAPI.getPSNode(kb, PSnode);
    return results;
  }

  public String getEXENode(String EXEnode) {
    String results="";
    results = expectAPI.getEXENode(kb, EXEnode);
    return results;
  }

  public String getTree(String type) {
    String results="";
    results = expectAPI.getTree(kb, type);
    return results;
  }

  public String getConceptDef (String name) {
    String results = expectAPI.getConceptDef(kb,name);
    return results;
  }
  public String getInstanceDef (String name) {
    String results = expectAPI.getInstanceDef(kb,name);
    return results;
  }
  public String getRelationDef (String name) {
    String results = expectAPI.getRelationDef(kb,name);
    return results;
  }
  public String getMethodDef (String name) {
    String results = expectAPI.getMethodDef(kb,name);
    return results;
  }

  public String editConcept (String name) {
    String results = expectAPI.editConcept(kb,name);
    return results;
  }
  public String editRelation (String name) {
    String results = expectAPI.editRelation(kb,name);
    return results;
  }
  public String editInstance (String name) {
    String results = expectAPI.editInstance(kb,name);
    return results;
  }
  public String editMethod (String name) {
    String results = expectAPI.editMethod(kb,name);
    return results;
  }
  

  /////////////////////////////////
  // To support Method Editor
  /////////////////////////////////


  /////////////////////////////////
  /// create/modify/delete method
  
  public String checkAndCreateMethod(String method) {
    String results="";
    results = expectAPI.checkAndCreateMethod(kb, method);
    return results;
  }
  
  public String checkAndModifyMethod(String method) {
    String results="";
    results = expectAPI.checkAndModifyMethod(kb, method);
    return results;
  }
  
  public String modifyOrCreateMethod(String method) {
    String results="";
    results = expectAPI.modifyOrCreateMethod(kb, method);
    return results;
  }

  public String deleteMethod(String methodName) {
    String results="";
    results = expectAPI.deleteMethod(kb, methodName);
    return results;
  }
  public String removeMethod(String methodName) {
    String results="";
    results = expectAPI.removeMethod(kb, methodName);
    return results;
  }
  
   public String checkMethod(String method) {
    String results="";
    results = expectAPI.checkMethod(kb, method);
    return results;
  }


  /////////////////////////////////

  public void initializeMKB () {
     String results = expectAPI.initializeMKB(kb);
  }
   public String getMethodCapabilityTree (String type) {
     String results = expectAPI.getMethodCapabilityTree(kb);
     return results;
  }
   public String getMethodRelationTree (String type) {
     String results = expectAPI.getMethodRelationTree(kb);
     return results;
  }
   public String getUndefinedGoalList (String type) {
     String results = expectAPI.getUndefinedGoalList(kb);
     return results;
  }
   public String getPSUndefinedGoalList (String type) {
     String results = expectAPI.getPSUndefinedGoalList(kb);
     return results;
  }
   public String getMethodNameList (String type) {
     String results = expectAPI.getMethodNameList(kb);
     return results;
  }
   public String getUserDefinedMethodNameList (String type) {
     String results = expectAPI.getUserDefinedMethodNameList(kb);
     return results;
  }
   public String getSystemDefinedMethodNameList (String type) {
     String results = expectAPI.getSystemDefinedMethodNameList(kb);
     return results;
  }
   public String getSearchedMethodNameList (String type, String key) {
     String results = expectAPI.getSearchedMethodNameList(kb, key);
     return results;
  }
   public String getMethodsWithSubsumers (String type, String key) {
     String results = expectAPI.getMethodsWithSubsumers(kb, key);
     return results;
  }
   public String getMethodsWithSubsumees (String type, String key) {
     String results = expectAPI.getMethodsWithSubsumees(kb, key);
     return results;
  }
   public String getAllMessages (String type) {
     String results = expectAPI.getAllMessages(kb);
     return results;
  }
   public String deleteAllMethods (String type) {
     String results = expectAPI.deleteAllMethods(kb);
     return results;
  }
   public String getTopResult (String type) {
     String results = expectAPI.getTopResult(kb);
     return results;
  }



  /////////////////////////////////////
  //// for interdependencies from PS
  /////////////////////////////////////

   public String getPSMethodRelation (String type) {
     String results = expectAPI.getPSMethodRelation(kb);
     return results;
  }
   public String getPSMethodRelAll (String type) {
     String results = expectAPI.getPSMethodRelAll(kb);
     return results;
  }

  ////////////////////////////////////////
  // get *get-nl-description-of-capability* 
   public String getNLOfCapability (String key) {
     String results = expectAPI.getNLOfCapability(kb, key);
     return results;
   }

   public String getSimplifiedGoal (String name) {
     String results = expectAPI.getSimplifiedGoal(kb, name);
     return results;
   }

  ////////////////////////////////////////
  // get *get-nl-description-of-method*
   public String getNLOfMethod (String key) {
     String results = expectAPI.getNLOfMethod(kb, key);
     return results;
   }


  ////////////////////////////////////////
  // potential match
  public String getPartialMatch () {
    String results = expectAPI.getPartialMatch(kb);
    return results;
  }

  public String applyPartialMatch (String id) {
    String results = expectAPI.applyPartialMatch(kb, id);
    return results;
  }

  ////////////////////////////////////////
  /// print ps tree /////

  public String getPSTreeAll () {
    return expectAPI.getPSTreeAll(kb);
  }

  public String getPSTreeSuccess () {
    return expectAPI.getPSTreeSuccess(kb);
  }

  public String getPSTreeShort () {
    return expectAPI.getPSTreeShort(kb);
  }

  public String getPSTreeGoals () {
    return expectAPI.getPSTreeGoals(kb);
  }

  public String getPSTreePretty () {
    return expectAPI.getPSTreePretty(kb);
  }

  public String getPSTreePrettyNL () {
    return expectAPI.getPSTreePrettyNL(kb);
  }
  public String getPSTreeVeryDetail () {
    return expectAPI.getPSTreeVeryDetail(kb);
  }

  public String getEXEGoals () {
    return expectAPI.getEXEGoals(kb);
  }
  public String getEXEPretty () {
    return expectAPI.getEXEPretty(kb);
  }

  public String getExpectMessages () {
    return expectAPI.getExpectMessages(kb);
  }
  public String getOtherMessages () {
    return expectAPI.getOtherMessages(kb);
  }

  //////////////////////////
  /// support for editor
  //////////////////////////
  public String getEditAlts (String nt) {
    return expectAPI.getEditAlts(kb, nt,"", "");
  }
  public String getEditAlts (String nt, String cap, String methodName) {
    return expectAPI.getEditAlts(kb, nt,cap,methodName);
  }
  public String getEditVars (String desc) {
    return expectAPI.getEditVars(kb, desc);
  }  
  public String getVarForType (String desc, String type) {
    return expectAPI.getVarForType(kb, desc,type);
  }  
   public String getEditMethod (String name) {
    return expectAPI.getEditMethod(kb, name);
  } 
  public String getEditCapOrBody (String code, String flag) {
    return expectAPI.getEditCapOrBody(kb, code, flag);
  } 
  public String getSearchedCapability (String name) {
    return expectAPI.getSearchedCapability(kb, name);
  } 

}
