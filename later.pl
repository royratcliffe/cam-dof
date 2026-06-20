/*  File:    later.pl
    Author:  Roy Ratcliffe
    Created: Jun 20 2026
    Purpose: Run goals after a delay in Prolog

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

:- module(later,
          [ do_later/2, % +Time, :Goal
            later/2     % +Time, :Goal
          ]).

:- meta_predicate
    do_later(+, 0),
    later(+, 0).

%! do_later(+Time, :Goal) is det.
% Run Goal after Time seconds. Time can be a float. Goal is a callable term that
% will be called after Time seconds. The goal will be called in a separate
% thread, so it will not block the calling thread.
% @arg Time The time to wait before calling Goal, in seconds.
% @arg Goal The goal to call after Time seconds.
do_later(Time, Goal) :-
    thread_create(later(Time, Goal), _, [detached(true)]).

%! later(+Time, :Goal) is det.
% Run Goal after Time seconds. Time can be a float. Goal is a callable term that
% will be called after Time seconds. The goal will be called in the same thread,
% so it will block the calling thread until Time seconds have passed.
% @arg Time The time to wait before calling Goal, in seconds.
% @arg Goal The goal to call after Time seconds.
later(Time, Goal) :-
    sleep(Time),
    call(Goal).
