module Check

import DynGrace;
import Message;
import ParseTree;

set[Message] check(start[Program] p) 
  = nestedMethods(p) + traitFields(p); 

/*
 todo: 
 - match out annos.
 - check duplicate modifiers or conflicting ones.
*/

set[loc] containedMethods(CodeSequence c) {
  set[loc] result = {};
  top-down-break visit (c) {
    case (Declaration)`method <MethodHeader m> { <CodeSequence c> }`: result += {m@\loc};
    case (Declaration)`class <MethodHeader _> { <CodeSequence _> }`: ;
    case (Declaration)`class <MethodHeader _> { <Extend* _> <CodeSequence _> }`: ;
    case (Declaration)`trait <MethodHeader _> { <CodeSequence _> }`: ;
    case (Expression)`object { <CodeSequence _> }`: ;
    case (Expression)`object { <Extend* _> <CodeSequence _> }`: ;
  }
  return result;
}


set[Message] nestedMethods(start[Program] p)   
  = { error("Nested method", m) | 
        /(Declaration)`method <MethodHeader _> { <CodeSequence c> }` := p, 
         m <- containedMethods(c) };


set[loc] containedFields(CodeSequence c) {
  set[loc] result = {};
  top-down-break visit(c) {
    case (Declaration)`var <Identifier x>`: result += {x@\loc};
    case (Declaration)`var <Identifier x> <Annos _>`: result += {x@\loc};
    case (Declaration)`var <Identifier x> := <Expression _>`: result += {x@\loc};
    case (Declaration)`var <Identifier x> <Annos _> := <Expression _>`: result += {x@\loc};
    case (Declaration)`def <Identifier x> = <Expression _>`: result += {x@\loc};
    case (Declaration)`def <Identifier x> <Annos _> = <Expression _>`: result += {x@\loc};
    case (Declaration)`class <MethodHeader _> { <CodeSequence _> }`: ;
    case (Declaration)`class <MethodHeader _> { <Extend* _> <CodeSequence _> }`: ;
    case (Declaration)`trait <MethodHeader _> { <CodeSequence _> }`: ;
    case (Expression)`object { <CodeSequence _> }`: ;
    case (Expression)`object { <Extend* _> <CodeSequence _> }`: ;
  }
  return result; 
}

set[Message] traitFields(start[Program] p)   
  = { error("Field in trait", f) | 
        /(Declaration)`trait <MethodHeader _> { <CodeSequence c> }` := p, 
         f <- containedFields(c) };
         
