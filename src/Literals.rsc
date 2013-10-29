module Literals

import Lexical;
import Declarations;
import Code;
import Expressions;
import Statements;

syntax Literal
  = StringLiteral
  | SelfLiteral
  | BlockLiteral
  | NumberLiteral
  | ObjectLiteral
  | TupleLiteral
  | TypeLiteral
  ;


lexical StringLiteral 
  = [\"] StringChar* [\"]
  ;
   
   
lexical StringChar 
  = EscapeChar
  | ![\\\"\t\f\b] // does \" belong here?
  ;  

lexical EscapeChar 
  = [\\] [\\\"\'{}bnrtlfe ]
  ;

// NB: otherChars, needs to escape  \

syntax BlockLiteral
  = "{" (BlockSignature "-\>")? InnerCodeSequence? "}"
  ;
  
syntax BlockSignature
  = MatchBinding
  | BlockFormals
  ;

syntax BlockFormals 
  //= {Formal ","}* // Formal is amb with MatchBinding
  // so we let a single formal with type expression
  // always be a MatchBinding
  = Formal "," {Formal ","}+
  ;
   
syntax MatchBinding
  = Identifier MatchExtra?
  | Literal MatchExtra?
  | "(" Expression ")" MatchExtra?
  ;   
  
syntax MatchExtra
  = ":" TypeExpression MatchingBlockTail?
  ;
   
syntax MatchingBlockTail 
  = "(" {MatchBinding ","}+ ")"
  ;
  
  
syntax SelfLiteral 
  = "self"
  ;
   
lexical NumberLiteral 
  = [0-9]+ !>> [0-9] 
  ;
  
syntax ObjectLiteral 
  = "object" "{" InheritsClause? CodeSequence? "}"
  ;
  
syntax TupleLiteral 
  = "[" {Expression ","}+ "]"
  ;

syntax TypeLiteral 
  = "type" NakedTypeLiteral
  ;
  
  
syntax MethodType
  = MethodHeader MethodReturnType ";"
  | MethodHeader MethodReturnType $
  | MethodHeader MethodReturnType WhereClause? 
  ;

// TODO: check this!
syntax NakedTypeLiteral 
  =  "{" MethodType* "}"
  ;
  
