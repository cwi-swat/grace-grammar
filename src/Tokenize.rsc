module Tokenize

extend Lexical;
extend Layout;
extend Comment;
extend Literals;
extend Expressions;

start syntax TokenStream
  = Token*
  ;
  
  /*
  
  Note to self
  The infix operators act as line continuations
  
  */
  
syntax Token
  = StringLiteral
  | "{" Token* "}"
  | "(" Token* ")"
  | NumberLiteral
  | "[" Token* "]"
  | Reserved
  | Identifier
  | ReservedOperator
  | Operator
  | ","
  ;


