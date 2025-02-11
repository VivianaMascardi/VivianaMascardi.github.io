state_action(standing,noSubState,look,0).
state_action(standing,noSubState,deceive,0).
state_action(standing,noSubState,kill,0).
state_action(standing,noSubState,move,0).
state_action(standing,noSubState,report,0).
state_action(standing,noSubState,dontVote,0).

state_action(standing,advantageReceived,look,0).
state_action(standing,advantageReceived,deceive,0).
state_action(standing,advantageReceived,kill,0).
state_action(standing,advantageReceived,move,0).
state_action(standing,advantageReceived,report,0).
state_action(standing,advantageReceived,dontVote,0).

state_action(standing,reported,look,0).
state_action(standing,reported,deceive,0).
state_action(standing,reported,kill,0).
state_action(standing,reported,move,0).
state_action(standing,reported,report,0).
state_action(standing,reported,dontVote,0).

state_action(found1,noSubState,look,0).
state_action(found1,noSubState,deceive,0).
state_action(found1,noSubState,kill,0).
state_action(found1,noSubState,move,0).
state_action(found1,noSubState,report,0).
state_action(found1,noSubState,dontVote,0).

state_action(found1,advantageReceived,look,0).
state_action(found1,advantageReceived,deceive,0).
state_action(found1,advantageReceived,kill,0).
state_action(found1,advantageReceived,move,0).
state_action(found1,advantageReceived,report,0).
state_action(found1,advantageReceived,dontvote,0).

state_action(found1,reported,look,0).
state_action(found1,reported,deceive,0).
state_action(found1,reported,kill,0).
state_action(found1,reported,move,0).
state_action(found1,reported,report,0).
state_action(found1,reported,dontvote,0).

state_action(found2orMore,noSubState,look,0).
state_action(found2orMore,noSubState,deceive,0).
state_action(found2orMore,noSubState,kill,0).
state_action(found2orMore,noSubState,move,0).
state_action(found2orMore,noSubState,report,0).
state_action(found2orMore,noSubState,dontVote,0).

state_action(found2orMore,advantageReceived,look,0).
state_action(found2orMore,advantageReceived,deceive,0).
state_action(found2orMore,advantageReceived,kill,0).
state_action(found2orMore,advantageReceived,move,0).
state_action(found2orMore,advantageReceived,report,0).
state_action(found2orMore,advantageReceived,dontVote,0).

state_action(found2orMore,reported,look,0).
state_action(found2orMore,reported,deceive,0).
state_action(found2orMore,reported,kill,0).
state_action(found2orMore,reported,move,0).
state_action(found2orMore,reported,report,0).
state_action(found2orMore,reported,dontVote,0).

state_action(goalAccomplished,noSubState,look,0).
state_action(goalAccomplished,noSubState,deceive,0).
state_action(goalAccomplished,noSubState,kill,0).
state_action(goalAccomplished,noSubState,move,0).
state_action(goalAccomplished,noSubState,report,0).
state_action(goalAccomplished,noSubState,dontVote,0).

state_action(goalAccomplished,advantageReceived,look,0).
state_action(goalAccomplished,advantageReceived,deceive,0).
state_action(goalAccomplished,advantageReceived,kill,0).
state_action(goalAccomplished,advantageReceived,move,0).
state_action(goalAccomplished,advantageReceived,report,0).
state_action(goalAccomplished,advantageReceived,dontVote,0).

state_action(goalAccomplished,reported,look,0).
state_action(goalAccomplished,reported,deceive,0).
state_action(goalAccomplished,reported,kill,0).
state_action(goalAccomplished,reported,move,0).
state_action(goalAccomplished,reported,report,0).
state_action(goalAccomplished,reported,dontVote,0).

state_action(notFound,noSubState,look,0).
state_action(notFound,noSubState,deceive,0).
state_action(notFound,noSubState,kill,0).
state_action(notFound,noSubState,move,0).
state_action(notFound,noSubState,report,0).
state_action(notFound,noSubState,dontVote,0).

state_action(notFound,advantageReceived,look,0).
state_action(notFound,advantageReceived,deceive,0).
state_action(notFound,advantageReceived,kill,0).
state_action(notFound,advantageReceived,move,0).
state_action(notFound,advantageReceived,report,0).
state_action(notFound,advantageReceived,dontVote,0).

state_action(notFound,reported,look,0).
state_action(notFound,reported,deceive,0).
state_action(notFound,reported,kill,0).
state_action(notFound,reported,move,0).
state_action(notFound,reported,report,0).
state_action(notFound,reported,dontVote,0).

learning_rate(0.2).
discount_factor(0.1).
epsilon(0.3).

@startPlan[atomic]
+start <-
    .wait(3000);
	.print("starting after waiting for my teacher to teach me");                   
	+myState(standing,noSubState).

@myStatePlan[atomic]
+myState(S1,S2) : epsilon(EPSILON) <-
	.findall(action_value(V,A),state_action(S1,S2,A,V),L);
	.random(R);
	if (R < EPSILON) {
		.max(L,action_value(Value,Action));
	} else {
		.shuffle(L,L1);
		.nth(0,L1,action_value(Value,Action));
	}
	+myAction(Action);
	executeAction(Action,S1,S2).
	

