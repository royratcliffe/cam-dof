:- module(cam, []).
:- use_module(library(settings), [setting/4]).

:- setting(key, atom, cam,
    'Redis stream key to listen to for camera DOF events').

:- setting(group, atom, dof,
    'Redis consumer group for camera DOF events').

:- setting(consumer, atom, env('HOSTNAME'),
    'Name to use for consuming camera DOF events').
