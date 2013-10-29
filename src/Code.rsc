module Code

import Declarations;
import Statements;
import Comment;
import Offside;


syntax Declaration
  = VarDeclaration
  | DefDeclaration
  | ClassDeclaration
  | TypeDeclaration
  | MethodDeclaration
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
  
syntax InnerDeclaration
  = VarDeclaration
  | DefDeclaration
  | ClassDeclaration
  | TypeDeclaration
  ;

syntax InnerCode
  = InnerDeclaration 
  | Statement
  ;
  
syntax InnerCodeSequence 
  = InnerCode
  | right InnerCodeSequence ";" InnerCodeSequence
  > right seqInner: InnerCodeSequence InnerCodeSequence
  ;

  
InnerCodeSequence seqInner(InnerCodeSequence lhs,  InnerCodeSequence rhs) {
  if (horizontal(lhs, rhs)) {
    filter;
  }
  fail;
}

CodeSequence seq(CodeSequence lhs,  CodeSequence rhs) {
  if (horizontal(lhs, rhs)) {
    filter;
  }
  fail;
}