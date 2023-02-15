:- use_module(library(assoc)).
:- use_module(library(coinduction)).

:- dynamic involved/2.
:- dynamic count/1.

:- set_prolog_stack(global, limit(100 000 000 000)).
:- set_prolog_stack(trail,  limit(20 000 000 000)).
:- set_prolog_stack(local,  limit(2 000 000 000)).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Tests for the 50 years of Prolog Book   %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


/**************************************************************************************/
/*                        NON PARAMETRIC TRACE EXPRESSIONS (next/3)                   */
/* This code is a super-simplified version of the code available at                   */      
/* https://github.com/RMLatDIBRIS/monitor/blob/master/trace_expressions_semantics.pl  */
/* Simplifications were needed to make the code accessible                            */
/* Compile the code and type test1 or test2                                           */ 
/**************************************************************************************/

/* Transition rules */


%% explicit failure for eps; not just an optimization, it ensures also correctness if
%% a default clause is added at the end, for instance to correctly deal with singleton event type patterns and finite failure
delta(eps,_,_) :- !,fail.


delta(ET:T, E, T) :- !, match(E, ET).

delta(T1\/_, E, T2) :- delta(T1, E, T2),!.
delta(_\/T1, E, T2) :- !, delta(T1, E, T2).

delta(T1|T2, E, T) :- delta(T1, E, T3),!,fork(T3, T2, T).
delta(T1|T2, E, T) :- !, delta(T2, E, T3),fork(T1, T3, T).

delta(T1*T2, E, T) :- delta(T1, E, T3),!,concat(T3, T2, T).
delta(T1*T2, E, T3) :- !,may_halt(T1),delta(T2, E, T3).

delta(T1/\T2, E, T) :- !,delta(T1, E, T3),delta(T2, E, T4),conj(T3, T4, T).

%% explicit failure for prefixing
may_halt(_:_) :- !,fail.

may_halt(eps) :- !.
may_halt(T1\/T2) :- (may_halt(T1), !; may_halt(T2)).
may_halt(T1|T2) :- !, may_halt(T1), may_halt(T2).
may_halt(T1*T2) :- !, may_halt(T1), may_halt(T2).
may_halt(T1/\T2) :- !, may_halt(T1), may_halt(T2).
    
%%% optimizations
fork(0,0,0) :- !.
fork(0,eps,0) :- !.
fork(eps,0,0) :- !.
fork(1,T,T) :- !.
fork(T,1,T) :- !.
fork(eps, T, T) :- !.
fork(T, eps, T) :- !.
fork((T1l|T1r), T2, (T1l|(T1r|T2))) :- !.
fork(T1, T2, (T1|T2)).

concat(0, _, 0) :- !.
concat(1, _, 1) :- !.
concat(eps, T, T) :- !.
concat(T, eps, T) :- !.
concat((T1l*T1r), T2, T1l*(T1r*T2)) :- !.
concat(T1, T2, T1*T2).

conj(eps/\eps, eps) :- !.
conj(1,T,T) :- !.
conj(T,1,T) :- !.
conj((T1l/\T1r), T2, T1l/\(T1r/\T2)) :- !.
conj(T1, T2, T1/\T2).


/****************************************************************************/
/*                     Multi-step PTE semantics (multi_next)                           */
/****************************************************************************/


closure_delta(T, []) :- write('=== TE === \n'), write(T), write('\n no more events to consume\n\n').
closure_delta(T, [Ev|Evs]) :-
  delta(T, Ev, T1), write('=== TE === \n'), write(T), write('\n consumed '), write(Ev), write(' and succeeded in moving on\n\n'), closure_delta(T1, Evs).
closure_delta(T, [Ev|_Evs]) :- write('=== TE === \n'), write(T), write('\n cannot accept '), write(Ev), write(': MONITORING FAILURE\n\n').

/****************************************************************************/
/*                 CENTRALIZED EXAMPLES  AND TESTS                        */
/****************************************************************************/



%%% FIPA Request Protocol %%%

fipa_cn_protocol(P) :-
P =  ((msg(alice, bob, cfp) : T1) |
        (msg(alice, charlie, cfp) : T2) |
        (msg(alice, dave, cfp) : T3) |
        (msg(alice, erika, cfp) : T4) |
        (msg(alice, frank, cfp) : T5)),
T1 = ((msg(bob, alice, refuse) : eps) \/
         (msg(bob, alice, propose) : T1a)),
T1a = ((msg(alice, bob, accept_proposal) : T11) \/
            (msg(alice, bob, reject_proposal) : eps)),
T11 = ((msg(bob, alice, failure) : eps) \/
           (msg(bob, alice, inform_done) : eps) \/
           (msg(bob, alice, inform_result) : eps)),
T2 = ((msg(charlie, alice, refuse) : eps) \/
         (msg(charlie, alice, propose) : T2a)),
T2a = ((msg(alice, charlie, accept_proposal) : T21) \/
            (msg(alice, charlie, reject_proposal) : eps)),
T21 =  ((msg(charlie, alice, failure) : eps) \/
            (msg(charlie, alice, inform_done) : eps) \/
           (msg(charlie, alice, inform_result) : eps)),
