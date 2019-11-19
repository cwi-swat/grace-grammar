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
  return intercalate("\n", insertMarkers(split("\n", src)));
}

bool isMarker(Tree t) = appl(prod(sort("MARKER"), _, _), _) := t;
  
  

Tree deleteMarkers(t:appl(Production p, list[Tree] args)) {
  list[Tree] newArgs = [];
  for (int i <- [0..size(args)]) {
     if (isMarker(args[i])) {
       ;//newArgs = newArgs[0..-1]; // remove preceding layout node;
     }
     else {
       newArgs += [deleteMarkers(args[i])];
     }
   } 
   return appl(p, newArgs);
}
  
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