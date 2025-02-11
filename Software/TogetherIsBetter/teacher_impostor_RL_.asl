// Agent teacher_impostor_RL_.asl in project rl_training.mas2j

/* Initial beliefs and rules */

/* Initial goals */

//!teach([s(found2orMore, kill, 3), s(found1, kill, -3)]).
!teach([]).

/* Plans */

@teachingPlan[atomic]
+!teach([s(State, Action, Value)|Tail]) : true
<- .print("teaching the impostor that ", Action, " in the ", State, " state  has value ", Value); .send(impostor_RL_, tell, given_state_action(State,_,Action,Value)); !teach(Tail).

+!teach([]) : true
<- .print("teaching completed").


