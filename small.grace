print "starting $Id: combinators.grace 279 2012-02-21 23:54:53Z kjx $"

def Void = object {
 def brand = "Void"
}

////////////////////////////////////////////////////////////
// input stream type

// type InputStream = {
//   brand -> String
//   position -> Number
//   take(n : Number) -> String
//   rest(n : Number) -> InputStream
//   atEnd -> Boolean
// }

////////////////////////////////////////////////////////////
// string input stream
class StringInputStream.new(string : String, position' : Number) {
 def brand = "StringInputStream"
 def position : Number = position'

 // functional!
 method take(n : Number) -> String {
   // print "take {n} at {position}" // DEBUG

   var result := ""
   var endPosition := position + n - 1
   if (endPosition > string.size) then {endPosition := string.size}

   for (position..endPosition) do { i : Number -> 
       result := result ++ string.at(i)
   }
   // print "take returning <{result}>"
   return result
 }

 method rest(n : Number)  {
//  print "rest {n} at {position}"  // DEBUG
  if ((n + position) <= (string.size + 1))
   then {return StringInputStream.new(string, position+n)}
   else {
     return print("FATAL ERROR END OF INPUT {position+n}")}
 }

 method atEnd  {return position > string.size}

}

////////////////////////////////////////////////////////////
// parse results

// type ParseSuccessType = {
//  brand -> String
//  next -> InputStream
//  result -> String
//  succeeded -> Boolean
//  resultUnlessFailed(Block) -> ParseResult 
// }

// type ParseFailureType = {
//  brand -> String
//  message -> String
//  succeded -> Boolean
//  resultUnlessFailed(Block) -> ParseResult 
// }

// type ParseResult = (ParseSuccessType | ParseFailureType)

// type ParseResult = ParseFailureType

class ParseSuccess.new(next', result') {
 def brand = "ParseSuccess"
 def next = next'
 def result = result'
 method succeeded { return true }
 method resultUnlessFailed (failBlock : Block) {
   return self
 }
}

class ParseFailure.new(message') {
 def brand = "ParseFailure" 
 def message = message'
 method succeeded { return false }
 method resultUnlessFailed (failBlock : Block) { 
   return failBlock.apply(self)
 }
}

 
////////////////////////////////////////////////////////////
// parsers

class AbstractParser.new {
 def brand = "AbstractParser"
 method parse(in) { }

 // this shold be an inherited method suite in Parser
 method ~(other) {SequentialParser.new(self,other)}
 method |(other) {AlternativeParser.new(self,other)}
}

// type Parser = { 
//  parse(InputStream) -> ParseResult
//  method ~(Parser) -> Parser
//  method |(Parser) -> Parser

// }

// parse just a token - basically a string, matching exactly
class TokenParser.new(tken) {
 inherits AbstractParser.new
 def brand = "TokenParser"
 method parse(in) {
   def size = tken.size
   if (in.take(size) == tken) then {
      return ParseSuccess.new(in.rest(size), "{in.take(size)}" )
     } else {
      return ParseFailure.new(
        "expected {tken} got {in.take(size)} at {in.position}")
   }
 }
}

// get at least one whitespace
class WhiteSpaceParser.new {
 inherits AbstractParser.new 
 def brand = "WhiteSpaceParser"
 method parse(in) {
   var current := in
   while {current.take(1) == " "} 
     do {current := current.rest(1)}
   if (current != in) then {
      return ParseSuccess.new(current, " ")
     } else {
      return ParseFailure.new(
        "expected w/s got {in.take(5)} at {in.position}")
   }
 }
}


// parser single character from set of acceptable characters (given as a string)
class CharacterSetParser.new(charSet) {
 inherits AbstractParser.new
 def brand = "CharacterSetParser"

 method parse(in) {
   def current = in.take(1) 
   
   for (charSet) do { c ->
      if (c == current) then {
        return ParseSuccess.new(in.rest(1), current ) }
     }

   return ParseFailure.new(
        "expected \"{charSet}\" got {current} at {in.position}")
 }
}

//does *not* eat whitespace!
class GraceIdentifierParser.new { 
 inherits AbstractParser.new

