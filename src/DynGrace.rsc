module DynGrace

import ParseTree;

start syntax Program = Code*;


syntax MARKER
  = "§";

syntax Code
  = decl: Declaration ";"
  | stat: Statement ";"
  | decl: Declaration MARKER
  | stat: Statement MARKER
  ;


// last element in a single-line block has optional ; and never §
syntax CodeSequence
  = Code* Declaration 
  | Code* Statement   
  | Code* Declaration ";"
  | Code* Statement ";"
  | Code* Declaration MARKER  
  | Code* Statement MARKER  
  | /* empty */
  ;

syntax Statement
  = ret: "return" Expression 
  | ret0: "return"
  | exp: Expression 
  | assign: Expression ":=" Expression 
  ;
  
syntax Declaration
  = var: "var" Identifier Annos? (":=" Expression)? 
  | def: "def" Identifier Annos? "=" Expression 
  | @Foldable class: "class" MethodHeader!prefix!operator!assignment Annos? "{" Extend* CodeSequence "}"
  | trait: "trait" MethodHeader!prefix!operator!assignment Annos? "{" CodeSequence "}"
  | @Foldable method:  "method" MethodHeader Annos? "{" CodeSequence "}"
  ;

  
syntax Annos = "is" {Anno ","}+;

syntax Anno
  = "public" | "writable" | "readable" | "overrides" | "manifest" 
  | "confidential" | "required"
  ;

syntax MethodHeader 
  = assignment: Identifier ":=" "(" Identifier ")" 
  | keywords: ArgumentHeader+ 
  | unary: Identifier 
  | operator: OtherOp "(" Identifier ")" 
  | prefix: "prefix" !>> [ \n\r] OtherOp
  ;

syntax ArgumentHeader = Identifier keyword "(" {Identifier ","}+ formals ")";

syntax Extend 
  = inherit: "inherit" Expression 
  | inherit: "inherit" Expression MARKER
  | use: "use" Expression 
  | use: "use" Expression MARKER
  ;  


// Expressions

syntax Dot = ".";
syntax Star = "*";
syntax Slash = "/";
syntax Plus = "+";
syntax Dash = "-";
syntax OpenParen = "(";
syntax CloseParen = ")";
syntax Ellipsis = "...";
  
syntax Expression 
  = lit: Literal
  | ellipsis: Ellipsis
  | implicitUnary: Identifier () !>> [{(\"\[]
  | bracket parens: OpenParen {Expression ";"}+ CloseParen
  | implicitMulti: ArgumentClause+
  | multi: Expression Dot ArgumentClause+
  | unary: Expression Dot Identifier () !>> [{(\"\[]
  > prefix: OtherOp Expression
  > left (
    star: Expression Star Expression
  | slash: Expression Slash Expression
  )
  > left (
    plus: Expression Plus Expression
  | dash: Expression Dash !>> "\>" !>> [0-9] Expression
  )
  > left binaryOther: Expression OtherOp op Expression 
  ;
  

syntax Argument
 = exps: OpenParen {Expression ","}+ CloseParen
 | block: BlockLiteral
 | string: StringLiteral
 | number: NumberLiteral
 | lineUp: LineUpLiteral
 ;
 
syntax ArgumentClause
  = Identifier Argument
  ;

lexical Operator 
 = [!?@#$%^&|~=+\-*/\>\<:.\u2200–\u22FF]+ !>> [!?@#$%^&|~=+\-*/\>\<:.\u2200–\u22FF]
 ;
 
keyword ReservedOperator
  = "." | "..." | ":=" | "-" | "+" | "*" | "/" | "\<" | "\>" | "-\>" | "→" | "[" | "]";

syntax OtherOp 
  = Operator \ ReservedOperator
  ;
  
// Literals

syntax Literal
  = StringLiteral
  | SelfLiteral
  | BlockLiteral
  | NumberLiteral
  | ObjectLiteral
  | LineUpLiteral
  ;

lexical StringLiteral = [\"] StringChar* [\"];
   
lexical StringChar 
  = EscapeChar
  | ![\\\"\t\f\b] // does \" belong here?
  ;  

lexical EscapeChar = [\\] [\\\"\'{}bnrtlfe ];

// NB: otherChars, needs to escape  \

lexical Arrow = "→" | "-\>";

syntax BlockLiteral
  // TODO: check, no methods allowed in code sequence
  = noArgs: "{" CodeSequence body "}"
  | withArgs: "{" {Identifier ","}+ formals Arrow CodeSequence body "}"
  ;
  
syntax SelfLiteral = "self";
   
lexical Int = [+\-]? [0-9]+ !>> [0-9];

lexical Float = Int "." [0-9]+ !>> [0-9] ([eE] Int)?;

lexical Radix = ([0]|[2-9]|([1-2][0-9])|([3][1-5])) "x" [0-9A-Za-z]+ !>> [0-9A-Za-z];
   
syntax NumberLiteral 
  = integer: Int  
  | float: Float
  | radix: Radix
  ;
  
  
syntax ObjectLiteral = @Foldable "object" Annos? "{" Extend* CodeSequence "}";
  
syntax LineUpLiteral = "[" {Expression ","}+ "]";
  
  
// Lexical stuff
  
lexical Identifier
  = [_]
  | ([a-zA-Z0-9\'] !<< [a-zA-Z][a-zA-Z0-9\']* !>> [a-zA-Z0-9\']) \ Reserved
  ;
  

keyword Reserved 
  = "self" | "inherit" | "class" | "object" | "type" | "where" | "def" | "var" 
  | "method" | "prefix" | "alias" | "as" | "dialect" | "exclude" | "import"
  | "is" | "outer" | "required" | "return" | "Self" | "trait" | "use"
  ;

layout Default = LAYOUT* !>> [\ \n\r] !>> "//";

lexical LAYOUT
  = Comment 
  | [\ \n\r] 
  ;

lexical Comment = @category="Comment" "//" ![\n\r]* $ ;
  
/*
 * Post-parse disambiguation
 */

// Reject direct binary operator nesting with different operators
Expression binaryOther(Expression lhs, OtherOp op, Expression rhs) {
  if (lhs is binaryOther, op != lhs.op) {
    filter;
  }
  fail;
}





