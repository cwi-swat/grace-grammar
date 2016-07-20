module Statements

import Offside;
import ParseTree;

syntax Statement
  = ret: "return" Expression
  | exp: Expression 
  | assign: Expression ":=" Expression
  ;

  
Statement ret(Expression e) {
   bool leftMost(Tree e2) =
     e@\loc.begin.column == e2@\loc.begin.column
        && e@\loc.begin.line == e2@\loc.begin.line;
     
   top-down visit (e) {
     case ArgumentClause e2: {
       if (!leftMost(e2), offSide(e, e2)) {
         filter;
       }
     }
     
     case Expression e2: {
       if (!leftMost(e2), offSide(e, e2)) {
         filter;
       }
     }
   }
   fail;
}

Statement exp(Expression e) {
   //println("Maybe filter <e>");
   bool leftMost(Tree e2) =
     e@\loc.begin.column == e2@\loc.begin.column
        && e@\loc.begin.line == e2@\loc.begin.line;
        
   bool isExcluded(Tree t) {
     if (lit("}") := t.prod.def) {
       return true;
     }
     
     if (t.prod.def is layouts) {
       return true;
     }
     
     if ("<t>" == "") {
       return true;
     }
     
     return false;
   }
     
     
   Tree filterIt(Tree e2) {
     if (offSide(e, e2)) {
       //println("Filtering |<e2>|");
       //rprintln(e2);
       filter;
     }
     return e2;
   }
     
   top-down-break visit (e) {
     case Tree e2 => filterIt(e2)
       when e2@\loc?, !leftMost(e2), !isExcluded(e2)
   }
   
   fail;
}