 def brand = "GraceIdentifierParser"
 method parse(in) {
   if (in.take(1) == "_") then {
      return ParseSuccess.new(in.rest(1), "_")                 
   }
   var current := in

   if (! isletter(in.take(1))) then {
      return ParseFailure.new(
        "expected GraceIdentifier got {in.take(5)}... at {in.position}")
   }
   
   var char := current.take(1)
   var id := ""

   while {isletter(char) | isdigit(char) | (char == "'") }
     do {
        id := id ++ char
        current := current.rest(1)
        char := current.take(1)
   }

   return ParseSuccess.new(current, id)
 }

}


// dunno why this is here?
class DigitStringParser.new { 
 inherits AbstractParser.new
 def brand = "DigitStringParser"
 method parse(in) {
   
   var current := in

   var char := current.take(1)
   var id := ""

   if (char == "-") then {
     id := "-"
     current := in.rest(1)
     char := current.take(1)     
   }

   if (! isdigit(char)) then {
      return ParseFailure.new(
        "expected DigitString got {in.take(5)}... at {in.position}")
   }

   while {isdigit(char)} do {
        id := id ++ char
        current := current.rest(1)
        char := current.take(1)
   }

   return ParseSuccess.new(current, id)
 }

}



class SequentialParser.new(left, right) { 
 inherits AbstractParser.new def brand = "SequentialParser"
 method parse(in) {
    def leftResult = left.parse(in)
          .resultUnlessFailed {f -> return f}
    def rightResult = right.parse(leftResult.next)
          .resultUnlessFailed {f -> return f}
    return ParseSuccess.new(rightResult.next, 
           leftResult.result ++ rightResult.result)
 }
}


class OptionalParser.new(subParser) { 
 inherits AbstractParser.new
 def brand = "OptionalParser"
 method parse(in) {
    return (subParser.parse(in)
          .resultUnlessFailed {f -> 
               return ParseSuccess.new(in, "")})
}

}

//match as if SubParser, discard the result
class DropParser.new(subParser) {
 inherits AbstractParser.new
 def brand = "DropParser"
 method parse(in) {
    def subRes = subParser.parse(in)
          .resultUnlessFailed {f -> return f}
    return ParseSuccess.new(subRes.next, "")
 }

}


class AlternativeParser.new(left, right) {
 inherits AbstractParser.new
 def brand = "AlternativeParser"
 method parse(in) {
    def leftResult = left.parse(in)
    if (leftResult.succeeded) then {
      return leftResult }
    return right.parse(in)
 }

}


//succeeds if both left & right succeed; returns LEFT parse
//e.g. both(identifier,not(reservedIdentifiers)) -- except that's wrong!
class BothParser.new(left, right) {
 inherits AbstractParser.new
 def brand = "BothParser"
 method parse(in) {
    def leftResult = left.parse(in)
    if (!leftResult.succeeded) then {return leftResult}
    def rightResult = right.parse(in)
    if (!rightResult.succeeded) then {return rightResult}
    return leftResult
 }

}



class RepetitionParser.new(subParser) {
 inherits AbstractParser.new
 def brand = "RepetitionParser"
 method parse(in) {
   var current := in

   var res := subParser.parse(in)
   var id := ""

   while {res.succeeded}
     do {
        id := id ++ res.result
        current := res.next
        res := subParser.parse(current)
   }

   return ParseSuccess.new(current, id)
 }

}



class ProxyParser.new(proxyBlock) { 
 inherits AbstractParser.new
 def brand = "ProxyParser"
 var subParser := "no parser installed"
 var needToInitialiseSubParser := true

 method parse(in) {

  if (needToInitialiseSubParser) then {
    subParser := proxyBlock.apply
    needToInitialiseSubParser := false
  }

  return subParser.parse(in)
 }

}



class WrappingProxyParser.new(proxyBlock, string) {
 inherits AbstractParser.new
 def brand = "WrappingProxyParser"
 var subParser := "no parser installed"
 var needToInitialiseSubParser := true

 method parse(in) {

  if (needToInitialiseSubParser) then {
    subParser := proxyBlock.apply
    needToInitialiseSubParser := false
  }
   
  def result = subParser.parse(in)
  if (!result.succeeded) then {return result}
  
  return ParseSuccess.new(result.next, "[{string}{result.result}]")
 }

}



