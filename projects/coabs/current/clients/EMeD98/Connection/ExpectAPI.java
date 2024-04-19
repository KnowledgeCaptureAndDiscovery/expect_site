/*  
 * ExpectAPI.java  7/30/98
 */
 
/*
 * APIs for client: 
 * @author Jihie Kim
 */

package Connection;

import java.util.*;
import java.io.*;

public class ExpectAPI {
  String siteWithoutHttpOrLeadingBackslashes;
  String portNumber;
  String pathPrefixIncludingLeadingAndTrailingBackslash;
  String authData;

  ExpectAPI(String si,String po,String pa, String ad) {
    siteWithoutHttpOrLeadingBackslashes=si;
    portNumber=po;
    pathPrefixIncludingLeadingAndTrailingBackslash=pa;
    authData = ad;
  }

  private String site() {return siteWithoutHttpOrLeadingBackslashes;}
  private String port() {return portNumber;}
  private String path() {return pathPrefixIncludingLeadingAndTrailingBackslash;}
  private String auth() {return authData;}

  ///////////////////////////////////////
  // 7/21/98
  // For Expect Interface APIs
  //
  ///////////////////////////////////////



  ///////////////////////////////////////
  ///////// common code /////////////////
  private String getInfoCommonCode (Strings x) {
    if(!((String)x.items.elementAt(0)).trim().equalsIgnoreCase("ok")) {
      System.out.println(" query error: returned |"+ (String)x.items.elementAt(0) + "|");
      return null;}
    Enumeration e = x.items.elements();
    boolean isFirst=true;
    String result = "";
    while(e.hasMoreElements()) {
      String s = (String) e.nextElement();
      if(isFirst) {isFirst=false;}
      else { 
	result = result + s;
      }
    }
    return result;
  }

  ///////////////////////////////////////
  // For KBs
  ///////////////////////////////////////

  //// load KB ////
  private Strings loadKBInternal(String KBname) {
    Hashtable h = new Hashtable();
    h.put("package", "EXPECT");
    h.put("kb",KBname);
    //System.out.println(" EXPECT " + KBname);
    return HtmlUtilAuth.post(site()+":"+port(),path()+"load-expect-kb.html",h,auth());
  }

  public String loadKB (String KBname) {
    Strings x = loadKBInternal(KBname);
    String result = getEditResponse (x);
    //System.out.println(" ** loadKB " + KBname+":"+result);
    return result;
  }

  //// save KB ////
  private Strings saveKBInternal(String KBname) {
    Hashtable h = new Hashtable();
    h.put("package", "EXPECT");
    h.put("kb",KBname);
    //System.out.println(" ** saveKB " + KBname);
    return HtmlUtilAuth.post(site()+":"+port(),path()+"save-expect-kb.html",h,auth());
  }

  public String saveKB (String KBname) {
    Strings x = saveKBInternal(KBname);
    String result = getEditResponse (x);
    return result;
  }


  /// create kb ///
  private Strings createKBInternal(String kbName) {
    Hashtable h = new Hashtable(); 
    h.put("kb-name",kbName);
    //System.out.println(" EXPECT create " + kbName);
    return HtmlUtilAuth.post(site()+":"+port(),path()+"create-kb.html",h,auth());
  }

  public String createKB (String kbName) {
    Strings x = createKBInternal(kbName);
    String result = getInfoCommonCode (x);
    return result;
  }


  //// summarize kb /////
  private Strings summarizeKBInternal(String kb) {
    Hashtable h = new Hashtable();
    h.put("kb-name",kb);
    //System.out.println(kb+" EXPECT ");
    return HtmlUtilAuth.post(site()+":"+port(),path()+"summarize-kb.html",h,auth());
  }

  public String summarizeKB (String kb) {
    Strings x = summarizeKBInternal(kb);
    String result = getInfoCommonCode (x);
    return result;
  }

  //// list kbs ////
  private Strings listKBsInternal() {
    Hashtable h = new Hashtable(); // dummy
    //System.out.println(" EXPECT list kbs ");
    return HtmlUtilAuth.post(site()+":"+port(),path()+"list-kbs.html",h,auth());
  }

  public String listKBs () {
    Strings x = listKBsInternal();
    String result = getInfoCommonCode (x);
    return result;
  }

  ///////////////////////////////////////
  // For Goals
  ///////////////////////////////////////

  private Strings setTopGoalInternal(String kb, String goal) {
    Hashtable h = new Hashtable();
    h.put("context",kb);
    h.put("package", "EXPECT");
    h.put("goal",goal);
    return HtmlUtilAuth.post(site()+":"+port(),path()+"set-top-level-goal.html",h,auth());
  }

  public String setTopGoal (String kb, String goal) {
    Strings x = setTopGoalInternal(kb, goal);
    String result = getEditResponse (x);
    return result;
  }

  private Strings getTopGoalInternal(String kb) {
    Hashtable h = new Hashtable();
    h.put("context",kb);
    h.put("package", "EXPECT");
    return HtmlUtilAuth.post(site()+":"+port(),path()+"get-top-level-goal.html",h,auth());
  }

  public String getTopGoal (String kb) {
    Strings x = getTopGoalInternal(kb);
    String result = getInfoCommonCode (x);
    return result;
  }

