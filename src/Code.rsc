module Code


syntax Declaration
  = var: VarDeclaration
  | def: DefDeclaration
  | class: ClassDeclaration
  | method: MethodDeclaration
  ;

syntax Code
  = Declaration PAR 
  | Statement PAR
  ;
  
syntax PAR
  = "§";  
