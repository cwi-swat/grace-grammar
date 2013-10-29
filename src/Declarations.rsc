module Declarations

import Expressions;
import Statements;
import Lexical;
import Literals;
import Code;

// Change: WhereClause? -> WhereClause
// (because WhereClause = Where*)

syntax VarDeclaration 
  = "var" Identifier  (":" TypeExpression)? (":=" Expression)?
  ;

syntax DefDeclaration 
  = "def" Identifier  (":" TypeExpression)? "=" Expression
  ;

syntax MethodDeclaration 
  = "method" MethodHeader MethodReturnType? WhereClause 
       "{" InnerCodeSequence? "}"
  ;
  
syntax ClassDeclaration 
  = "class" Identifier "." ClassHeader MethodReturnType? WhereClause
     "{" InheritsClause? CodeSequence? "}";

// TODO: how to do this in rascal??
//warning: order here is significant!

syntax MethodHeader 
  = accessingAssignment: "[" "]" ":=" GenericFormals? MethodFormals 
  | accessing: "[" "]" GenericFormals? MethodFormals 
  | assignment: Identifier ":=" OneMethodFormal 
  | Identifier GenericFormals? MethodFormals ArgumentHeader* 
  | unary: Identifier GenericFormals? 
  | operator: OtherOp OneMethodFormal 
  | prefix: "prefix" !>> [ \n\r] OtherOp
  ;


syntax ArgumentHeader
  = Identifier MethodFormals
  ;

syntax ClassHeader 
  = Identifier GenericFormals? MethodFormals ArgumentHeader*  
  | Identifier GenericFormals? 
  ;
  
syntax InheritsClause 
  = "inherits" Expression 
  ;  

syntax ArgumentHeader 
  = Identifier MethodFormals
  ;


syntax MethodReturnType 
  = "-\>" TypeExpression
  ;

syntax Formal 
  = Identifier (":" TypeExpression)?
  ;
  
syntax MethodFormals 
  = "(" {Formal ","}+ ")"
  ;

syntax OneMethodFormal 
  = "(" Formal ")"
  ;
  
syntax TypeDeclaration 
  = "type" Identifier GenericFormals? "=" TypeExpression WhereClause $
  | "type" Identifier GenericFormals? "=" TypeExpression WhereClause ";"
  ;

syntax TypeExpression 
   = non-assoc (
         left TypeExpression "|" TypeExpression
         | left  TypeExpression "&" TypeExpression
         | left TypeExpression "+" TypeExpression
   )
   |  NakedTypeLiteral
   |  Literal
   | path: ("super" ".")? {IdGenericActuals "."}+ 
   |  bracket "(" TypeExpression ")"
   ;

syntax IdGenericActuals 
  = Identifier GenericActuals?
  ;
  
  
// "generics" 
syntax GenericActuals 
  = "\<" {TypeExpression ","}+ "\>"
  ;

syntax GenericFormals 
  = "\<" {Identifier ","}+ "\>"
  ;



syntax Where
  = "where" Expression $
  | "where" Expression ";"
  ;
  
// TODO: this should also be a binary op.
// and do some kind of offside.

syntax WhereClause 
  = Where*
  ;
  

