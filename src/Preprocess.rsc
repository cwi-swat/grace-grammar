module Preprocess

import String;
import List;

bool shouldContinue(str base, str indentee) {
  if (/^<ws1:[ ]*>/ := base, /^<ws2:[ ]*>/ := indentee) {
    return size(ws2) > size(ws1);
  }
  throw "Cannot happen"; 
}

str preprocess(str src) {
  lines = split("\n", src);
  i = 0;
  newLines = while (i < size(lines)) {
    if (i < size(lines) - 1) {
      if (shouldContinue(lines[i], lines[i + 1])) {
        append "<lines[i]>¤\n";
      }
      else {
        append "<lines[i]>\n";
      }
    }
    else {
       append "<lines[i]>\n";
    }
    i += 1;
  }
  return intercalate("", newLines);
}