  private Strings solveGoalInternal(String kb) {
    Hashtable h = new Hashtable();
    h.put("context",kb);
    h.put("package", "EXPECT");
    return HtmlUtilAuth.post(site()+":"+port(),path()+"solve-goal.html",h,auth());
  }

  public String solveGoal (String kb) {
    Strings x = solveGoalInternal(kb);
    String result = getEditResponse (x);
    return result;
  }


  private Strings setTopProblemInternal(String kb, String problem) {
    Hashtable h = new Hashtable();
    h.put("context",kb);
    h.put("package", "EXPECT");
    h.put("problem",problem);
    return HtmlUtilAuth.post(site()+":"+port(),path()+"set-top-level-problem.html",h,auth());
  }

  public String setTopProblem (String kb, String problem) {
    Strings x = setTopProblemInternal(kb, problem);
    String result = getEditResponse (x);
    return result;
  }

  private Strings getTopProblemInternal(String kb) {
    Hashtable h = new Hashtable();
    h.put("context",kb);
    h.put("package", "EXPECT");
    return HtmlUtilAuth.post(site()+":"+port(),path()+"get-top-level-problem.html",h,auth());
  }

  public String getTopProblem (String kb) {
    Strings x = getTopProblemInternal(kb);
    String result = getInfoCommonCode (x);
    return result;
  }

  private Strings solveProblemInternal(String kb) {
    Hashtable h = new Hashtable();
    h.put("context",kb);
    h.put("package", "EXPECT");
    return HtmlUtilAuth.post(site()+":"+port(),path()+"solve-problem.html",h,auth());
  }

  public String solveProblem (String kb) {
    Strings x = solveProblemInternal(kb);
    String result = getEditResponse (x);
    return result;
  }


  ///////////////////////////////////////
  ///////// get concept /////////////////
  private Strings getConceptInternal(String kb, String name) {
    Hashtable h = new Hashtable();
    h.put("context",kb);
    h.put("package", "EXPECT");
    h.put("concept",name);
    return HtmlUtilAuth.post(site()+":"+port(),path()+"get-concept.html",h,auth());
  }

  public String getConcept (String kb, String name) {
    Strings x = getConceptInternal(kb,name);
    String result = getInfoCommonCode (x);
    return result;
  }

  ///////////////////////////////////////
  ///////// get relation /////////////////
  private Strings getRelationInternal(String kb, String name) {
    Hashtable h = new Hashtable();
    h.put("context",kb);
    h.put("package", "EXPECT");
    h.put("relation",name);
    //System.out.println(kb+" EXPECT " + name);
    return HtmlUtilAuth.post(site()+":"+port(),path()+"get-relation.html",h,auth());
  }

  public String getRelation (String kb, String name) {
    Strings x = getRelationInternal(kb,name);
    String result = getInfoCommonCode (x);
    return result;
  }

  ///////////////////////////////////////
  ///////// get instances /////////////////
  private Strings getInstancesInternal(String kb, String conceptName) {
    Hashtable h = new Hashtable();
    h.put("context",kb);
    h.put("package", "EXPECT");
    h.put("concept",conceptName);
    return HtmlUtilAuth.post(site()+":"+port(),path()+"get-instances.html",h,auth());
  }

  public String getInstances (String kb, String conceptName) {
    Strings x = getInstancesInternal(kb,conceptName);
    String result = getInfoCommonCode (x);
    return result;
  }
  ///////////////////////////////////////
  ///////// get instance info ///////////
  private Strings getInstanceInternal(String kb, String instanceName) {
    Hashtable h = new Hashtable();
    h.put("context",kb);
    h.put("package", "EXPECT");
    h.put("instance",instanceName);
    //System.out.println("getInstanceInternal:"+kb+" EXPECT " + instanceName);
    return HtmlUtilAuth.post(site()+":"+port(),path()+"get-instance.html",h,auth());
  }

  public String getInstance (String kb, String instanceName) {
    
    Strings x = getInstanceInternal(kb,instanceName);
    String result = getInfoCommonCode (x);
    return result;
  }

  ///////////////////////////////////////
  ///////// get method //////////////////
  private Strings getMethodInternal(String kb, String name) {
    Hashtable h = new Hashtable();
    h.put("context",kb);
    h.put("package", "EXPECT");
    h.put("method",name);
    //System.out.println(kb+" EXPECT " + name);
    return HtmlUtilAuth.post(site()+":"+port(),path()+"get-method.html",h,auth());
  }

  public String getMethod (String kb, String name) {
    Strings x = getMethodInternal(kb,name);
    String result = getInfoCommonCode (x);
    return result;
  }


  ///////////////////////////////////////
  ///////// get PS node /////////////////
  private Strings getPSNodeInternal(String kb, String PSnode) {
    Hashtable h = new Hashtable(); 
    h.put("kb",kb);
    h.put("ps-node",PSnode);
    //System.out.println(kb + " node " + PSnode);
    return HtmlUtilAuth.post(site()+":"+port(),path()+"get-ps-node.html",h,auth());
  }

  public String getPSNode (String kb, String PSnode) {
    Strings x = getPSNodeInternal(kb,PSnode);
    String result = getInfoCommonCode (x);
    return result;
  }

