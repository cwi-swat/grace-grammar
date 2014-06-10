module Lexical

lexical Identifier
  = [_]
  | ([a-zA-Z0-9\'] !<< [a-zA-Z][a-zA-Z0-9\']* !>> [a-zA-Z0-9\']) \ Reserved
  ;
  

keyword Reserved 
  = "self" 
  | "extends" 
  | "inherits" 
  | "class"
  | "object" 
  | "type" 
  | "where" 
  | "def" 
  | "var" 
  | "method" 
  | "prefix" 
  | "interface"
  // not in the spec
  | "return"
  ; // more to come




  