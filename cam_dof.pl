:- module(cam_dof, []).
:- use_module(library(sysfs/pwmchip)).
:- use_module(cam).
:- use_module(pwm).
:- use_module(xgroup).
:- use_module(clamp).
:- use_module(library(broadcast)).
:- use_module(library(redis)).
:- use_module(library(redis_streams)).
:- use_module(library(settings)).

:- initialization(main, main).

main :-
    create_cam_dof_thread,
    create_cam_dof_xgroup,
    listen_to_cam_dof,
    xlisten_cam_dof_group.

dof(cam, 'pca9685-pwm', 11, 0.1, 0.3).

create_cam_dof_xgroup :- create_cam_dof_xgroup(default).

create_cam_dof_xgroup(Redis) :-
    setting(cam:key, Key),
    setting(cam:group, Group),
    xgroup_create(Redis, Key, Group, [id($), mkstream(true)]).

xlisten_cam_dof_group :- xlisten_cam_dof_group(default).

xlisten_cam_dof_group(Redis) :-
    setting(cam:key, Key),
    setting(cam:group, Group),
    setting(cam:consumer, Consumer),
    xlisten_group(Redis, Group, Consumer, [Key], [starts([>])]).

listen_to_cam_dof :-
    unlisten_to_cam_dof,
    setting(cam:key, Key),
    listen(redis_consume(Key, Entry, _), consume(Entry)).

unlisten_to_cam_dof :-
    setting(cam:key, Key),
    unlisten(redis_consume(Key, _, _)).

consume(Entry) :-
    get_dict(duty_cycle, Entry, DutyCycle),
    !,
    thread_send_message(cam, DutyCycle).
consume(_).

create_cam_dof_thread :-
    (   thread_property(_, alias(cam))
    ->  true
    ;   thread_create(cam_dof, _, [alias(cam), detached(true)])
    ).

cam_dof :-
    setting(cam:key, Key),
    redis(default, get(Key:duty_cycle), DutyCycle),
    cam_dof_(DutyCycle).

cam_dof_(DutyCycle) :-
    dof_enable(cam),
    cam_dof__(DutyCycle).

cam_dof__(DutyCycle) :-
    dof_duty_cycle(cam, DutyCycle),
    setting(cam:key, Key),
    redis(default, set(Key:duty_cycle, DutyCycle), status(ok)),
    cam_dof___(DutyCycle).

cam_dof___(DutyCycle) :-
    thread_self(Self),
    (   thread_get_message(Self, DutyCycle1, [timeout(1)])
    ->  (   thread_peek_message(Self, _)
        ->  cam_dof___(DutyCycle)
        ;   % Got a message and there are no more in the queue, so update the duty cycle and wait for the next message.
            (   DutyCycle == DutyCycle1
            ->  cam_dof___(DutyCycle1)
            ;   cam_dof__(DutyCycle1)
            )
        )
    ;   cam_dof____
    ).

cam_dof____ :-
    dof_disable(cam),
    thread_self(Self),
    thread_get_message(Self, DutyCycle),
    cam_dof_(DutyCycle).

%! dof_enable(DOF, Enable) is nondet.
% Enable or disable a specific DOF by writing to the enable file in the sysfs
% PWM interface. For example, to enable the camera DOF, you would call
% dof_enable(cam, 1), which would write the value 1 to the enable file for the
% camera DOF. To disable the camera DOF, you would call dof_enable(cam, 0),
% which would write the value 0 to the enable file for the camera DOF. The
% predicate is non-deterministic and can be used to enable or disable a specific
% DOF by providing its name (cam) and the desired state (1 for enabled, 0 for
% disabled).
dof_enable(DOF, Enable) :-
    degree_of_freedom(DOF, Chip, Export, _, _),
    pwm_enable(Chip, Export, Enable).

dof_enable(DOF) :- dof_enable(DOF, 1).

dof_disable(DOF) :- dof_enable(DOF, 0).

%! dof_duty_cycle(DOF, DutyCycle) is nondet.
%
% Set the duty cycle for a specific DOF by writing to the duty_cycle file in the
% sysfs PWM interface. The duty cycle is a value between 0 and 1 that represents
% the percentage of time that the signal is high.
%
% @arg DOF The name of the degree of freedom to set the duty cycle for (e.g., cam).
%
% @arg DutyCycle The duty cycle to set (a value between 0 and 1). For example,
% to set the duty cycle for the camera DOF to 50%, you would call
% dof_duty_cycle(cam, 0.5), which would write the appropriate value to the
% duty_cycle file for the camera DOF.
dof_duty_cycle(DOF, DutyCycle) :-
    degree_of_freedom(DOF, Chip, Export, MinDutyCycle, MaxDutyCycle),
    % Scale the incoming duty cycle to the range of the DOF. For example, if the
    % DOF has a minimum duty cycle of 0.1 and a maximum duty cycle of 0.3, and
    % the incoming duty cycle is 0.5, we would scale it to 0.1 + (0.3 - 0.1) *
    % 0.5 = 0.2, which is the appropriate duty cycle for the DOF
    clamp(MinDutyCycle, MaxDutyCycle, MinDutyCycle + (MaxDutyCycle - MinDutyCycle) * DutyCycle, DutyCycle1),
    pwm_duty_cycle(Chip, Export, DutyCycle1).

degree_of_freedom(DOF, Chip, Export, MinDutyCycle, MaxDutyCycle) :-
    dof(DOF, DeviceNameOfChip, Export, MinDutyCycle, MaxDutyCycle),
    device_name_of_chip(DeviceNameOfChip, Chip).

:- table device_name_of_chip/2.

%! device_name_of_chip(DeviceName, Chip) is semidet.
%
% Find the PWM chip that corresponds to the given device name. For example, to
% find the chip for the PCA9685 PWM controller, you would call
% device_name_of_chip('pca9685-pwm', Chip), which would unify Chip with the
% appropriate value for the PCA9685 PWM controller.
%
% The predicate is semidet, meaning it will succeed at most once. If there is a
% chip with the specified device name, it will unify Chip with that chip. If
% there is no chip with the specified device name, the predicate will fail. If
% there is more than one chip with the specified device name, the predicate will
% succeed with the first one it finds, and will not backtrack to find additional
% chips.
device_name_of_chip(DeviceName, Chip) :-
    once(sysfs_pwmchip_read(device/name, Chip, DeviceName)).