  ///////////////////////////////////////
  ///////// get EXE node ////////////////
  private Strings getEXENodeInternal(String kb, String EXEnode) {
    Hashtable h = new Hashtable(); 
    h.put("context",kb);
    h.put("exe-node",EXEnode);
    //System.out.println(kb + " node " + EXEnode);
    return HtmlUtilAuth.post(site()+":"+port(),path()+"get-exe-node.html",h,auth());
  }

  public String getEXENode (String kb, String EXEnode) {
    Strings x = getEXENodeInternal(kb,EXEnode);
    String result = getInfoCommonCode (x);
    return result;
  }  

  ///////////////////////////////////////
  ///////// get Agenda   ////////////////
  
  private Strings getAgendaInternal(String kb, String agendaItem) {
    Hashtable h = new Hashtable(); 
    h.put("context",kb);
    h.put("agenda-item",agendaItem);
    return HtmlUtilAuth.post(site()+":"+port(),path()+"get-agenda-item.html",h,auth());
  }

  public String getAgenda (String kb, String agendaItem) {
    Strings x = getAgendaInternal(kb,agendaItem);
    String result = getInfoCommonCode (x);
    return result;
  }
  
  ///////////////////////////////////////
  ///////// get Tree ////////////////////
  private Strings getTreeInternal(String kb, String type) {
    Hashtable h = new Hashtable(); 
    h.put("context",kb);
    h.put("tree-type",type);
    h.put("root","");
    return HtmlUtilAuth.post(site()+":"+port(),path()+"get-tree.html",h,auth());
  }

  public String getTree (String kb, String type) {
    Strings x = getTreeInternal(kb,type);
    String result = getInfoCommonCode (x);
    return result;
  }




  ///////////////////////////////////////
  ///////// get search info /////////////
  private Strings getSearchElementInternal(String kb, String name, String type,
					   String matchCase, String wholeWord,
					   String where) {
    Hashtable h = new Hashtable();
    h.put("context",kb);
    h.put("package", "EXPECT");
    h.put("name",name);
    h.put("type",type);
    h.put("match-case",matchCase);
    h.put("whole-word",wholeWord);
    h.put("where",where);
    
    return HtmlUtilAuth.post(site()+":"+port(),path()+"search-element.html",h,auth());
  }

  public String getSearchElement (String kb, String name, String type,
				  String matchCase, String wholeWord,
				  String where) {
    Strings x = getSearchElementInternal(kb,name,type,matchCase,wholeWord,where);

    if(!((String)x.items.elementAt(0)).trim().equalsIgnoreCase("ok")) {
      System.out.println(" query error: returned |"+ (String)x.items.elementAt(0) + "|");
      return null;}
    Enumeration e = x.items.elements();
    boolean isFirst=true;
    String result = "";
    while(e.hasMoreElements()) {
      String s = (String) e.nextElement();
      if(isFirst) {isFirst=false;}
      else { 
	result = result + s;
      }
    }
    return result;
  }




  ///////////////////////////////////////
  // general evaluation
  private Strings generalEvalInternal(String kb, String query) {
    Hashtable h = new Hashtable();
    h.put("context",kb);
    h.put("package", "EXPECT");
    h.put("query",query);
    //System.out.println(kb+" EXPECT " + vars + " " + query);
    return HtmlUtilAuth.post(site()+":"+port(),path()+"general-eval.html",h,auth());
  }

  public String generalEval (String kb, String vars, String query) {
    Strings x = generalEvalInternal(kb,query);

    if(!((String)x.items.elementAt(0)).equalsIgnoreCase("ok")) {
      System.out.println(" query error");
      return null;}
    Enumeration e = x.items.elements();
    boolean isFirst=true;
    String result = "";
    String separator = new String("::");
    while(e.hasMoreElements()) {
      String s = (String) e.nextElement();
      if(isFirst) {isFirst=false;}
      else {
	int i = s.indexOf(separator);
	String rawName = s.substring(i+separator.length(),s.length());
	result = result + rawName;
      }
    }
    return result;
  }

  //"which" can be execute-query
  private Strings executeLoomQueryInternal(String kb, String vars, String query) {
    Hashtable h = new Hashtable();
    h.put("context",kb);
    h.put("package", "PRODUCT");
    h.put("variables",vars);
    h.put("query",query);
    //System.out.println(kb+" PRODUCT " + vars + " " + query);
    return HtmlUtilAuth.post(site()+":"+port(),path()+"execute-query.html",h,auth());
  }

  public String executeLoomQuery (String kb, String vars, String query) {
    Strings x = executeLoomQueryInternal(kb,vars,query);
    //if(x.items.size()!=2) {return null;}
    //System.out.println(" After executeLoomQueryInternal");
    if(!((String)x.items.elementAt(0)).equalsIgnoreCase("ok")) {
      System.out.println(" query error");
      return null;}
    Enumeration e = x.items.elements();
    boolean isFirst=true;
    String result = "";
    String separator = new String("::");
    while(e.hasMoreElements()) {
      String s = (String) e.nextElement();
      if(isFirst) {isFirst=false;}
      else {
	int i = s.indexOf(separator);
	String rawName = s.substring(i+separator.length(),s.length());
	result = result + rawName;
      }
    }
    return result;
  }