// get at least one whitespace
class AtEndParser.new { 
 inherits AbstractParser.new
 def brand = "AtEndParser"
 method parse(in) {
   if (in.atEnd) then {
      return ParseSuccess.new(in, "")
     } else {
      return ParseFailure.new(
        "expected end got {in.take(5)} at {in.position}")
   }
 }

}

// succeeds when subparser fails; never consumes input if succeeds
class NotParser.new(subParser) {
 inherits AbstractParser.new
 def brand = "NotParser"
 method parse(in) {
    def result = subParser.parse(in)

    if (result.succeeded)
      then {return ParseFailure.new("Not Parser - subParser succeeded so I failed")}
      else {return ParseSuccess.new(in,"")}
 }

}


class GuardParser.new(subParser, guardBlock) {
 inherits AbstractParser.new
 def brand = "GuardParser"
 method parse(in) {
    def result = subParser.parse(in)

    if (!result.succeeded) then {return result}
    if (guardBlock.apply(result.result)) then {return result}
    return  ParseFailure.new("Guard failure at {in.position}")
 }

}


class SuccessParser.new {
 inherits AbstractParser.new
 def brand = "SuccessParser"
 method parse(in) {return ParseSuccess.new(in,"!!success!!")}

}


object {
 def brand = "Void"
}

def Void = object {
 def brand = "Void"
}

////////////////////////////////////////////////////////////
// input stream type

// type InputStream = {
//   brand -> String
//   position -> Number
//   take(n : Number) -> String
//   rest(n : Number) -> InputStream
//   atEnd -> Boolean
// }

////////////////////////////////////////////////////////////
// string input stream
class StringInputStream.new(string : String, position' : Number) {
 def brand = "StringInputStream"
 def position : Number = position'

 // functional!
 method take(n : Number) -> String {
   // print "take {n} at {position}" // DEBUG

   var result := ""
   var endPosition := position + n - 1
   if (endPosition > string.size) then {a := b}
   for (c..d) do { 
     x
   }
 }

 method rest(n : Number)  {
//  print "rest {n} at {position}"  // DEBUG
  if (x)
   then {a}
   else {
     x}
 }

 method atEnd  {return position > string.size}

}


print "starting $Id: combinators.grace 279 2012-02-21 23:54:53Z kjx $"

def Void = object {
 def brand = "Void"
}

////////////////////////////////////////////////////////////
// input stream type

// type InputStream = {
//   brand -> String
//   position -> Number
//   take(n : Number) -> String
//   rest(n : Number) -> InputStream
//   atEnd -> Boolean
// }

////////////////////////////////////////////////////////////
// string input stream
class StringInputStream.new(string : String, position' : Number) {
 def brand = "StringInputStream"
 def position : Number = position'

 // functional!
 method take(n : Number) -> String {
   // print "take {n} at {position}" // DEBUG

   var result := ""
   var endPosition := position + n - 1
   if (endPosition > string.size) then {endPosition := string.size}

   for (position..endPosition) do { i : Number -> 
       result := result ++ string.at(i)
   }
   // print "take returning <{result}>"
   return result
 }

 method rest(n : Number)  {
//  print "rest {n} at {position}"  // DEBUG
  if ((n + position) <= (string.size + 1))
   then {return StringInputStream.new(string, position+n)}
   else {
     return print("FATAL ERROR END OF INPUT {position+n}")}
 }

 method atEnd  {return position > string.size}

}

////////////////////////////////////////////////////////////
// parse results

// type ParseSuccessType = {
//  brand -> String
//  next -> InputStream
//  result -> String
//  succeeded -> Boolean
//  resultUnlessFailed(Block) -> ParseResult 
// }

// type ParseFailureType = {
//  brand -> String
//  message -> String
//  succeded -> Boolean
//  resultUnlessFailed(Block) -> ParseResult 
// }

// type ParseResult = (ParseSuccessType | ParseFailureType)

// type ParseResult = ParseFailureType

class ParseSuccess.new(next', result') {
 def brand = "ParseSuccess"
 def next = next'
 def result = result'
 method succeeded { return true }
 method resultUnlessFailed (failBlock : Block) {
   return self
 }
}

