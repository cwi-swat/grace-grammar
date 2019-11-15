module Plugin

import util::IDE;
import DynGrace;
import ParseTree;
import Check;
import Outline;
import Tokenize;
import String;
import List;
import IO;


str preprocess(str src) {
  return intercalate("\n", insertSemicolons(split("\n", src)));
}

bool isMarker(Tree t) = appl(prod(sort("MARKER"), _, _), _) := t;
  
  

Tree deleteMarkers(appl(Production p, list[Tree] args)) 
  = appl(p, [ deleteMarkers(a) | Tree a <- args, !isMarker(a) ]);
  
default Tree deleteMarkers(Tree t) = t;
  


public void main() {
  registerLanguage("Grace", "grace", 
    start[Program] (str input, loc origin) {
      //pt = parse(#start[Program], input, origin);
      pt = parse(#start[Program], preprocess(input), origin);
      if (start[Program] prog := deleteMarkers(pt)) {
        return prog;
      }
      //return pt;
    });
  //registerContributions("Grace", {
  //  annotator(Tree(Tree t) {
  //    if (start[Program] p := t) {
  //      return p[@messages=check(p)];
  //    }
  //    return {error("Not a program", t@\loc)};
  //  }),
  //  outliner(node(Tree t) {
  //    if (start[Program] p := t) {
  //      return outlineGrace(p);
  //    }
  //    return ""();
  //  })
  //});
}