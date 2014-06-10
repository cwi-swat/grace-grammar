module Offside

import ParseTree;

@doc{
Tree rhs is offside of lhs when its begin column is before
or equal to the begin column of rhs. 
}
bool offSide(Tree lhs, Tree rhs) 
  = rhs@\loc.begin.column <= lhs@\loc.begin.column;
  
bool sameLine(Tree lhs, Tree rhs)
  = lhs@\loc.begin.line == rhs@\loc.begin.line;

bool vertical(Tree lhs, Tree rhs)
  = !sameLine(lhs, rhs) && offSide(lhs, rhs);
  
bool horizontal(Tree lhs, Tree rhs)
  = //!vertical(lhs, rhs); 
  sameLine(lhs, rhs) || !offSide(lhs, rhs);