module Outline

import DynGrace;
import ParseTree;


node outlineGrace(start[Program] p) {
  methods = [];
  classes = [];
  traits = [];
  
  top-down visit (p) {
    case d:(Declaration)`method <MethodHeader m> { <CodeSequence c> }`: 
      methods += "method"()[@label="<m>"][@\loc=d@\loc];
      
    case d:(Declaration)`method <MethodHeader m> { }`: 
      methods += "method"()[@label="<m>"][@\loc=d@\loc];

    case d:(Declaration)`class <MethodHeader m> { <CodeSequence _> }`: 
      classes += "class"()[@label="<m>"][@\loc=d@\loc];

    case d:(Declaration)`class <MethodHeader m> { <InheritsClause _> <CodeSequence _> }`: 
      classes += "class"()[@label="<m>"][@\loc=d@\loc];
      
    case d:(Declaration)`trait <MethodHeader m> { <CodeSequence _> }`: 
      traits += "trait"()[@label="<m>"][@\loc=d@\loc];
  }
  
  return "outline"("classes"(classes)[@\label="Classes"],
            "traits"(traits)[@\label="Traits"],
            "methods"(methods)[@\label="Methods"]);
} 