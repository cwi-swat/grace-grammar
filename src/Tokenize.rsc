module Tokenize

import String;
import List;
import IO;

/*

Code is sequence of statements

A statement is
  - terminated by end of line if no braces are open on it and next line is same or less indentation

Examples
a + b // one statement
a +
  b // one statement because indent
  
a
+ b // two statements

a {
  b  // b is one, a { b } is one
}
  
*/


list[str] catGrace() = readFileLines(|project://Grace/src/cat.grace|);


tuple[str, str, str] splitLine(str line)  = <ws, stuff, comment>
  when /^<ws:\s*><stuff:.*?><comment:[\/][\/].*>?$/ := line;

list[str] insertSemicolons(list[str] lines) {

  str insertSemicolon(str ws, str stuff, str comment) {
    if (/;\s*$/ := stuff) {
      return ws + stuff + comment;
    }
    return ws + stuff + "§" + comment;
  }

  int i = 0;
    
  return while (i < size(lines)) {
    str line = lines[i];
    <ws, stuff, comment> = splitLine(line);
   
    if (stuff == "") {
      append line;
    }
    else if (i == size(lines) - 1) { // last line
      append insertSemicolon(ws, stuff, comment);
    }
    else { // look ahead
      <ws2, stuff2, comment2> = splitLine(lines[i+1]);
      if (!hasOpenBrace(stuff), size(ws2) <= size(ws)) {
        append insertSemicolon(ws, stuff, comment);
      }
      else {
        append line;
      }
    }
    i += 1;
  }
  return newLines;
}



bool hasOpenBrace(str line) = size(findAll("{", line)) > size(findAll("}", line));
  
