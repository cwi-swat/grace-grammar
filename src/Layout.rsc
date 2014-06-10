module Layout

extend Comment;

layout Default
  = LAYOUT* !>> [\ \n\r] !>> "//";

lexical LAYOUT
  = Comment 
  | [\ \n\r] 
  ;

  
