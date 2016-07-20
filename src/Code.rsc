module Code

import Offside;


syntax Declaration
  = var: VarDeclaration
  | def: DefDeclaration
  | class: ClassDeclaration
  | method: MethodDeclaration
  ;

syntax Code
  = Declaration  
  | Statement 
  ;
  
syntax CodeSequence 
  = Code
  | right CodeSequence ";" CodeSequence
  > right seq: CodeSequence CodeSequence
  ;
  
//syntax InnerDeclaration
//  = VarDeclaration
//  | DefDeclaration
//  | ClassDeclaration
//  ;
//
//syntax InnerCode
//  = InnerDeclaration 
//  | Statement
//  ;
//  
//syntax InnerCodeSequence 
//  = InnerCode
//  | right InnerCodeSequence ";" InnerCodeSequence
//  > right seqInner: InnerCodeSequence InnerCodeSequence
//  ;

  
//InnerCodeSequence seqInner(InnerCodeSequence lhs,  InnerCodeSequence rhs) {
//  //println("SEQInner");
//  if (horizontal(lhs, rhs)) {
//    filter;
//  }
//  fail;
//}

CodeSequence seq(CodeSequence lhs,  CodeSequence rhs) {
  //println("SEQ");
  //println("LHS = <lhs>");
  //println("RHS = <rhs>");
  if (horizontal(lhs, rhs)) {
    //println("Filtering seq");
    filter;
  }
  fail;
}