module Expressions

import Lexical;
import Literals;
import Layout;
import IO;
import Offside;


syntax UnaryRequest
  = Identifier GenericActuals? () !>> [{(\"]
  ;
  
syntax Expression 
  = Literal
  | unarySelf: UnaryRequest
  | implicitSelf: ArgumentClause2 //+
  | nonNakedSuper: [s][u][p][e][r] () >> [!?@#$%^&|~=+-*/\>\<:.]
  //??? | Expression "{" {Expression ","}+ "}"
  | Expression "." Identifier GenericActuals? Argument ArgumentClause?
  | Expression "." UnaryRequest
  | Expression "[" {Expression ","}+ "]"
  > OtherOp+ "super"  
  |OtherOp Expression
  > left (
  Expression "*" Expression
  | Expression "/" Expression
  )
  > left (
    Expression "+" Expression
    | Expression "-" Expression
  )
  > left binaryOther: Expression OtherOp op Expression 
  | "(" {Expression ";"}+ ")"
  ;
  

syntax Argument
 = "(" {Expression ","}+ ")"
 | BlockLiteral
 | StringLiteral
 ;
 
syntax ArgumentClause2
  = Identifier Argument
  | left conc: ArgumentClause2 ArgumentClause2
  ;


syntax ArgumentClause
  = Identifier Argument 
  ; 

lexical Operator 
 = [!?@#$%^&|~=+\-*/\>\<:.]+ !>> [!?@#$%^&|~=+-*/\>\<:.]
 ;
 
keyword ReservedOperator
  = "*" | "/" | "+" | "-" | "=" | "." | ":" | ";" | ":=" | "-\>"
  ;

syntax OtherOp 
  = Operator \ ReservedOperator
  ;
  
Expression binaryOther(Expression lhs, OtherOp op, Expression rhs) {
  if (lhs is binaryOther, op != lhs.op) 
    filter;
  if (vertical(lhs, op)) {
    filter;
  }
  fail;
}

ArgumentClause2 conc(ArgumentClause2 lhs, ArgumentClause2 rhs) {
  if (vertical(lhs, rhs)) 
    filter;
  fail;
}
