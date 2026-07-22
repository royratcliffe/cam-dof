
:- setting(key, atom, env('DOF_KEY', dof_key),
    'Redis stream key to listen to for DOF events').

:- setting(group, atom, env('DOF_GROUP', dof_group),
    'Redis consumer group for DOF events').

:- setting(consumer, atom, env('DOF_CONSUMER', dof_consumer),
    'Name to use for consuming DOF events').

:- setting(idle_timeout, number, env('DOF_IDLE_TIMEOUT', 5),
    'Timeout in seconds for idling').

:- setting(wait_timeout, number, env('DOF_WAIT_TIMEOUT', 5),
    'Timeout in seconds for waiting').

create_dof_thread :-
    (   thread_property(_, alias(dof))
    ->  true
    ;   thread_create(dof, _, [alias(dof), detached(true)])
    ).

dof :-
    setting(key, Key),
    (   redis(default, get(Key:duty_cycle), DutyCycle)
    ->  dof_(DutyCycle)
    ;   dof____
    ).

dof_(DutyCycle) :-
    dof_enable(cam),
    dof__(DutyCycle).

dof__(DutyCycle) :-
    dof_duty_cycle(cam, DutyCycle),
    setting(key, Key),
    redis(default, set(Key:duty_cycle, DutyCycle), status(ok)),
    dof___(DutyCycle).

dof___(DutyCycle) :-
    thread_self(Self),
    setting(idle_timeout, Timeout),
    (   thread_get_message(Self, DutyCycle1, [timeout(Timeout)])
    ->  (   thread_peek_message(Self, _)
        ->  dof___(DutyCycle)
        ;   (   DutyCycle == DutyCycle1
            ->  dof___(DutyCycle1)
            ;   dof__(DutyCycle1)
            )
        )
    ;   dof____
    ).

dof____ :-
    dof_disable(cam),
    thread_self(Self),
    setting(wait_timeout, Timeout),
    (   thread_get_message(Self, DutyCycle, [timeout(Timeout)])
    ->  dof_(DutyCycle)
    ;   dof
    ).
