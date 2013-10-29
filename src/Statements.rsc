module Statements

syntax Statement
  = "return" Expression
  | Expression 
  | Expression ":=" Expression
  ;