class ParseFailure.new(message') {
 def brand = "ParseFailure" 
 def message = message'
 method succeeded { return false }
 method resultUnlessFailed (failBlock : Block) { 
   return failBlock.apply(self)
 }
}

 
////////////////////////////////////////////////////////////
// parsers

class AbstractParser.new {
 def brand = "AbstractParser"
 method parse(in) { }

 // this shold be an inherited method suite in Parser
 method ~(other) {SequentialParser.new(self,other)}
 method |(other) {AlternativeParser.new(self,other)}
}

// type Parser = { 
//  parse(InputStream) -> ParseResult
//  method ~(Parser) -> Parser
//  method |(Parser) -> Parser

// }

// parse just a token - basically a string, matching exactly
class TokenParser.new(tken) {
 inherits AbstractParser.new
 def brand = "TokenParser"
 method parse(in) {
   def size = tken.size
   if (in.take(size) == tken) then {
      return ParseSuccess.new(in.rest(size), "{in.take(size)}" )
     } else {
      return ParseFailure.new(
        "expected {tken} got {in.take(size)} at {in.position}")
   }
 }
}

// get at least one whitespace
class WhiteSpaceParser.new {
 inherits AbstractParser.new 
 def brand = "WhiteSpaceParser"
 method parse(in) {
   var current := in
   while {current.take(1) == " "} 
     do {current := current.rest(1)}
   if (current != in) then {
      return ParseSuccess.new(current, " ")
     } else {
      return ParseFailure.new(
        "expected w/s got {in.take(5)} at {in.position}")
   }
 }
}


// parser single character from set of acceptable characters (given as a string)
class CharacterSetParser.new(charSet) {
 inherits AbstractParser.new
 def brand = "CharacterSetParser"

 method parse(in) {
   def current = in.take(1) 
   
   for (charSet) do { c ->
      if (c == current) then {
        return ParseSuccess.new(in.rest(1), current ) }
     }

   return ParseFailure.new(
        "expected \"{charSet}\" got {current} at {in.position}")
 }
}

//does *not* eat whitespace!
class GraceIdentifierParser.new { 
 inherits AbstractParser.new

 def brand = "GraceIdentifierParser"
 method parse(in) {
   if (in.take(1) == "_") then {
      return ParseSuccess.new(in.rest(1), "_")                 
   }
   var current := in

   if (! isletter(in.take(1))) then {
      return ParseFailure.new(
        "expected GraceIdentifier got {in.take(5)}... at {in.position}")
   }
   
   var char := current.take(1)
   var id := ""

   while {isletter(char) | isdigit(char) | (char == "'") }
     do {
        id := id ++ char
        current := current.rest(1)
        char := current.take(1)
   }

   return ParseSuccess.new(current, id)
 }

}


// dunno why this is here?
class DigitStringParser.new { 
 inherits AbstractParser.new
 def brand = "DigitStringParser"
 method parse(in) {
   
   var current := in

   var char := current.take(1)
   var id := ""

   if (char == "-") then {
     id := "-"
     current := in.rest(1)
     char := current.take(1)     
   }

   if (! isdigit(char)) then {
      return ParseFailure.new(
        "expected DigitString got {in.take(5)}... at {in.position}")
   }

   while {isdigit(char)}
     do {
        id := id ++ char
        current := current.rest(1)
        char := current.take(1)
   }

   return ParseSuccess.new(current, id)
 }

}



class SequentialParser.new(left, right) { 
 inherits AbstractParser.new def brand = "SequentialParser"
 method parse(in) {
    def leftResult = left.parse(in)
          .resultUnlessFailed {f -> return f}
    def rightResult = right.parse(leftResult.next)
          .resultUnlessFailed {f -> return f}
    return ParseSuccess.new(rightResult.next, 
           leftResult.result ++ rightResult.result)
 }
}


class OptionalParser.new(subParser) { 
 inherits AbstractParser.new
 def brand = "OptionalParser"
 method parse(in) {
    return (subParser.parse(in)
          .resultUnlessFailed {f -> 
               return ParseSuccess.new(in, "")})
}

}

//match as if SubParser, discard the result
class DropParser.new(subParser) {
 inherits AbstractParser.new
 def brand = "DropParser"
 method parse(in) {
    def subRes = subParser.parse(in)
          .resultUnlessFailed {f -> return f}
    return ParseSuccess.new(subRes.next, "")
 }

}


