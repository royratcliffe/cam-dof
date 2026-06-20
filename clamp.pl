/*  File:    clamp.pl
    Author:  Roy Ratcliffe
    Created: Jun 20 2026
    Purpose: Clamp a value between a minimum and maximum

Copyright (c) 2026, Roy Ratcliffe, Northumberland, United Kingdom

Permission is hereby granted, free of charge,  to any person obtaining a
copy  of  this  software  and    associated   documentation  files  (the
"Software"), to deal in  the   Software  without  restriction, including
without limitation the rights to  use,   copy,  modify,  merge, publish,
distribute, sub-license, and/or sell copies  of   the  Software,  and to
permit persons to whom the Software is   furnished  to do so, subject to
the following conditions:

    The above copyright notice and this permission notice shall be
    included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT  WARRANTY OF ANY KIND, EXPRESS
OR  IMPLIED,  INCLUDING  BUT  NOT   LIMITED    TO   THE   WARRANTIES  OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR   PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS  OR   COPYRIGHT  HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY,  WHETHER   IN  AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM,  OUT  OF   OR  IN  CONNECTION  WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

*/

:- module(clamp,
          [ clamp/4 % +Min, +Max, +Unclamped, -Clamped
          ]).

%!  clamp(+Min, +Max, +Unclamped, -Clamped) is det.
%
%   Clamp a value between a minimum and maximum.
%
%   This predicate takes an input value (Unclamped) and ensures that it falls
%   within the specified minimum (Min) and maximum (Max) bounds. If Unclamped is
%   less than Min, Clamped will be unified with Min. If Unclamped is greater
%   than Max, Clamped will be unified with Max. If Unclamped is between Min and
%   Max, Clamped will be unified with Unclamped. The predicate is deterministic
%   and will always succeed with a single solution.
%
%   @arg Min The minimum value that the result can be.
%   @arg Max The maximum value that the result can be.
%   @arg Unclamped The value to be clamped.
%   @arg Clamped The result of clamping Unclamped between Min and Max.

clamp(Min, Max, Unclamped, Clamped) :- Clamped is min(Max, max(Min, Unclamped)).
