module Plugin

import util::IDE;
import DynGrace;
import ParseTree;
import Check;
import Outline;

public void main() {
  registerLanguage("Grace", "grace", 
    start[Program] (str input, loc origin) {
      return parse(#start[Program], input, origin);
    });
  registerContributions("Grace", {
    annotator(Tree(Tree t) {
      if (start[Program] p := t) {
        return p[@messages=check(p)];
      }
      return {error("Not a program", t@\loc)};
    }),
    outliner(node(Tree t) {
      if (start[Program] p := t) {
        return outlineGrace(p);
      }
      return ""();
    })
  });
}