class AlternativeParser.new(left, right) {
 inherits AbstractParser.new
 def brand = "AlternativeParser"
 method parse(in) {
    def leftResult = left.parse(in)
    if (leftResult.succeeded) then {
      return leftResult }
    return right.parse(in)
 }

}


//succeeds if both left & right succeed; returns LEFT parse
//e.g. both(identifier,not(reservedIdentifiers)) -- except that's wrong!
class BothParser.new(left, right) {
 inherits AbstractParser.new
 def brand = "BothParser"
 method parse(in) {
    def leftResult = left.parse(in)
    if (!leftResult.succeeded) then {return leftResult}
    def rightResult = right.parse(in)
    if (!rightResult.succeeded) then {return rightResult}
    return leftResult
 }

}



class RepetitionParser.new(subParser) {
 inherits AbstractParser.new
 def brand = "RepetitionParser"
 method parse(in) {
   var current := in

   var res := subParser.parse(in)
   var id := ""

   while {res.succeeded}
     do {
        id := id ++ res.result
        current := res.next
        res := subParser.parse(current)
   }

   return ParseSuccess.new(current, id)
 }

}



class ProxyParser.new(proxyBlock) { 
 inherits AbstractParser.new
 def brand = "ProxyParser"
 var subParser := "no parser installed"
 var needToInitialiseSubParser := true

 method parse(in) {

  if (needToInitialiseSubParser) then {
    subParser := proxyBlock.apply
    needToInitialiseSubParser := false
  }

  return subParser.parse(in)
 }

}



class WrappingProxyParser.new(proxyBlock, string) {
 inherits AbstractParser.new
 def brand = "WrappingProxyParser"
 var subParser := "no parser installed"
 var needToInitialiseSubParser := true

 method parse(in) {

  if (needToInitialiseSubParser) then {
    subParser := proxyBlock.apply
    needToInitialiseSubParser := false
  }
   
  def result = subParser.parse(in)
  if (!result.succeeded) then {return result}
  
  return ParseSuccess.new(result.next, "[{string}{result.result}]")
 }

}



// get at least one whitespace
class AtEndParser.new { 
 inherits AbstractParser.new
 def brand = "AtEndParser"
 method parse(in) {
   if (in.atEnd) then {
      return ParseSuccess.new(in, "")
     } else {
      return ParseFailure.new(
        "expected end got {in.take(5)} at {in.position}")
   }
 }

}

// succeeds when subparser fails; never consumes input if succeeds
class NotParser.new(subParser) {
 inherits AbstractParser.new
 def brand = "NotParser"
 method parse(in) {
    def result = subParser.parse(in)

    if (result.succeeded)
      then {return ParseFailure.new("Not Parser - subParser succeeded so I failed")}
      else {return ParseSuccess.new(in,"")}
 }

}


class GuardParser.new(subParser, guardBlock) {
 inherits AbstractParser.new
 def brand = "GuardParser"
 method parse(in) {
    def result = subParser.parse(in)

    if (!result.succeeded) then {return result}
    if (guardBlock.apply(result.result)) then {return result}
    return  ParseFailure.new("Guard failure at {in.position}")
 }

}


class SuccessParser.new {
 inherits AbstractParser.new
 def brand = "SuccessParser"
 method parse(in) {return ParseSuccess.new(in,"!!success!!")}

}


// puts tag into output
class TagParser.new(tagx : String) {
 inherits AbstractParser.new
 def brand = "TagParser"
 method parse(in) {return ParseSuccess.new(in, tagx)}

}

// puts tagx around start and end of parse
class PhraseParser.new(tagx: String, subParser) {
 inherits AbstractParser.new
 def brand = "PhraseParser"
 method parse(in) {
    def result = subParser.parse(in)

    if (!result.succeeded) then {return result}

    return ParseSuccess.new(result.next,
              "<" ++ tagx ++ " " ++ result.result ++ " " ++ tagx ++ ">" )
 }

}



////////////////////////////////////////////////////////////
// "support library methods" 

method assert  (assertion : Block) complaint (name : String) {
 if (!assertion.apply) then {print "ASSERTION FAILURE"} 
}


