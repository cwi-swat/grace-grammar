module Grace

extend Lexical;
extend Declarations;
extend Literals;
extend Expressions;
extend Statements;
extend Code;
extend Layout;
extend Comment;


import ParseTree;

/*
 * Some things should not be dealt with syntactically, but be static error
 * E.g. the distinction between inner decls and others.
 */ 

start syntax Program 
  = Code*
  ;


Expression pe(str src)
  = parse(#Expression, src);
  