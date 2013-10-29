module Test

import ParseTree;
import Grace;


bool isExpr(CodeSequence cs) = (CodeSequence)`<Expression e>` := cs;
CodeSequence parseCode(str s) = parse(#CodeSequence, s);

int countStats((CodeSequence)`<Code _>`) = 1;
int countStats((CodeSequence)`<CodeSequence a>; <CodeSequence b>`) 
  = countStats(a) + countStats(b);

int countStats((CodeSequence)`<CodeSequence a> <CodeSequence b>`) 
  = countStats(a) + countStats(b);


test bool keywordMessage1() 
  = isExpr(parseCode("if (x) then {y} else {z}"));

test bool keywordMessage2() 
  = isExpr(parseCode("if (x) 
                     '  then {y} 
                     '  else {z}"));

test bool keywordMessage3() 
  = isExpr(parseCode("if (x) 
                     '  then {y} 
                     '    else {z}"));

test bool keywordMessage4() 
  = countStats(parseCode("if (x) then {y} else {z}")) == 1;
  
test bool keywordMessage5() 
  = countStats(parseCode("if (x) 
                         'then {y} 
                         'else {z}")) == 3;
  
test bool keywordMessage6() 
  = countStats(parseCode("if (x) 
                         '  then {y} 
                         'else {z}")) == 2;

test bool otherOp1() 
  = isExpr(parseCode("1 ++ 2"));


test bool otherOp2() 
  = isExpr(parseCode("1 
                     '  ++ 2"));


test bool otherOp3() 
  = countStats(parseCode("1 
                         '++ 2")) == 2;

test bool otherOp3() 
  = countStats(parseCode("1 ++ 
                         ' 2")) == 1;
  