method isletter(c) -> Boolean {
//  print "called isletter({c})"
  if (c.size == 0) then {return false} //is bad. is a hack. works.
  if (c.size != 1) then {print "isletter string {c} too long"}
//  assert {c.size == 1} complaint "isletter string too long" 
  return (((c.ord >= "A".ord) & (c.ord <= "Z".ord)) 
            | ((c.ord >= "a".ord) & (c.ord <= "z".ord)))
}

method isdigit(c) -> Boolean {
 //  assert {c.size == 1} complaint "isdigit string too long" 
  return ((c.ord >= "0".ord) & (c.ord <= "9".ord)) 
}

////////////////////////////////////////////////////////////
// combinator functions - many of these should be methods
// on parser but I got sick of copying everything!

method dyn(d : Dynamic) -> Dynamic {return d}


def ws    = (WhiteSpaceParser.new)
method opt(p : Parser)  {OptionalParser.new(p)}
method rep(p : Parser)  {RepetitionParser.new(p)}
method rep1(p : Parser) {p ~ RepetitionParser.new(p)}
method drop(p : Parser) {DropParser.new(p)}
method trim(p : Parser) {drop(opt(ws)) ~ p ~ drop(opt(ws))}
method token(s : String)  {TokenParser.new(s)}
method symbol(s : String) {trim(token(s))}
method rep1sep(p : Parser, q : Parser)  {p ~ rep(q ~ p)}
method repsep(p : Parser, q : Parser)  {opt( rep1sep(p,q))}
method repdel(p : Parser, q : Parser)  {repsep(p,q) ~ opt(q)}
method rule(proxyBlock : Block)  {ProxyParser.new(proxyBlock)}
//method rule(proxyBlock : Block) wrap(s : String)  {WrappingProxyParser.new(proxyBlock,s)}
method rule(proxyBlock : Block) wrap(s : String)  {ProxyParser.new(proxyBlock,s)}

def end = AtEndParser.new
method not(p : Parser)  {NotParser.new(p)}
method both(p : Parser, q : Parser)  {BothParser.new(p,q)}
method empty  {SuccessParser.new} 
method guard(p : Parser, b : Block)  {GuardParser.new(p, b)} 
method tag(s : String) {TagParser.new(s)}
method phrase(s : String, p : Parser) { PhraseParser.new(s, p) }

method parse (s : String) with (p : Parser)  {
 p.parse(StringInputStream.new(s,1)).succeeded
}

////////////////////////////////////////////////////////////
// "tests" 

print("start")

var passedTests := 0
var failedTests := 0

method test (block : Block, result : Object, comment : String) {
 def rv = block.apply
 if  (rv == result) 
   then {print  ("------: " ++ comment)}
   else {print  ("FAILED: " ++ comment)} 
}

method test(block : Block) expecting(result : Object) comment(comment : String) {
   test(block,result,comment)
}


method test (block : Block, result : Object, comment : String) {
 def rv = block.apply
 if  (rv == result) 
   then {print  ("------: " ++ comment)}
   else {print  ("FAILED: " ++ comment)} 
}

method test(parser : Parser) on(s : String) correctly(comment : String) {
 def res = parser.parse(StringInputStream.new(s,1))
 if (res.succeeded) 
   then {print  ("------: " ++ comment ++ " " ++  res.result)} // res.result
   else {print  ("FAILED: " ++ comment ++ " " ++  s)} 
  
// def rv = parser.parse(StringInputStream.new(s,1)).succeeded
// if  (rv) 
//   then {print  ("------: " ++ comment ++ " " ++  s)}
//   else {print  ("FAILED: " ++ comment ++ " " ++  s)} 
}

method test(parser : Parser) on(s : String) wrongly(comment : String) {
 def rv = parser.parse(StringInputStream.new(s,1)).succeeded
 if  (!rv) 
   then {print  ("------: " ++ comment ++ " " ++  s)}
   else {print  ("FAILED: " ++ comment ++ " " ++  s)} 
}

method testProgramOn(s : String) correctly(comment : String) {
  test(program) on(s) correctly(comment)
}

method testProgramOn(s : String) wrongly(comment : String) {
  test(program) on(s) wrongly(comment)
}

