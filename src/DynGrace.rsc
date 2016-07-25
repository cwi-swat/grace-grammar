module DynGrace

import IO;
import Offside;
import ParseTree;

start syntax Program 
  = CodeSequence
  ;


// Statements

syntax Statement
  = ret: "return" Expression 
  | exp: Expression 
  | assign: Expression ":=" Expression 
  ;
  
syntax Declaration
  = var: "var" Identifier Annos? (":=" Expression)? 
  | @Foldable def: "def" Identifier Annos? "=" Expression 
  | @Foldable class:  "class" MethodHeader Annos? "{" InheritsClause? CodeSequence? "}"
  | @Foldable trait:  "trait" MethodHeader Annos? "{" CodeSequence? "}"
   // make check that disallows methods in methods.
  | @Foldable method:  "method" MethodHeader Annos? "{" CodeSequence? "}"
  ;

syntax Code
  = decl: Declaration  ";"?
  | stat: Statement ";"?
  ;
  
syntax CodeSequence 
  = Code 
  | right seq: CodeSequence CodeSequence 
  ;
  
// Declarations

syntax Annos
  = "is" {Anno ","}+ 
  ;

syntax Anno
  = "public"
  | "writable"
  | "readable"
  | "overrides"
  | "manifest"
  | "confidential"
  ;


syntax MethodHeader 
  = assignment: Identifier ":=" OneMethodFormal 
  | call: Identifier MethodFormals ArgumentHeader* 
  | unary: Identifier GenericFormals? 
  | operator: OtherOp OneMethodFormal 
  | prefix: "prefix" !>> [ \n\r] OtherOp
  ;


syntax ArgumentHeader
  = Identifier MethodFormals
  ;

syntax ClassHeader 
  = Identifier MethodFormals ArgumentHeader*  
  | Identifier 
  ;
  
syntax InheritsClause 
  = "inherit" Expression 
  ;  

syntax ArgumentHeader 
  = Identifier MethodFormals
  ;


syntax Formal 
  = Identifier 
  ;
  
syntax MethodFormals 
  = "(" {Formal ","}+ ")"
  ;

syntax OneMethodFormal 
  = "(" Formal ")"
  ;

// Expressions

syntax UnaryRequest
  = Identifier () !>> [{(\"\[]
  ;
  
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
  | unarySelf: UnaryRequest
  | bracket parens: OpenParen {Expression ";"}+ OpenParen
  | implicitSelf: ArgumentClause+
  | Expression Dot Identifier Argument ArgumentClause*
  | Expression Dot UnaryRequest
  > OtherOp Expression
  > left (
    Expression Star Expression
  | Expression Slash Expression
  )
  > left (
    Expression Plus Expression
  | Expression Dash !>> "\>" Expression
  )
  > left binaryOther: Expression OtherOp op Expression 
  ;
  

syntax Argument
 = OpenParen {Expression ","}+ CloseParen
 | BlockLiteral
 | StringLiteral
 | NumberLiteral
 | LineUp
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
  
// Literals

syntax Literal
  = StringLiteral
  | SelfLiteral
  | BlockLiteral
  | NumberLiteral
  | ObjectLiteral
  | LineUp
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
  = noArgs: "{" CodeSequence? "}"
  | withArgs: "{" BlockSignature Arrow CodeSequence? "}"
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
  = "object" Annos? "{" InheritsClause? CodeSequence? "}"
  ;
  
syntax LineUp 
  = "[" {Expression ","}+ "]"
  ;
  
  
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

layout Default
  = LAYOUT* !>> [\ \n\r] !>> "//";

lexical LAYOUT
  = Comment 
  | [\ \n\r] 
  ;

lexical Comment
  = @category="Comment" "//" ![\n\r]* $
  ;
  
  
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
	  if (UnaryRequest a := s, a@\loc.begin.column <= at, a@\loc.begin.line > atLine) {
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
  if (/UnaryRequest a := d, a@\loc.begin.column <= at, a@\loc.begin.line > atLine) {
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