T3 = ((msg(dave, alice, refuse) : eps) \/
         (msg(dave, alice, propose) : T3a)),
T3a = ((msg(alice, dave, accept_proposal) : T31) \/
            (msg(alice, dave, reject_proposal) : eps)),
T31 = ((msg(dave, alice, failure) : eps) \/
           (msg(dave, alice, inform_done) : eps) \/
           (msg(dave, alice, inform_result) : eps)),
T4 = ((msg(erika, alice, refuse) : eps) \/
         (msg(erika, alice, propose) : T4a)),
T4a = ((msg(alice, erika, accept_proposal) : T41) \/
            (msg(alice, erika, reject_proposal) : eps)),
T41 = ((msg(erika, alice, failure) : eps) \/
           (msg(erika, alice, inform_done) : eps) \/
           (msg(erika, alice, inform_result) : eps)),
T5 = ((msg(frank, alice, refuse) : eps) \/
         (msg(frank, alice, propose) : T5a)),
T5a = ((msg(alice, frank, accept_proposal) : T51) \/
            (msg(alice, frank, reject_proposal) : eps)),
T51 = ((msg(frank, alice, failure) : eps) \/
           (msg(frank, alice, inform_done) : eps) \/
           (msg(frank, alice, inform_result) : eps)).



fipa_request_protocol(P) :-
P =  ((msg(alice, bob, request) : T1) \/
        (msg(alice, charlie, request) : T2) \/
        (msg(alice, dave, request) : T3) \/
        (msg(alice, erika, request) : T4) \/
        (msg(alice, frank, request) : T5)),
T1 = ((msg(bob, alice, refuse) : eps) \/
         (msg(bob, alice, agree) : T11)),
T11 = ((msg(bob, alice, failure) : eps) \/
           (msg(bob, alice, inform_done) : eps) \/
           (msg(bob, alice, inform_result) : eps)),
T2 = ((msg(charlie, alice, refuse) : eps) \/
         (msg(charlie, alice, agree) : T21)),
T21 =  ((msg(charlie, alice, failure) : eps) \/
            (msg(charlie, alice, inform_done) : eps) \/
           (msg(charlie, alice, inform_result) : eps)),
T3 = ((msg(dave, alice, refuse) : eps) \/
         (msg(dave, alice, agree) : T31)),
T31 = ((msg(dave, alice, failure) : eps) \/
           (msg(dave, alice, inform_done) : eps) \/
           (msg(dave, alice, inform_result) : eps)),
T4 = ((msg(erika, alice, refuse) : eps) \/
         (msg(erika, alice, agree) : T41)),
T41 = ((msg(erika, alice, failure) : eps) \/
           (msg(erika, alice, inform_done) : eps) \/
           (msg(erika, alice, inform_result) : eps)),
T5 = ((msg(frank, alice, refuse) : eps) \/
         (msg(frank, alice, agree) : T51)),
T51 = ((msg(frank, alice, failure) : eps) \/
           (msg(frank, alice, inform_done) : eps) \/
           (msg(frank, alice, inform_result) : eps)).

%%% P2 in the paper %%%
example2(P) :-
P = msg(A, B, invoice(G)) : 
       msg(B, A, payProof(G)):
       (
          (msg(A, B, okPay(G)) : eps) 
          \/
          (msg(A, B, invalidPay(G)) : eps)
       ).

match( msg(alice, bob, invoice(twentyKgApples)), msg(A, B, invoice(G)) ) :- !.
match( msg(bob, alice, payProof(twentyKgApples)), msg(B, A, payProof(G))) :- !.
match( msg(alice, bob, okPay(twentyKgApples)), msg(A, B, okPay(G))) :- !.
match( msg(alice, bob, invalidPay(twentyKgApples)), msg(A, B, invalidPay(G))) :- !.

match(Event, Event).

trace1([msg(alice, charlie, request), msg(charlie, alice, agree), msg(charlie, alice, inform_done)]).
trace2([msg(alice, charlie, request), msg(charlie, alice, agree), msg(charlie, alice, agree)]).


test1 :-
fipa_request_protocol(T),
trace1(Events),
closure_delta(T, Events).

test2 :-
fipa_request_protocol(T),
trace2(Events),
closure_delta(T, Events).

test3 :-
T = msg(A, B, invoice(G)) : 
       msg(B, A, payProof(G)):
       ((msg(A, B, okPay(G)) : eps) \/
        (msg(A, B, invalidPay(G)) : eps)),
Evs = [msg(alice, bob, invoice(twentyKgApples)),
         msg(bob, alice, payProof(twentyKgApples)),
         msg(alice, bob, invalidPay(twentyKgApples))],
closure_delta(T, Evs).

test4 :-
T = msg(A, B, invoice(G)) : 
       msg(B, A, payProof(G)):
       ((msg(A, B, okPay(G)) : eps) \/
        (msg(A, B, invalidPay(G)) : eps)),
Evs = [msg(alice, bob, invalidPay(twentyKgApples))],
closure_delta(T, Evs).