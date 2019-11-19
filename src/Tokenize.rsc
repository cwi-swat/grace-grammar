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

list[str] insertMarkers(list[str] lines) {

  str insertMarker(str ws, str stuff, str comment) {
    if (/;\s*$/ := stuff) { // don't insert if there's a semi-colon already
      return ws + stuff + comment;
    }
    return ws + stuff + "§" + comment;
  }

  bool isOffSide(str ws, str nextLine) {
    <ws2, stuff2, comment2> = splitLine(nextLine);
    return size(ws2) > size(ws);
  }

  int i = 0;
    
  return while (i < size(lines)) {
    str line = lines[i];
    <ws, stuff, comment> = splitLine(line);
   
    if (stuff == "") { // only whitespace and/or comment
      append line;
    }
    else if (i == size(lines) - 1) { // last line with stuff
      append insertMarker(ws, stuff, comment);
    }
    else { // look ahead
      if (!hasOpenBrace(stuff), !isOffSide(ws, lines[i+1])) {
        append insertMarker(ws, stuff, comment);
      }
      else {
        append line;
      }
    }
    i += 1;
  }

}



bool hasOpenBrace(str line) = size(findAll("{", line)) > size(findAll("}", line));
  
