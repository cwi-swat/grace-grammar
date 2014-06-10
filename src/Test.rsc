module Test

import ParseTree;
import Grace;
import List;
import IO;

bool expectParseError(void() f) {
  try {
    f();
    return false;
  }
  catch ParseError(_):
    return true;
}

bool isExpr(CodeSequence cs) = (CodeSequence)`<Expression e>` := cs;

CodeSequence parseCode(str s) {
//  t = disamb(parse(#CodeSequence, s), 1, 0);
  t = parse(#CodeSequence, s);
  return t;
  //if (CodeSequence c := t) {
  //  return t;
  //}
  //rprintln(t);
}
Expression parseExp(str s) = parse(#Expression, s);

// f(f(a, b), c)
bool isLeftAssoc(Expression x)
  = size(x.args[0].args) == 5
  && size(x.args[4].args) == 1;

int countStats((CodeSequence)`<Code _>`) = 1;
int countStats((CodeSequence)`<CodeSequence a>; <CodeSequence b>`) 
  = countStats(a) + countStats(b);

int countStats((CodeSequence)`<CodeSequence a> <CodeSequence b>`) 
  = countStats(a) + countStats(b);

test bool keywordMessage0() 
  = isExpr(parseCode("if (x) then {y} 
                     '  else {z}"));

test bool keywordMessage01() 
  = isExpr(parseCode("if (x) then {y} else 
                     '  {z}"));

test bool zigzag() 
  = isExpr(parseCode("if (x)
                     '   then {foo}
                     ' elsif (x)
                     '    then {bar}
                     ' elsif (x)
                     '    then {baz}"));

test bool keywordMessageBla() 
  = isExpr(parseCode("match 1
                     '   case 2
                     '   do (x)
                     '   case 3
                     '   do (x)"));


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
  
Tree pw() =   parseCode("if (x) 
                        'then {y} 
                        'else {z}");
  
test bool keywordMessage5() 
  = countStats(parseCode("if (x) 
                         'then {y} 
                         'else {z}")) == 3;
  
test bool keywordMessage6() 
  = countStats(parseCode("if (x) 
                         '  then {y} 
                         'else {z}")) == 2;

test bool keywordMessage7() 
  = isExpr(parseCode("if (x) then {
                     '  y 
                     '} else {
                     '  z
                     '}"));
 

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

test bool otherOp4() 
  = countStats(parseCode("1 ++ 
                         ' 2 ++ 
                         '   3")) == 1;

test bool otherOp5() 
  = countStats(parseCode("1 ++ 
                         ' 2 
                         '++ 3")) == 2;

test bool otherOp6() 
  = countStats(parseCode("1  
                         ' ++ 2 
                         ' ++ 3")) == 1;


test bool plusOp1() 
  = isExpr(parseCode("1 + 2"));


test bool plusOp2() 
  = isExpr(parseCode("1 
                     '  + 2"));

// is there no builtin unary plus?
//test bool plusOp3() 
//  = countStats(parseCode("1 
//                         '+ 2")) == 2;

test bool plusOp3() 
  = countStats(parseCode("1 + 
                         ' 2")) == 1;
  
  
test bool otherOpPrecedence1() 
  = isLeftAssoc(parseExp("1 ++ 2 ++ 3")); 
  
  
  
test bool otherOpPrecedence2() 
  = expectParseError(() { parseExp("1 -- 2 ++ 3"); });
   

test bool otherOpParens() 
  = expectParseError(() { 
      parseCode("(x 
                ' ++ y)");
    });
    
    // should succeed
test bool someVar1() 
  = countStats(parseCode("var x := y
                         '  ++ z")) == 1;

test bool someVar2() 
  = countStats(parseCode("var x := y
                         '          ++ z")) == 1;
 
test bool prefixOp1()
  = isExpr(parseCode("++
                     '  3"));  

test bool prefixOp2()
  = isExpr(parseCode("++
                     ' 3"));  
  
test bool prefixOp3()
  = countStats(parseCode("a
                         '++
                         '  3")) == 2;