/*  File:    pwm.pl
    Author:  Roy Ratcliffe
    Created: Jun 20 2026
    Purpose: PWM control using sysfs interface in Prolog

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

:- module(pwm,
          [ pwm_enable/3,    % +Chip:atom, +Export:integer, +Enable:integer
            pwm_duty_cycle/3 % +Chip:atom, +Export:integer, +DutyCycle:float
          ]).
:- use_module(library(sysfs/pwm)).
:- use_module(clamp).

%! pwm_enable(Chip, Export, Enable) is nondet.
% Enable or disable a specific PWM channel by writing to the enable file in the
% sysfs PWM interface.
% @arg Chip The PWM chip.
% @arg Export The PWM export number.
% @arg Enable The value to write to the enable file (1 to enable, 0 to disable).
pwm_enable(Chip, Export, Enable) :-
    sysfs_pwm_write(enable, Chip, Export, Enable).

%! pwm_duty_cycle(Chip, Export, DutyCycle) is nondet.
% Set the duty cycle for a specific PWM channel by writing to the duty_cycle file in the
% sysfs PWM interface. The duty cycle is a value between 0 and 1 that represents
% the percentage of time that the signal is high.
% @arg Chip The PWM chip.
% @arg Export The PWM export number.
% @arg DutyCycle The duty cycle to set (a value between 0 and 1).
pwm_duty_cycle(Chip, Export, DutyCycle) :-
    sysfs_pwm_read(period, Chip, Export, Period),
    clamp(0, Period - 1, round(DutyCycle * Period), DutyCycle1),
    sysfs_pwm_write(duty_cycle, Chip, Export, DutyCycle1).
