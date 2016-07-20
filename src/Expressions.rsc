module Expressions

//extend Lexical;
//extend Literals;
//extend Layout;
import IO;
import Offside;


syntax UnaryRequest
  = Identifier () !>> [{(\"]
  ;
  
syntax Expression 
  = lit: Literal
  | unarySelf: UnaryRequest
  | implicitSelf: ArgumentClause+
  | Expression "." Identifier Argument ArgumentClause*
  | Expression "." UnaryRequest
  > OtherOp Expression
  > left (
    Expression "*" Expression
  | Expression "/" Expression
  )
  > left (
    Expression "+" Expression
  | Expression "-" !>> "\>" Expression
  )
  > left binaryOther: Expression OtherOp op Expression 
  | "(" {Expression ";"}+ ")"
  ;
  

syntax Argument
 = "(" {Expression ","}+ ")"
 | BlockLiteral
 | StringLiteral
 | NumberLiteral
 ;
 
syntax ArgumentClause
  = Identifier Argument
  ;


lexical Operator 
 = [!?@#$%^&|~=+\-*/\>\<:.]+ !>> [!?@#$%^&|~=+\-*/\>\<:.]
 ;
 
keyword ReservedOperator
  = "*" | "/" | "+" | "-"  
  | "=" | "." | ":" | ";" | ":=" | "-\>" | "→"
  ;

syntax OtherOp 
  = Operator \ ReservedOperator
  ;
  
Expression binaryOther(Expression lhs, OtherOp op, Expression rhs) {
  if (lhs is binaryOther, op != lhs.op) 
    filter;
  //if (vertical(lhs, op)) {
  //  filter;
  //}
  fail;
}

//ArgumentClause2 conc(ArgumentClause2 lhs, ArgumentClause2 rhs) {
//  if (vertical(lhs, rhs)) 
//    filter;
//  fail;
//}