  ///////////////////////////
  //// get definitions only
  ///////////////////////////
  private Strings getConceptDefInternal(String kb, String name) {
    Hashtable h = new Hashtable();
    h.put("context",kb);
    h.put("package", "EXPECT");
    h.put("concept",name);
    return HtmlUtilAuth.post(site()+":"+port(),path()+"get-concept-definition.html",h,auth());
  }

  public String getConceptDef (String kb, String name) {
   // System.out.println("getConceptDef:"+kb+":"+name);
    Strings x = getConceptDefInternal(kb,name);
    String result = getInfoCommonCode (x);
    return result;
  }

  private Strings getInstanceDefInternal(String kb, String name) {
    Hashtable h = new Hashtable();
    h.put("context",kb);
    h.put("package", "EXPECT");
    h.put("instance",name);
    return HtmlUtilAuth.post(site()+":"+port(),path()+"get-instance-definition.html",h,auth());
  }

  public String getInstanceDef (String kb, String name) {
    //System.out.println("getInstanceDef:"+kb+":"+name);
    Strings x = getInstanceDefInternal(kb,name);
    String result = getInfoCommonCode (x);
    return result;
  }

  private Strings getRelationDefInternal(String kb, String name) {
    Hashtable h = new Hashtable();
    h.put("context",kb);
    h.put("package", "EXPECT");
    h.put("relation",name);
    return HtmlUtilAuth.post(site()+":"+port(),path()+"get-relation-definition.html",h,auth());
  }

  public String getRelationDef (String kb, String name) {
    Strings x = getRelationDefInternal(kb,name);
    String result = getInfoCommonCode (x);
    return result;
  }

  private Strings getMethodDefInternal(String kb, String name) {
    Hashtable h = new Hashtable();
    h.put("context",kb);
    h.put("package", "EXPECT");
    h.put("method",name);
    return HtmlUtilAuth.post(site()+":"+port(),path()+"get-method-definition.html",h,auth());
  }

  public String getMethodDef (String kb, String name) {
    Strings x = getMethodDefInternal(kb,name);
    String result = getInfoCommonCode (x);
    //System.out.println("Result in Server:"+result);
    return result;
  }

  ///////////////////////////
  //// edit definitions 
  ///////////////////////////

 private String getEditResponse (Strings x) {
    Enumeration e = x.items.elements();
    String result = "";
    while(e.hasMoreElements()) {
      String s = (String) e.nextElement();
      result = result + s;
    }
    return result;
  }

  private Strings editConceptInternal(String kb, String name) {
    Hashtable h = new Hashtable();
    h.put("context",kb);
    h.put("package", "EXPECT");
    h.put("concept",name);
    return HtmlUtilAuth.post(site()+":"+port(),path()+"add-or-change-concept.html",h,auth());
  }

  public String editConcept (String kb, String name) {
    Strings x = editConceptInternal(kb,name);
    String result = getEditResponse (x);
    System.out.println(" ** edit concept " + kb+":"+result);
    return result;
  }

  private Strings editInstanceInternal(String kb, String name) {
    Hashtable h = new Hashtable();
    h.put("context",kb);
    h.put("package", "EXPECT");
    h.put("instance",name);
    return HtmlUtilAuth.post(site()+":"+port(),path()+"add-or-change-instance.html",h,auth());
  }

  public String editInstance (String kb, String name) {
    Strings x = editInstanceInternal(kb,name);
    String result = getEditResponse (x);
    return result;
  }

  private Strings editRelationInternal(String kb, String name) {
    Hashtable h = new Hashtable();
    h.put("context",kb);
    h.put("package", "EXPECT");
    h.put("relation",name);
    return HtmlUtilAuth.post(site()+":"+port(),path()+"add-or-change-relation.html",h,auth());
  }

  public String editRelation (String kb, String name) {
    Strings x = editRelationInternal(kb,name);
    String result = getEditResponse (x);
    return result;
  }

  private Strings editMethodInternal(String kb, String name) {
    Hashtable h = new Hashtable();
    h.put("context",kb);
    h.put("package", "EXPECT");
    h.put("method",name);
    return HtmlUtilAuth.post(site()+":"+port(),path()+"add-or-change-method.html",h,auth());
  }

  public String editMethod (String kb, String name) {
    Strings x = editMethodInternal(kb,name);
    String result = getEditResponse (x);
    return result;
  }



  ///////////////////////////////////////
  ///////////////////////////////////////
  // To support Method Editor
  //////////////////////////////////////

  /*************** Edit/modify/delete method ****************/

  ///////////////////////////////////////
  private Strings checkAndCreateMethodInternal(String kb, String method) {
    Hashtable h = new Hashtable(); 
    h.put("kb",kb);
    h.put("method",method);
    return HtmlUtilAuth.post(site()+":"+port(),path()+"check-and-create-plan.html",h,auth());
  }

  public String checkAndCreateMethod (String kb, String method) {
    Strings x = checkAndCreateMethodInternal(kb,method);
    String result = getInfoCommonCode (x);
    return result;
  }

  ///////////////////////////////////////
  private Strings checkAndModifyMethodInternal(String kb, String method) {
    Hashtable h = new Hashtable(); 
    h.put("kb",kb);
    h.put("method",method);
    return HtmlUtilAuth.post(site()+":"+port(),path()+"check-and-modify-plan.html",h,auth());
  }

