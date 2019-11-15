class catColoured(c) named (n) {
    def colour is public = c§
    def name is public = n§
    var miceEaten is readable := 0§
    method eatMouse {miceEaten := miceEaten + 1}§
    print "The cat {n} has been created."§
}§

def fergus = catColoured (colour.tortoiseshell) named "Fergus"§

def x =
   mumble "3"§
   fratz 7§
while {stream.hasNext} do {
   print(stream.read)§
};  

def x =
   mumble "3" §
   ratz 7§

while {stream.hasNext} do {
      print(stream.read)§
}§

var x := y 
  ++ z§
  
object {
    def a = 1                  §// Confidential access to a
    def b is public = 2        §// Public access to b
    def c is readable = 2      §// Public access to c
    var d := 3                 §// Confidential access and assignment
    var e is readable          §// Public access and confidential assignment
    var f is writable          §// Confidential access, public assignment
    var g is public            §// Public access and assignment
    var h is readable, writable    §// Public access and assignment
}§


method catColoured(c) named (n) {
    method bla(c) {
      println "bla"§
    }§
    object {
        inherit graceObject§
        def colour is public = c§
        
        def name is public = n§
        var miceEaten is readable := 0 §
        method eatMouse {miceEaten := miceEaten + 1}§
        print "The cat {n} has been created."§
        if (x) 
          then {y}
            else {z}§
    }§
}§

trait edible {
  def name = "Edible";
}§

method newShipStartingAt(s)endingAt(e) {
    // returns a battleship object extending from s to e.  This object cannot
    // be asked its size, or its location, or how much floatation remains.
    def size = s.distanceTo(e)§
    var floatation := size§
    object {
        method isHitAt(shot) {
            if (shot.onLineFrom(s)to(e)) then {
                floatation := floatation -1§
                if (floatation == 0) then { self.sink }§
                true§
            } else { false }§
        }§
        ...§
    }§
}§