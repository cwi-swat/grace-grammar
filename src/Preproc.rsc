module Preproc

import String;
import List;
import IO;


test bool insertSemisEmpty() = insertSemis("") == "";

test bool insertSemisSingle() = insertSemis("abc") == "abc";

//bug in split
//test bool insertSemisSingleNL() = insertSemis("abc\n") == "abc;\n";

test bool insertSemisTwoLinesSame() = insertSemis("abc\nd") == "abc;\nd";

test bool insertSemisTwoLinesDedent() = insertSemis("  abc\nd") == "  abc;\nd";

test bool insertSemisTwoLinesIndent() = insertSemis("abc\n  d") == "abc\n  d";

test bool insertSemisNotOnEmptyLine() = insertSemis("abc\n\nd") == "abc;\n\nd";

test bool insertSemisBeforeComments() = insertSemis("abc //comm\nd") == "abc;//comm\nd";



str insertSemis(str src) {
  lines = split("\n", src);
 
  lastIndent = 100000; // very big
  first = true;
  newLines = [];
  
  for (l <- lines) {
    if (indentOf(l) <= lastIndent, !first) {
      //newLines[-1] += ";";
      last = newLines[size(newLines)-1]; 
      if (last != "") {
        newLines[size(newLines)-1] += ";";
      }
    }
    newLines += [l];
    lastIndent = indentOf(l);
    first = false;
  }
  return intercalate("\n", newLines);  
}

int indentOf(str line) {
  if (/^<indent:[ ]*>/ := line) {
     return size(indent);
  }
  return 0; 
}