  public String checkAndModifyMethod (String kb, String method) {
    Strings x = checkAndModifyMethodInternal(kb,method);
    String result = getInfoCommonCode (x);
    return result;
  }

  ///////////////////////////////////////
  private Strings modifyOrCreateMethodInternal(String kb, String method) {
    Hashtable h = new Hashtable(); 
    h.put("kb",kb);
    h.put("method",method);
    return HtmlUtilAuth.post(site()+":"+port(),path()+"modify-or-create-plan.html",h,auth());
  }

  public String modifyOrCreateMethod (String kb, String method) {
    Strings x = modifyOrCreateMethodInternal(kb,method);
    String result = getInfoCommonCode (x);
    return result;
  }

  ///////////////////////////////////////
  private Strings deleteMethodInternal(String kb, String methodName) {
    Hashtable h = new Hashtable(); 
    h.put("kb",kb);
    h.put("method",methodName);
    return HtmlUtilAuth.post(site()+":"+port(),path()+"delete-plan.html",h,auth());
  }

  public String deleteMethod (String kb, String methodName) {
    Strings x = deleteMethodInternal(kb,methodName);
    String result = getInfoCommonCode (x);
    return result;
  }

  /////// for experiment only
  private Strings removeMethodInternal(String kb, String methodName) {
    Hashtable h = new Hashtable(); 
    h.put("kb",kb);
    h.put("method",methodName);
    return HtmlUtilAuth.post(site()+":"+port(),path()+"remove-plan.html",h,auth());
  }

  public String removeMethod (String kb, String methodName) {
    Strings x = removeMethodInternal(kb,methodName);
    String result = getInfoCommonCode (x);
    return result;
  }





  ///////////////////////////////////////
  private Strings checkMethodInternal(String kb, String method) {
    Hashtable h = new Hashtable(); 
    h.put("kb",kb);
    h.put("method",method);
    //System.out.println(kb + " method " + method);
    return HtmlUtilAuth.post(site()+":"+port(),path()+"check-plan.html",h,auth());
  }

  public String checkMethod (String kb, String method) {
    Strings x = checkMethodInternal(kb,method);
    String result = getInfoCommonCode (x);
    //System.out.println("\n result in API:" + result);
    return result;
  }

  /*************** initialize method KB ****************/
  private Strings initializeMKBInternal(String kb) {
    Hashtable h = new Hashtable(); 
    h.put("kb",kb);
    //System.out.println(kb + " method " + method);
    return HtmlUtilAuth.post(site()+":"+port(),path()+"initialize-mkb.html",h,auth());
  }

  public String initializeMKB (String kb) {
    Strings x = initializeMKBInternal(kb);
    String result = getInfoCommonCode (x);
    return result;
  }

  /*************** get *mkb-defined-goals-root*  ****************/
  private Strings getMethodCapabilityTreeInternal(String kb) {
    Hashtable h = new Hashtable(); 
    h.put("kb",kb);
    return HtmlUtilAuth.post(site()+":"+port(),path()+"get-method-capability-tree.html",h,auth());
  }

  public String getMethodCapabilityTree (String kb) {
    Strings x = getMethodCapabilityTreeInternal(kb);
    String result = getInfoCommonCode (x);
    return result;
  }  

  /*************** get *mkb-goal-structure-tree-root*  ****************/
  private Strings getMethodRelationTreeInternal(String kb) {
    Hashtable h = new Hashtable(); 
    h.put("kb",kb);
    return HtmlUtilAuth.post(site()+":"+port(),path()+"get-method-relation-tree.html",h,auth());
  }

  public String getMethodRelationTree (String kb) {
    Strings x = getMethodRelationTreeInternal(kb);
    String result = getInfoCommonCode (x);
    return result;
  }  

  /*************** get  *mkb-undefined-goal-list*  ****************/
  private Strings getUndefinedGoalListInternal(String kb) {
    Hashtable h = new Hashtable(); 
    h.put("kb",kb);
    return HtmlUtilAuth.post(site()+":"+port(),path()+"get-undefined-goal-list.html",h,auth());
  }

  public String getUndefinedGoalList (String kb) {
    Strings x = getUndefinedGoalListInternal(kb);
    String result = getInfoCommonCode (x);
    return result;
  }  
  /*************** get  *mkb-ps-undefined-goal-list*  ****************/
  private Strings getPSUndefinedGoalListInternal(String kb) {
    Hashtable h = new Hashtable(); 
    h.put("kb",kb);
    return HtmlUtilAuth.post(site()+":"+port(),path()+"get-ps-undefined-goals.html",h,auth());
  }

  public String getPSUndefinedGoalList (String kb) {
    Strings x = getPSUndefinedGoalListInternal(kb);
    String result = getInfoCommonCode (x);
    return result;
  }

  /*************** get  method-name-list  ****************/
  private Strings getMethodNameListInternal(String kb) {
    Hashtable h = new Hashtable(); 
    h.put("kb",kb);
    return HtmlUtilAuth.post(site()+":"+port(),path()+"get-method-name-list.html",h,auth());
  }

