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
  = var: "var" Identifier Modifier? (":=" Expression)? 
  | @Foldable def: "def" Identifier Modifier? "=" Expression 
  | @Foldable class:  "class" MethodHeader "{" InheritsClause? CodeSequence? "}"
  | @Foldable trait:  "trait" MethodHeader "{" CodeSequence? "}"
   // make check that disallows methods in methods.
  | @Foldable method:  "method" MethodHeader "{" CodeSequence? "}"
  ;

syntax Code
  = decl: Declaration  ";"?
  | stat: Statement ";"?
  ;
  
syntax CodeSequence 
  //= Code ";"?
  ////| right CodeSequence ";" CodeSequence
  //| right seq: CodeSequence CodeSequence
  = Code 
  | right seq: CodeSequence CodeSequence 
  //= codePlus: Code+
  ;
  
// Declarations

syntax Modifier
  = "is" "public"
  | "is" "readable"
  | "is" "confidential"
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
  = Identifier () !>> [{(\"]
  ;
  
syntax Dot = ".";
syntax Star = "*";
syntax Slash = "/";
syntax Plus = "+";
syntax Dash = "-";
syntax OpenParen = "(";
syntax CloseParen = ")";
  
syntax Expression 
  = lit: Literal
  | unarySelf: UnaryRequest
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
  | OpenParen {Expression ";"}+ OpenParen
  ;
  

syntax Argument
 = OpenParen {Expression ","}+ CloseParen
 | BlockLiteral
 | StringLiteral
 | NumberLiteral
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
  = "object" "{" InheritsClause? CodeSequence? "}"
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
  if (lhs is binaryOther, op != lhs.op) 
    filter;
  //if (vertical(lhs, op)) {
  //  filter;
  //}
  fail;
}

//Statement ret(Expression e) {
//   bool leftMost(Tree e2) =
//     e@\loc.begin.column == e2@\loc.begin.column
//        && e@\loc.begin.line == e2@\loc.begin.line;
//     
//   top-down visit (e) {
//     case ArgumentClause e2: {
//       if (!leftMost(e2), offSide(e, e2)) {
//         filter;
//       }
//     }
//     
//     case Expression e2: {
//       if (!leftMost(e2), offSide(e, e2)) {
//         filter;
//       }
//     }
//   }
//   fail;
//}
//
//Statement exp(Expression e) {
//   //println("Maybe filter <e>");
//   bool leftMost(Tree e2) =
//     e@\loc.begin.column == e2@\loc.begin.column
//        && e@\loc.begin.line == e2@\loc.begin.line;
//        
//   bool isExcluded(Tree t) {
//     if (lit("}") := t.prod.def) {
//       return true;
//     }
//     
//     if (t.prod.def is layouts) {
//       return true;
//     }
//     
//     if ("<t>" == "") {
//       return true;
//     }
//     
//     return false;
//   }
//     
//     
//   Tree filterIt(Tree e2) {
//     if (offSide(e, e2)) {
//       println("Filtering |<e2>|");
//       //rprintln(e2);
//       filter;
//     }
//     return e2;
//   }
//     
//   top-down-break visit (e) {
//     case Tree e2 => filterIt(e2)
//       when e2@\loc?, !leftMost(e2), !isExcluded(e2)
//   }
//   
//   fail;
//}

//Code stat(Statement s, ";"? _) {
//  int at = s@\loc.begin.column;
//  int atLine = s@\loc.begin.line;
//  if (/Tree t := s, t@\loc?, t@\loc.begin.column <= at, t@\loc.begin.line > atLine,
//       lit("}") !:= t.prod.def, !(t.prod.def is layouts), "<t>" != "", "<t>" != ";") {
//    println("Stat Offside argument clause: |<t>|");
//    filter;
//  }
//  fail;
//}


Code stat(Statement s, ";"? _) {
  int at = s@\loc.begin.column;
  int atLine = s@\loc.begin.line;
  if (/ArgumentClause a := s, a@\loc.begin.column <= at, a@\loc.begin.line > atLine) {
    filter;
  }
  if (/Dot a := s, a@\loc.begin.column <= at, a@\loc.begin.line > atLine) {
    filter;
  }
  if (/Slash a := s, a@\loc.begin.column <= at, a@\loc.begin.line > atLine) {
    filter;
  }
  if (/Plus a := s, a@\loc.begin.column <= at, a@\loc.begin.line > atLine) {
    filter;
  }
  if (/Dash a := s, a@\loc.begin.column <= at, a@\loc.begin.line > atLine) {
    filter;
  }
  if (/OpenParen a := s, a@\loc.begin.column <= at, a@\loc.begin.line > atLine) {
    filter;
  }
  if (/CloseParen a := s, a@\loc.begin.column <= at, a@\loc.begin.line > atLine) {
    filter;
  }
  
  if (/UnaryRequest a := s, a@\loc.begin.column <= at, a@\loc.begin.line > atLine) {
    filter;
  }
  
  if (/OtherOp a := s, a@\loc.begin.column <= at, a@\loc.begin.line > atLine) {
    filter;
  }
  
  if (/Argument a := s, a@\loc.begin.column <= at, a@\loc.begin.line > atLine) {
    filter;
  }
  
  if (/Expression e := s, e@\loc.begin.column <= at, e@\loc.begin.line > atLine) {
    //println("Stat Offside expression: <e>");
    filter;
  }
  fail;
}

Code decl(Declaration d, ";"? _) {
  int at = d@\loc.begin.column;
  int atLine = d@\loc.begin.line;
  if (/ArgumentClause a := d, a@\loc.begin.column <= at, a@\loc.begin.line > atLine) {
    //println("Decl Offside argument clause: <a>");
    filter;
  }
  if (/Expression e := d, e@\loc.begin.column <= at, e@\loc.begin.line > atLine) {
    //println("Decl Offside expression: <e>");
    filter;
  }
  fail;
}

//CodeSequence codePlus(Code+ cs) {
//  println("Code+ = <cs>");
//  int line = cs@\loc.begin.line;
//  first = true;
//  for (Code c <- cs) {
//    println("C = <c>");
//    println("line = <line>, c@line = <c@\loc.begin.line>");
//    if (first) {
//      first = false;
//      continue;
//    }
//    if (c@\loc.begin.line == line) {
//      println("Filtering |<c>|");
//      filter;
//    }
//    else {
//      line = c@\loc.begin.line;
//    }
//  }
//  fail;
//}


//CodeSequence codePlus(Code+ cs) {
//  rprintln(cs);
//  if (cs is amb) {
//    println("AMB <cs>");
//    for (Tree t <- cs.alternatives, Code+ alt := t) {
//      codePlus(alt);
//    }
//  }
//  for (Code c <- cs) {
//    int at = c@\loc.begin.column;
//    int atLine = c@\loc.begin.line;
//    println("Code c = |<c>|");
//	  if (/ArgumentClause a := c, a@\loc.begin.column <= at, a@\loc.begin.line > atLine) {
//	    println("Offside argument clause: <a>");
//	    filter;
//	  }
//	  if (/Expression e := c, e@\loc.begin.column <= at, e@\loc.begin.line > atLine) {
//	    println("Offside expression: <e>");
//	    filter;
//	  }
//	}
//  fail;
//}

CodeSequence seq(CodeSequence lhs, CodeSequence rhs) {
  //println("SEQ");
  //println("LHS = <lhs>");
  //println("RHS = <rhs>");
  if (horizontal(lhs, rhs)) {
    //println("Filtering seq");
    filter;
  }
  fail;
}



