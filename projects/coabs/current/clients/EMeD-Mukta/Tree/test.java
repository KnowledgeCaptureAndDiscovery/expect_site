/*  
 * Search.java  4/22/98
 */

/*
 * Main program: use Ontology, Adpative Form, and meta info in DB
 *               and generate DB table name and initial attribute constraints
 *               The table name and the constraints are stored in "af_temp_file"
 * @author Jihie Kim
 */
 
package Tree;
import java.lang.*;
import java.io.*;
import java.util.*;
import java.net.*;

public class test {
  public test() {
      
  }
    public static void main(String[] args) {
      //treeRenderer app = new treeRenderer("<NODE><goalNode name=\"NIL\"> NIL </goalNode>   <NODE><goalNode name=\"NIL\"> (ESTIMATE (OBJ (SPEC-OF TIME))                       (FOR (INST-OF WORKAROUND-STEP))) </goalNode>      <NODE><goalNode name=\"NARROW-GAP\"> (ESTIMATE (OBJ (SPEC-OF TIME))                      (FOR                               (INST-OF                                NARROW-GAP-WITH-BULLDOZER))) </goalNode>      </NODE>      <NODE><goalNode name=\"EMPLACE-AVLB-STEP\"> (ESTIMATE (OBJ (SPEC-OF TIME))                                     (FOR (INST-OF EMPLACE-AVLB))) </goalNode>      </NODE>   </NODE>   <NODE><goalNode name=\"DIVIDE\"> (DIVIDE (OBJ (INST-OF NUMBER))                          (BY (INST-OF NUMBER))) </goalNode>   </NODE>   <NODE><goalNode name=\"NIL\"> (FIND (OBJ (SPEC-OF THING))                            (FOR (INST-OF THING))) </goalNode>      <NODE><goalNode name=\"GET-STANDARD-RATE-FOR-BULLDOZER\"> (FIND                                                   (OBJ                                                    (SPEC-OF                                                     STANDARD-BULLDOZING-RATE))                                                   (OF                                                    (INST-OF                                                     MILITARY-DOZER))) </goalNode>      </NODE>      <NODE><goalNode name=\"NIL\"> (FIND (OBJ (SPEC-OF THING))                            (FOR (INST-OF MOVE-EARTH-STUFF))) </goalNode>         <NODE><goalNode name=\"GET-DIRT-VOLUME\"> (FIND (OBJ (SPEC-OF DIRT-VOLUME))                                        (FOR                                         (INST-OF                                          MOVE-EARTH-STUFF))) </goalNode>         </NODE>         <NODE><goalNode name=\"GET-STANDARD-BULLDOZING-RATE\"> (FIND                                                (OBJ                                                 (SPEC-OF                                                  STANDARD-BULLDOZING-RATE))                                                (FOR                                                 (INST-OF                                                  BULLDOZE-REGION))) </goalNode>         </NODE>      </NODE>      <NODE><goalNode name=\"GET-EMPLACEMENT-TIME\"> (FIND                                        (OBJ (SPEC-OF TIME-FOR-EMPLACEMENT))                                        (FOR                                         (INST-OF                                          MILITARY-BRIDGE))) </goalNode>      </NODE>   </NODE> </NODE>");
      //treeRenderer app = new treeRenderer(" <NODE><goalInfoNode body=\"NIL\" name=\"NIL\"> NIL </goalInfoNode>   <NODE><goalInfoNode body=\"(FIND (OBJ (SPEC-OF TIME-FOR-EMPLACEMENT)) (FOR (BRIDGE-OF ?S)))\" name=\"EMPLACE-AVLB-STEP\"> (ESTIMATE                                                                                                                 (OBJ                                                                                                                  (?T                                                                                                                   IS                                                                                                                   (SPEC-OF                                                                                                                    TIME)))                                                                                                                 (FOR                                                                                                                  (?S                                                                                                                   IS                                                                                                                   (INST-OF                                                                                                                    EMPLACE-AVLB)))) </goalInfoNode>      <NODE><goalInfoNode body=\"(EMPLACEMENT-TIME ?B)\" name=\"GET-EMPLACEMENT-TIME\"> (FIND                                                                         (OBJ                                                                          (?T                                                                           IS                                                                           (SPEC-OF                                                                            TIME-FOR-EMPLACEMENT)))                                                                         (FOR                                                                          (?B                                                                           IS                                                                           (INST-OF                                                                            MILITARY-BRIDGE)))) </goalInfoNode>      </NODE>   </NODE>   <NODE><goalInfoNode body=\"(DIVIDE (OBJ (FIND (OBJ (SPEC-OF DIRT-VOLUME)) (FOR ?S)))        (BY (FIND (OBJ (SPEC-OF STANDARD-BULLDOZING-RATE)) (FOR ?S))))\" name=\"NARROW-GAP\"> (ESTIMATE                                                                                            (OBJ                                                                                             (?T                                                                                              IS                                                                                              (SPEC-OF                                                                                               TIME)))                                                                                            (FOR                                                                                             (?S                                                                                              IS                                                                                              (INST-OF                                                                                               NARROW-GAP-WITH-BULLDOZER)))) </goalInfoNode>      <NODE><goalInfoNode body=\"(EARTH-VOLUME ?S)\" name=\"GET-DIRT-VOLUME\"> (FIND                                                                (OBJ                                                                 (?V                                                                  IS                                                                  (SPEC-OF                                                                   DIRT-VOLUME)))                                                                (FOR                                                                 (?S                                                                  IS                                                                  (INST-OF                                                                   MOVE-EARTH-STUFF)))) </goalInfoNode>      </NODE>      <NODE><goalInfoNode body=\"(FIND (OBJ (SPEC-OF STANDARD-BULLDOZING-RATE)) (OF (DOZER-OF ?S)))\" name=\"GET-STANDARD-BULLDOZING-RATE\"> (FIND                                                                                                                              (OBJ                                                                                                                               (?R                                                                                                                                IS                                                                                                                                (SPEC-OF                                                                                                                                 STANDARD-BULLDOZING-RATE)))                                                                                                                              (FOR                                                                                                                               (?S                                                                                                                                IS                                                                                                                                (INST-OF                                                                                                                                 BULLDOZE-REGION)))) </goalInfoNode>         <NODE><goalInfoNode body=\"170\" name=\"GET-STANDARD-RATE-FOR-BULLDOZER\"> (FIND                                                                  (OBJ                                                                   (?R                                                                    IS                                                                    (SPEC-OF                                                                     STANDARD-BULLDOZING-RATE)))                                                                  (OF                                                                   (?D                                                                    IS                                                                    (INST-OF                                                                     MILITARY-DOZER)))) </goalInfoNode>         </NODE>      </NODE>      <NODE><goalInfoNode body=\"(PRIMITIVE-DIVIDE-NUMBERS ?N1 ?N2)\" name=\"DIVIDE\"> (DIVIDE                                                                        (OBJ                                                                         (?N1                                                                          IS                                                                          (INST-OF                                                                           NUMBER)))                                                                        (BY                                                                         (?N2                                                                          IS                                                                          (INST-OF                                                                           NUMBER)))) </goalInfoNode>      </NODE>   </NODE> </NODE>");

      treeRenderer app = new treeRenderer(" <NODE><goalInfoNode result=\"NIL\" edt=\"NIL\" body=\"NIL\" name=\"NIL\"> NIL </goalInfoNode>   <NODE><goalInfoNode result=\"(INST-OF NUMBER)\" edt=\"UNDEFINED\" body=\"(DIVIDE (OBJ (FIND (OBJ (SPEC-OF DIRT-VOLUME)) (FOR ?S)))        (BY (FIND (OBJ (SPEC-OF STANDARD-BULLDOZING-RATE)) (FOR ?S))))\" name=\"NARROW-GAP\"> (ESTIMATE                                                                                            (OBJ                                                                                             (?T                                                                                              IS                                                                                              (SPEC-OF                                                                                               TIME)))                                                                                            (FOR                                                                                             (?S                                                                                              IS                                                                                              (INST-OF                                                                                               NARROW-GAP-WITH-BULLDOZER)))) </goalInfoNode>      <NODE><goalInfoNode result=\"(INST-OF NUMBER)\" edt=\"(INST-OF VOLUME-QUANTITY&NUMBER)\" body=\"(EARTH-VOLUME ?S)\" name=\"GET-DIRT-VOLUME\"> (FIND                                                                                                                                 (OBJ                                                                                                                                  (?V                                                                                                                                   IS                                                                                                                                   (SPEC-OF                                                                                                                                    DIRT-VOLUME)))                                                                                                                                 (FOR                                                                                                                                  (?S                                                                                                                                   IS                                                                                                                                   (INST-OF                                                                                                                                    MOVE-EARTH-STUFF)))) </goalInfoNode>      </NODE>   </NODE> </NODE>"); 
      app.drawTree(); 


      //////////////////////
    }
    
}