  public String getMethodNameList (String kb) {
    Strings x = getMethodNameListInternal(kb);
    String result = getInfoCommonCode (x);
    return result;
  }

  /*************** get system defined method-name-list  ****************/
  private Strings getSystemDefinedMethodNameListInternal(String kb) {
    Hashtable h = new Hashtable(); 
    h.put("kb",kb);
    return HtmlUtilAuth.post(site()+":"+port(),path()+"get-system-method-list.html",h,auth());
  }

  public String getSystemDefinedMethodNameList (String kb) {
    Strings x = getSystemDefinedMethodNameListInternal(kb);
    String result = getInfoCommonCode (x);
    return result;
  }
  /*************** get user defined method-name-list  ****************/
  private Strings getUserDefinedMethodNameListInternal(String kb) {
    Hashtable h = new Hashtable(); 
    h.put("kb",kb);
    return HtmlUtilAuth.post(site()+":"+port(),path()+"get-user-method-list.html",h,auth());
  }

  public String getUserDefinedMethodNameList (String kb) {
    Strings x = getUserDefinedMethodNameListInternal(kb);
    String result = getInfoCommonCode (x);
    return result;
  }

  /*************** get searched method-name-list  ****************/
  private Strings getSearchedMethodNameListInternal(String kb, String key) {
    Hashtable h = new Hashtable(); 
    h.put("kb",kb);
    h.put("key",key);
    return HtmlUtilAuth.post(site()+":"+port(),path()+"get-srchd-method-list.html",h,auth());
  }

  public String getSearchedMethodNameList (String kb, String key) {
    Strings x = getSearchedMethodNameListInternal(kb, key);
    String result = getInfoCommonCode (x);
    return result;
  }

  /*************** search methods who refer to subsumers  ****************/
  private Strings getMethodsWithSubsumersInternal(String kb, String key) {
    Hashtable h = new Hashtable(); 
    h.put("kb",kb);
    h.put("key",key);
    return HtmlUtilAuth.post(site()+":"+port(),path()+"get-methods-with-subsumers.html",h,auth());
  }

  public String getMethodsWithSubsumers (String kb, String key) {
    Strings x = getMethodsWithSubsumersInternal(kb, key);
    String result = getInfoCommonCode (x);
    return result;
  }

  /*************** search methods who refer to subsumees  ****************/
  private Strings getMethodsWithSubsumeesInternal(String kb, String key) {
    Hashtable h = new Hashtable(); 
    h.put("kb",kb);
    h.put("key",key);
    return HtmlUtilAuth.post(site()+":"+port(),path()+"get-methods-with-subsumees.html",h,auth());
  }

  public String getMethodsWithSubsumees (String kb, String key) {
    Strings x = getMethodsWithSubsumeesInternal(kb, key);
    String result = getInfoCommonCode (x);
    return result;
  }

  /***************get all messages (as in agenda)  ****************/
  private Strings getAllMessagesInternal(String kb) {
    Hashtable h = new Hashtable(); 
    h.put("kb",kb);
    return HtmlUtilAuth.post(site()+":"+port(),path()+"get-all-messages.html",h,auth());
  }

  public String getAllMessages (String kb) {
    Strings x = getAllMessagesInternal(kb);
    String result = getInfoCommonCode (x);
    return result;
  }

  private Strings getExpectMessagesInternal(String kb) {
    Hashtable h = new Hashtable(); 
    h.put("kb",kb);
    return HtmlUtilAuth.post(site()+":"+port(),path()+"get-expect-messages.html",h,auth());
  }

  public String getExpectMessages (String kb) {
    Strings x = getExpectMessagesInternal(kb);
    String result = getInfoCommonCode (x);
    return result;
  }

  private Strings getOtherMessagesInternal(String kb) {
    Hashtable h = new Hashtable(); 
    h.put("kb",kb);
    return HtmlUtilAuth.post(site()+":"+port(),path()+"get-other-messages.html",h,auth());
  }

  public String getOtherMessages (String kb) {
    Strings x = getOtherMessagesInternal(kb);
    String result = getInfoCommonCode (x);
    return result;
  }

  /***************delete all methods  ****************/
  private Strings deleteAllMethodsInternal(String kb) {
    Hashtable h = new Hashtable(); 
    h.put("kb",kb);
    return HtmlUtilAuth.post(site()+":"+port(),path()+"delete-all-plans.html",h,auth());
  }

  public String deleteAllMethods (String kb) {
    Strings x = deleteAllMethodsInternal(kb);
    String result = getInfoCommonCode (x);
    return result;
  }

  private Strings getTopResultInternal(String kb) {
    Hashtable h = new Hashtable(); 
    h.put("kb",kb);
    return HtmlUtilAuth.post(site()+":"+port(),path()+"get-top-exe-result.html",h,auth());
  }

  public String getTopResult (String kb) {
    Strings x = getTopResultInternal(kb);
    String result = getInfoCommonCode (x);
    return result;
  }





  /////////////////////////////////////
  //// for interdependencies from PS
  /////////////////////////////////////

  /*************** get *mkb-ps-method-relation-tree-root*  ****************/
  private Strings getPSMethodRelationInternal(String kb) {
    Hashtable h = new Hashtable(); 
    h.put("kb",kb);
    return HtmlUtilAuth.post(site()+":"+port(),path()+"get-ps-method-relation.html",h,auth());
  }

