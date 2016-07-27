module DynGrace

import IO;
import Offside;
import ParseTree;

start syntax Program 
  = CodeSequence
  ;


syntax Statement
  = ret: "return" Expression 
  | ret0: "return"
  | exp: Expression 
  | assign: Expression ":=" Expression 
  ;
  
syntax Declaration
  = var: "var" Identifier Annos? (":=" Expression)? 
  | @Foldable def: "def" Identifier Annos? "=" Expression 
  | @Foldable class:  "class" MethodHeader!prefix!operator!assignment Annos? "{" Extend* CodeSequence "}"
  | @Foldable trait:  "trait" MethodHeader!prefix!operator!assignment Annos? "{" CodeSequence "}"
  | @Foldable method:  "method" MethodHeader Annos? "{" CodeSequence "}"
  ;

syntax Code
  = decl: Declaration ";"?
  | stat: Statement ";"?
  ;
  
syntax CodeSequence // TODO: this should be a proper list (e.g. Code*, but filtering does not seem to work)
  = code: Code 
  | empty: 
  | right seq: CodeSequence!empty CodeSequence!empty 
  ;
  
syntax Annos = "is" {Anno ","}+;

syntax Anno
  = "public" | "writable" | "readable" | "overrides" | "manifest" | "confidential" | "required";

syntax MethodHeader 
  = assignment: Identifier ":=" "(" Identifier ")" 
  | keywords: ArgumentHeader+ 
  | unary: Identifier 
  | operator: OtherOp "(" Identifier ")" 
  | prefix: "prefix" !>> [ \n\r] OtherOp
  ;

syntax ArgumentHeader = Identifier keyword "(" {Identifier ","}+ formals ")";

syntax Extend 
  = "inherit" Expression
  | "use" Expression 
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
  | unarySelf: Identifier () !>> [{(\"\[]
  | bracket parens: OpenParen {Expression ";"}+ OpenParen
  | implicitSelf: ArgumentClause+
  | sendKeyword: Expression Dot ArgumentClause+
  | sendUnary: Expression Dot Identifier () !>> [{(\"\[]
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
 = [!?@#$%^&|~=+\-*/\>\<:.\u2200–\u22FF]+ !>> [!?@#$%^&|~=+\-*/\>\<:.]
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
  
  
syntax ObjectLiteral = "object" Annos? "{" Extend* CodeSequence "}";
  
syntax LineUpLiteral = "[" {Expression ","}+ "]";
  
  
// Lexical stuff
  
lexical Identifier
  = [_]
  | ([a-zA-Z0-9\'] !<< [a-zA-Z][a-zA-Z0-9\']* !>> [a-zA-Z0-9\']) \ Reserved
  ;
  

keyword Reserved 
  = "self" 
  | "inherit" 
  | "class"
  | "object" 
  | "type" 
  | "where" 
  | "def" 
  | "var" 
  | "method" 
  | "prefix" 
  | "alias"
  | "as"
  | "dialect"
  | "exclude"
  | "import"
  | "is"
  | "outer"
  | "required"
  | "return"
  | "Self"
  | "trait"
  | "use"
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

Expression binaryOther(Expression lhs, OtherOp op, Expression rhs) {
  if (lhs is binaryOther, op != lhs.op) {
    filter;
  }
  fail;
}


Code stat(Statement s0, ";"? _) {
  int at = s0@\loc.begin.column;
  int atLine = s0@\loc.begin.line;
  
  for (/Tree s := s0) {
	  if (ArgumentClause a := s, a@\loc.begin.column <= at, a@\loc.begin.line > atLine) {
	    filter;
	  }
	  if (Dot a := s, a@\loc.begin.column <= at, a@\loc.begin.line > atLine) {
	    filter;
	  }
	  if (Slash a := s, a@\loc.begin.column <= at, a@\loc.begin.line > atLine) {
	    filter;
	  }
	  if (Plus a := s, a@\loc.begin.column <= at, a@\loc.begin.line > atLine) {
	    filter;
	  }
	  if (Dash a := s, a@\loc.begin.column <= at, a@\loc.begin.line > atLine) {
	    filter;
	  }
	  if (OpenParen a := s, a@\loc.begin.column <= at, a@\loc.begin.line > atLine) {
	    filter;
	  }
	  if (CloseParen a := s, a@\loc.begin.column <= at, a@\loc.begin.line > atLine) {
	    filter;
	  }
	  if (Identifier a := s, a@\loc.begin.column <= at, a@\loc.begin.line > atLine) {
	    filter;
	  }
	  if (Ellipsis a := s, a@\loc.begin.column <= at, a@\loc.begin.line > atLine) {
	    filter;
	  }
	  if (OtherOp a := s, a@\loc.begin.column <= at, a@\loc.begin.line > atLine) {
	    filter;
	  }
	  if (Argument a := s, a@\loc.begin.column <= at, a@\loc.begin.line > atLine) {
	    filter;
	  }
	  if (Expression e := s, e@\loc.begin.column <= at, e@\loc.begin.line > atLine) {
	    //println("Stat Offside expression: <e>");
	    filter;
	  }
	}
  fail;
}

Code decl(Declaration d, ";"? _) {
  int at = d@\loc.begin.column;
  int atLine = d@\loc.begin.line;
  if (/ArgumentClause a := d, a@\loc.begin.column <= at, a@\loc.begin.line > atLine) {
    filter;
  }
  if (/Dot a := d, a@\loc.begin.column <= at, a@\loc.begin.line > atLine) {
    filter;
  }
  if (/Slash a := d, a@\loc.begin.column <= at, a@\loc.begin.line > atLine) {
    filter;
  }
  if (/Plus a := d, a@\loc.begin.column <= at, a@\loc.begin.line > atLine) {
    filter;
  }
  if (/Dash a := d, a@\loc.begin.column <= at, a@\loc.begin.line > atLine) {
    filter;
  }
  if (/OpenParen a := d, a@\loc.begin.column <= at, a@\loc.begin.line > atLine) {
    filter;
  }
  if (/CloseParen a := d, a@\loc.begin.column <= at, a@\loc.begin.line > atLine) {
    filter;
  }
  if (/Identifier a := d, a@\loc.begin.column <= at, a@\loc.begin.line > atLine) {
    filter;
  }
  if (/Ellipsis a := d, a@\loc.begin.column <= at, a@\loc.begin.line > atLine) {
    filter;
  }
  if (/OtherOp a := d, a@\loc.begin.column <= at, a@\loc.begin.line > atLine) {
    filter;
  }
  if (/Argument a := d, a@\loc.begin.column <= at, a@\loc.begin.line > atLine) {
    filter;
  }
  if (/Expression e := d, e@\loc.begin.column <= at, e@\loc.begin.line > atLine) {
    //println("Stat Offside expression: <e>");
    filter;
  }
  fail;  
}

bool endsWithSemi((Code)`<Statement c>;`) = true;
bool endsWithSemi((Code)`<Declaration c>;`) = true;
default bool endsWithSemi(Code _) = false;

bool endsWithSemi((CodeSequence)`<Code c>`) = endsWithSemi(c);
bool endsWithSemi((CodeSequence)`<CodeSequence c1> <CodeSequence c2>`) = endsWithSemi(c2);

// There's something wrong with filtering of lists, so we use binary
// sequencing
CodeSequence seq(CodeSequence lhs, CodeSequence rhs) {
  if (horizontal(lhs, rhs) && !endsWithSemi(lhs)) {
    filter;
  }
  fail;
}



