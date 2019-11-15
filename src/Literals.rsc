module Literals

extend Lexical;
extend Declarations;
extend Code;
extend Expressions;
extend Statements;

syntax Literal
  = StringLiteral
  | SelfLiteral
  | BlockLiteral
  | NumberLiteral
  | ObjectLiteral
  | LineUp
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

lexical Arrow
  = "→"
  | "-\>"
  ;

syntax BlockLiteral
  = noArgs: "{" Code* "}"
  | withArgs: "{" BlockSignature Arrow Code* "}"
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
  = ":" Expression /* was TypeExpression */ MatchingBlockTail?
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
  = "object" "{" InheritsClause? Code* "}"
  ;
  
syntax LineUp 
  = "[" {Expression ","}+ "]"
  ;

  