  public String getPSMethodRelation (String kb) {
    Strings x = getPSMethodRelationInternal(kb);
    String result = getInfoCommonCode (x);
    return result;
  }  

  /*************** get *mkb-ps-method-relation-tree-root*  ****************/
  private Strings getPSMethodRelAllInternal(String kb) {
    Hashtable h = new Hashtable(); 
    h.put("kb",kb);
    return HtmlUtilAuth.post(site()+":"+port(),path()+"get-ps-method-rel-all.html",h,auth());
  }

  public String getPSMethodRelAll (String kb) {
    Strings x = getPSMethodRelAllInternal(kb);
    String result = getInfoCommonCode (x);
    return result;
  }  


  /*************** get *get-nl-description-of-capability*  ****************/

  private Strings getNLOfCapabilityInternal(String kb, String key) {
    Hashtable h = new Hashtable(); 
    h.put("kb",kb);
    h.put("key",key);
    return HtmlUtilAuth.post(site()+":"+port(),path()+"get-nl-of-capability.html",h,auth());
  }

  public String getNLOfCapability (String kb, String key) {
    Strings x = getNLOfCapabilityInternal(kb, key);
    String result = getInfoCommonCode (x);
    return result;
  }

  /*************** get *get-nl-description-of-method*  ****************/

  private Strings getNLOfMethodInternal(String kb, String key) {
    Hashtable h = new Hashtable(); 
    h.put("kb",kb);
    h.put("key",key);
    return HtmlUtilAuth.post(site()+":"+port(),path()+"get-nl-of-method.html",h,auth());
  }

  public String getNLOfMethod (String kb, String key) {
    Strings x = getNLOfMethodInternal(kb, key);
    String result = getInfoCommonCode (x);
    return result;
  }

  private Strings getSimplifiedGoalInternal(String kb, String key) {
    Hashtable h = new Hashtable(); 
    h.put("kb",kb);
    h.put("key",key);
    return HtmlUtilAuth.post(site()+":"+port(),path()+"get-simple-goal.html",h,auth());
  }

  public String getSimplifiedGoal (String kb, String key) {
    Strings x = getSimplifiedGoalInternal(kb, key);
    String result = getInfoCommonCode (x);
    return result;
  }


  /*************** process partial matches  ****************/


  private Strings getPartialMatchInternal(String kb) {
    Hashtable h = new Hashtable(); 
    h.put("kb",kb);
    return HtmlUtilAuth.post(site()+":"+port(),path()+"get-partial-match.html",h,auth());
  }

  public String getPartialMatch (String kb) {
    Strings x = getPartialMatchInternal(kb);
    String result = getInfoCommonCode (x);
    return result;
  }


  private Strings applyPartialMatchInternal(String kb, String id) {
    Hashtable h = new Hashtable(); 
    h.put("kb",kb);
    h.put("id",id);
    return HtmlUtilAuth.post(site()+":"+port(),path()+"apply-partial-match.html",h,auth());
  }

  public String applyPartialMatch (String kb, String id) {
    Strings x = applyPartialMatchInternal(kb,id);
    String result = getInfoCommonCode (x);
    return result;
  }

  ////////////////////////////////////////
  /// print ps tree /////

  private Strings getPSTreeAllInternal(String kb) {
    Hashtable h = new Hashtable(); 
    h.put("kb",kb);
    return HtmlUtilAuth.post(site()+":"+port(),path()+"get-ps-tree-all.html",h,auth());
  }

  public String getPSTreeAll (String kb) {
    Strings x = getPSTreeAllInternal(kb);
    String result = getInfoCommonCode (x);
    return result;
  }

  private Strings getPSTreeSuccessInternal(String kb) {
    Hashtable h = new Hashtable(); 
    h.put("kb",kb);
    return HtmlUtilAuth.post(site()+":"+port(),path()+"get-ps-tree-success.html",h,auth());
  }

  public String getPSTreeSuccess (String kb) {
    Strings x = getPSTreeSuccessInternal(kb);
    String result = getInfoCommonCode (x);
    return result;
  }

  private Strings getPSTreeShortInternal(String kb) {
    Hashtable h = new Hashtable(); 
    h.put("kb",kb);
    return HtmlUtilAuth.post(site()+":"+port(),path()+"get-ps-tree-short.html",h,auth());
  }

  public String getPSTreeShort (String kb) {
    Strings x = getPSTreeShortInternal(kb);
    String result = getInfoCommonCode (x);
    return result;
  }

  private Strings getPSTreeGoalsInternal(String kb) {
    Hashtable h = new Hashtable(); 
    h.put("kb",kb);
    return HtmlUtilAuth.post(site()+":"+port(),path()+"get-ps-tree-goals.html",h,auth());
  }

  public String getPSTreeGoals (String kb) {
    Strings x = getPSTreeGoalsInternal(kb);
    String result = getInfoCommonCode (x);
    return result;
  }

  private Strings getPSTreePrettyInternal(String kb) {
    Hashtable h = new Hashtable(); 
    h.put("kb",kb);
    return HtmlUtilAuth.post(site()+":"+port(),path()+"get-ps-tree-pretty.html",h,auth());
  }

