module Statements

import Offside;
import ParseTree;

syntax Statement
  = ret: "return" Expression
  | exp: Expression 
  | assign: Expression ":=" Expression
  ;

