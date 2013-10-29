
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
