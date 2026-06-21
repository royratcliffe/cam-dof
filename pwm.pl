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