@newStatePlanNotGiven[atomic]
+newState(NS1,R,N) : myState(S1,S2) & myAction(A) &  state_action(S1,S2,A,V) & not given_state_action(S1,S2,A,_) & learning_rate(ALPHA) & discount_factor(GAMMA) <-
	.findall(value(V1),state_action(NS1,S2,A1,V1),L);
	.max(L,value(Value));
	NV = V + ALPHA * (R + GAMMA * Value - V);
	-myAction(A);
	-myState(S1,S2);
	-state_action(S1,S2,A,V);
	+state_action(S1,S2,A,NV);
	+myState(NS1,S2).	
	

@newStatePlanGiven[atomic]
+newState(NS1,R,N) : myState(S1,S2) & myAction(A) & state_action(S1,S2,A,V) & given_state_action(S1,S2,A,GivenV)  <-
	-myAction(A);
	-myState(S1,S2);
	-state_action(S1,S2,A,V);
	+state_action(S1,S2,A,GivenV);
	+myState(NS1,S2).
											
@newSubStatePlan[atomic]
+newSubState(NS2)[source(percept)] : myState(S1,S2) & epsilon(EPSILON) <-
	-newSubState(NS2)[source(percept)];
	.findall(action_value(V,A),state_action(S1,NS2,A,V),L);
	.random(R);
	if (R < EPSILON) {
		.max(L,action_value(Value,Action));
	} else {
		.shuffle(L,L1);
		.nth(0,L1,action_value(Value,Action));
	}
	executeAction(Action,S1,NS2).
											
@rewardForSubStatePlan[atomic]
+rewardForSubState(S2,A,R,N) : learning_rate(ALPHA) & discount_factor(GAMMA) <-
	.findall(S1,state_action(S1,S2,A,V),L);
	.set.create(S);
	.set.union(S,L);
	for ( .member(X,S) ) {
		.findall(V,state_action(X,S2,A,V),L1);
		.nth(0,L1,Value);
		NV = Value + ALPHA * (R + GAMMA - Value);
		-state_action(X,S2,A,Value);
		+state_action(X,S2,A,NV)
	}.
											
@updateEpsilonPlan[atomic]
+updateEpsilon(NEW_EPSILON) : epsilon(EPSILON) <-
	-epsilon(EPSILON);
	+epsilon(NEW_EPSILON).

@showValuesPlan[atomic]
+showValues <- 
	.abolish(newState(_,_,_));
	.abolish(rewardForSubState(_,_,_,_));
	.print("******************************************************");
	.findall(S1,state_action(S1,S2,A,V),L);
	.set.create(Set);
	.set.union(Set,L);
	for ( .member(X,Set) ) {
		.findall(action_value(V,A),state_action(X,noSubState,A,V),L1);
		.max(L1,action_value(Value,Action));
		.print("state_action(",X,",",Action,")");
	}
	.findall(S2,state_action(S1,S2,A,V),L2);
	.set.create(Set1);
	.set.union(Set1,L2);
	.set.remove(Set1,noSubState);
	for ( .member(X,Set1) ) {
		.findall(action_value(V,A),state_action(S1,X,A,V),L3);
		.max(L3,action_value(Value1,Action1));
		.print("substate_action(",X,",",Action1,")");
	}.
	
/*
Without safe RL
[impostor_RL_] state_action(found1,kill)
[impostor_RL_] state_action(found2orMore,deceive)
[impostor_RL_] state_action(goalAccomplished,move)
[impostor_RL_] state_action(notFound,move)
[impostor_RL_] state_action(standing,look)
[impostor_RL_] substate_action(advantageReceived,report)
[impostor_RL_] substate_action(reported,report)
*/

/* 
With safe RL1, bad_state_action(found2orMore,_,kill,_).
[impostor_RL_] state_action(found1,kill)
[impostor_RL_] state_action(found2orMore,deceive)
[impostor_RL_] state_action(goalAccomplished,move)
[impostor_RL_] state_action(notFound,look)
[impostor_RL_] state_action(standing,look)
[impostor_RL_] substate_action(advantageReceived,report)
[impostor_RL_] substate_action(reported,dontVote)
*/

/* 
With safe RL2, bad_state_action(found2orMore,_,kill,_).
[impostor_RL_] state_action(found1,kill)
[impostor_RL_] state_action(found2orMore,deceive)
[impostor_RL_] state_action(goalAccomplished,move)
[impostor_RL_] state_action(notFound,look)
[impostor_RL_] state_action(standing,look)
[impostor_RL_] substate_action(advantageReceived,report)
[impostor_RL_] substate_action(reported,dontVote)
*/

/* 
With safe RL3, bad_state_action(found2orMore,_,deceive,_).
[impostor_RL_] state_action(found1,kill)
[impostor_RL_] state_action(found2orMore,move)
[impostor_RL_] state_action(goalAccomplished,move)
[impostor_RL_] state_action(notFound,look)
[impostor_RL_] state_action(standing,look)
[impostor_RL_] substate_action(advantageReceived,report)
[impostor_RL_] substate_action(reported,dontVote)
*/

/* 
With safe RL4, bad_state_action(found2orMore,_,deceive,_). bad_state_action(found1,_,kill,_).
[impostor_RL_] state_action(found1,move)
[impostor_RL_] state_action(found2orMore,move)
[impostor_RL_] state_action(goalAccomplished,move)
[impostor_RL_] state_action(notFound,move)
[impostor_RL_] state_action(standing,move)
[impostor_RL_] substate_action(advantageReceived,report)
[impostor_RL_] substate_action(reported,dontVote)
*/
