module Plugin

import util::IDE;
import Grace;
import ParseTree;

public void main() {
  registerLanguage("Grace", "grace", 
    start[Program] (str input, loc origin) {
      return parse(#start[Program], input, origin);
    });
}