  public String getPSTreePretty (String kb) {
    Strings x = getPSTreePrettyInternal(kb);
    String result = getInfoCommonCode (x);
    return result;
  }

  private Strings getPSTreePrettyNLInternal(String kb) {
    Hashtable h = new Hashtable(); 
    h.put("kb",kb);
    return HtmlUtilAuth.post(site()+":"+port(),path()+"get-ps-tree-pretty-nl.html",h,auth());
  }

  public String getPSTreePrettyNL (String kb) {
    Strings x = getPSTreePrettyNLInternal(kb);
    String result = getInfoCommonCode (x);
    return result;
  }


  private Strings getPSTreeVeryDetailInternal(String kb) {
    Hashtable h = new Hashtable(); 
    h.put("kb",kb);
    return HtmlUtilAuth.post(site()+":"+port(),path()+"get-ps-tree-very-detail.html",h,auth());
  }

  public String getPSTreeVeryDetail (String kb) {
    Strings x = getPSTreeVeryDetailInternal(kb);
    String result = getInfoCommonCode (x);
    return result;
  }

  private Strings getEXEGoalsInternal(String kb) {
    Hashtable h = new Hashtable(); 
    h.put("kb",kb);
    return HtmlUtilAuth.post(site()+":"+port(),path()+"get-exe-tree-goals.html",h,auth());
  }

  public String getEXEGoals (String kb) {
    Strings x = getEXEGoalsInternal(kb);
    String result = getInfoCommonCode (x);
    return result;
  }

  private Strings getEXEPrettyInternal(String kb) {
    Hashtable h = new Hashtable(); 
    h.put("kb",kb);
    return HtmlUtilAuth.post(site()+":"+port(),path()+"get-exe-tree-pretty.html",h,auth());
  }

  public String getEXEPretty (String kb) {
    Strings x = getEXEPrettyInternal(kb);
    String result = getInfoCommonCode (x);
    return result;
  }

  //////////////////////////
  /// support for editor
  //////////////////////////
  private Strings getEditAltsInternal(String kb, String nt, String cap, String name) {
    Hashtable h = new Hashtable(); 
    h.put("context",kb);
    h.put("package", "EXPECT");
    h.put("desc",nt);
    h.put("capability",cap);
    h.put("name", name);
    return HtmlUtilAuth.post(site()+":"+port(),path()+"get-edit-alts.html",h,auth());
  }

  public String getEditAlts (String kb, String nt, String cap, String name) {
    Strings x = getEditAltsInternal(kb, nt, cap, name);
    String result = getInfoCommonCode (x);
    return result;
  }

  private Strings getEditVarsInternal(String kb, String desc) {
    Hashtable h = new Hashtable(); 
    h.put("context",kb);
    h.put("package", "EXPECT");
    h.put("desc",desc);
    return HtmlUtilAuth.post(site()+":"+port(),path()+"get-edit-vars.html",h,auth());
  }

  public String getEditVars (String kb, String desc) {
    Strings x = getEditVarsInternal(kb, desc);
    String result = getInfoCommonCode (x);
    return result;
  }

  private Strings getVarForTypeInternal(String kb, String desc, String type) {
    Hashtable h = new Hashtable(); 
    h.put("context",kb);
    h.put("package", "EXPECT");
    h.put("desc",desc);
    h.put("type",type);
    return HtmlUtilAuth.post(site()+":"+port(),path()+"get-var-for-type.html",h,auth());
  }

  public String getVarForType (String kb, String desc, String type) {
    Strings x = getVarForTypeInternal(kb, desc, type);
    String result = getInfoCommonCode (x);
    return result;
  }



  private Strings getEditMethodInternal(String kb, String name) {
    Hashtable h = new Hashtable(); 
    h.put("context",kb);
    h.put("package", "EXPECT");
    h.put("name",name);
    return HtmlUtilAuth.post(site()+":"+port(),path()+"get-edit-method.html",h,auth());
  }

  public String getEditMethod (String kb, String name) {
    Strings x = getEditMethodInternal(kb, name);
    String result = getInfoCommonCode (x);
    return result;
  }

  private Strings getEditCapOrBodyInternal(String kb, String code, String flag) {
    Hashtable h = new Hashtable(); 
    h.put("context",kb);
    h.put("package", "EXPECT");
    h.put("code",code);
    h.put("flag",flag);
    return HtmlUtilAuth.post(site()+":"+port(),path()+"get-edit-cap-or-body.html",h,auth());
  }

  public String getEditCapOrBody (String kb, String code, String flag) {
    Strings x = getEditCapOrBodyInternal(kb, code, flag);
    String result = getInfoCommonCode (x);
    return result;
  }

  private Strings getSearchedCapabilityInternal(String kb, String name) {
    Hashtable h = new Hashtable(); 
    h.put("context",kb);
    h.put("package", "EXPECT");
    h.put("name",name);
    return HtmlUtilAuth.post(site()+":"+port(),path()+"get-searched-cap.html",h,auth());
  }

  public String getSearchedCapability (String kb, String name) {
    Strings x = getSearchedCapabilityInternal(kb, name);
    String result = getInfoCommonCode (x);
    return result;
  }


}
