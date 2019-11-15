module Declarations


syntax VarDeclaration 
  = "var" Identifier  Modifier? (":=" Expression)?
  ;

syntax DefDeclaration 
  = @Foldable "def" Identifier Modifier? "=" Expression
  ;

syntax Modifier
  = "is" "public"
  | "is" "readable"
  | "is" "confidential"
  ;

syntax MethodDeclaration 
  // make check that disallows methods in methods.
  = @Foldable "method" MethodHeader "{" Code* "}"
  ;
  
syntax ClassDeclaration 
  = @Foldable "class" MethodHeader "{" InheritsClause? Code* "}";

// TODO: how to do this in rascal??
//warning: order here is significant!

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
  = "inherits" Expression 
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
  

