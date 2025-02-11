import jason.environment.Environment;
import jason.asSyntax.*;
import java.util.*;
import java.util.logging.*;
import java.util.Random;
import java.util.Timer;
import java.util.TimerTask;

public class TrainingEnv extends Environment {

	private Logger logger = Logger.getLogger("rl_training.mas2j."+TrainingEnv.class.getName());
	private int crewmateIterations = 0;
	private int crewmateSubIterations = 0;
	private int impostorIterations = 0;
	private int impostorSubIterations = 0;
	private double crewmateEpsilon = 0.3;
	private double impostorEpsilon = 0.3;
	private int numberOfTasks = 5;
	private int numberOfImpostors = 4;
	private int numberOfCrewmates = 5;
	private List<String> crewmatePlausibleActionsForState = new ArrayList<String>();
	private List<String> impostorPlausibleActionsForState = new ArrayList<String>();
	
	@Override
	public void init(String[] args) {
		
		crewmatePlausibleActionsForState.add("standing_look");
		crewmatePlausibleActionsForState.add("standing_move");
		crewmatePlausibleActionsForState.add("taskDetected_look");
		crewmatePlausibleActionsForState.add("taskDetected_repair");
		crewmatePlausibleActionsForState.add("taskDetected_move");
		crewmatePlausibleActionsForState.add("nothingToDo_look");
		crewmatePlausibleActionsForState.add("nothingToDo_move");
		crewmatePlausibleActionsForState.add("wasFixing_trust");
		crewmatePlausibleActionsForState.add("wasKilling_untrust");
		crewmatePlausibleActionsForState.add("reported_trustAccuser_voteForAccuser");
		crewmatePlausibleActionsForState.add("reported_trustAccuser_voteForAccused");
		crewmatePlausibleActionsForState.add("reported_trustAccuser_dontVote");
		crewmatePlausibleActionsForState.add("reported_trustAccused_voteForAccuser");
		crewmatePlausibleActionsForState.add("reported_trustAccused_voteForAccused");
		crewmatePlausibleActionsForState.add("reported_trustAccused_dontVote");
		crewmatePlausibleActionsForState.add("reported_untrustAccuser_voteForAccuser");
		crewmatePlausibleActionsForState.add("reported_untrustAccuser_voteForAccused");
		crewmatePlausibleActionsForState.add("reported_untrustAccuser_dontVote");
		crewmatePlausibleActionsForState.add("reported_untrustAccused_voteForAccuser");
		crewmatePlausibleActionsForState.add("reported_untrustAccused_voteForAccused");
		crewmatePlausibleActionsForState.add("reported_untrustAccused_dontVote");
		crewmatePlausibleActionsForState.add("reported_dontknow_dontVote");
		crewmatePlausibleActionsForState.add("advantageReceived_report");
		
		impostorPlausibleActionsForState.add("standing_look");
		impostorPlausibleActionsForState.add("standing_move");
		impostorPlausibleActionsForState.add("found1_look");
		impostorPlausibleActionsForState.add("found1_deceive");
		impostorPlausibleActionsForState.add("found1_kill");
		impostorPlausibleActionsForState.add("found1_move");
		impostorPlausibleActionsForState.add("found2orMore_look");
		impostorPlausibleActionsForState.add("found2orMore_deceive");
		impostorPlausibleActionsForState.add("found2orMore_kill");
		impostorPlausibleActionsForState.add("found2orMore_move");
		impostorPlausibleActionsForState.add("goalAccomplished_look");
		impostorPlausibleActionsForState.add("goalAccomplished_move");
		impostorPlausibleActionsForState.add("notFound_look");
		impostorPlausibleActionsForState.add("notFound_move");
		impostorPlausibleActionsForState.add("advantageReceived_report");
		impostorPlausibleActionsForState.add("reported_dontVote");
		
		addPercept("crewmate_RL_",Literal.parseLiteral("start"));
		addPercept("impostor_RL_",Literal.parseLiteral("start"));
		
		new Timer().scheduleAtFixedRate(new TimerTask() {
			private int runs = 0;
			public void run() {
				String newSubState = oneOf("wasFixing","wasKilling","reported_trustAccuser","reported_trustAccused","reported_untrustAccuser","reported_untrustAccused","reported_dontknow","advantageReceived");
				removePercept("crewmate_RL_",Literal.parseLiteral("newSubState("+newSubState+")"));
				addPercept("crewmate_RL_",Literal.parseLiteral("newSubState("+newSubState+")"));
				if (++runs > 2000)
					cancel();
			}
		}, 0, 500);
		
		new Timer().scheduleAtFixedRate(new TimerTask() {
			private int runs = 0;
			public void run() {
				String newSubState = oneOf("advantageReceived","reported");
				removePercept("impostor_RL_",Literal.parseLiteral("newSubState("+newSubState+")"));
				addPercept("impostor_RL_",Literal.parseLiteral("newSubState("+newSubState+")"));
				if (++runs > 500)
					cancel();
			}
		}, 0, 500);
		
	}
	
	@Override
	 public void stop() {
		 super.stop();
	 }
	 
	 @Override
	public synchronized boolean executeAction(String player, Structure action) {
		
		if (player.startsWith("crewmate") && action.getFunctor().equals("executeAction")) {
			
			if(crewmateIterations >= 500) {
				addPercept("crewmate_RL_",Literal.parseLiteral("showValues"));
				return true;
			}
			
			String actionName = action.getTerm(0).toString();
			String state = action.getTerm(1).toString();
			String subState = action.getTerm(2).toString();
			
			if(subState.equals("noSubState")) {
				
				String key = state + "_" + actionName;
				int reward;
				if (crewmatePlausibleActionsForState.contains(key))
					reward = 0;
				else
					reward = -1;
				
				String newState = "";
				
				if (key.equals("standing_look"))
					newState = oneOf("taskDetected","nothingToDo");
				else if (state.equals("taskDetected") && !key.equals("taskDetected_repair"))
					newState = "taskDetected";
				else if (state.equals("nothingToDo") && !key.equals("nothingToDo_move"))
					newState = "nothingToDo";
				else
					newState = "standing";
				
				if (key.equals("taskDetected_repair")) {
					reward = 1;
					numberOfTasks--;
				}
				
				if (numberOfTasks == 0) {	//episode concluded, starting new episode
					reward = 100;
					numberOfTasks = 5;
				}
				
				crewmateIterations++;
				
				if (crewmateIterations % 100 == 0 && crewmateEpsilon < 0.8) {
					removePercept("crewmate_RL_",Literal.parseLiteral("updateEpsilon("+crewmateEpsilon+")"));
					crewmateEpsilon = crewmateEpsilon + 0.05;
					addPercept("crewmate_RL_",Literal.parseLiteral("updateEpsilon("+crewmateEpsilon+")"));
				}
			
				addPercept("crewmate_RL_",Literal.parseLiteral("newState("+newState+","+reward+","+crewmateIterations+")"));
				
			} else {
				
				String key = subState + "_" + actionName;
				int reward;
				if (crewmatePlausibleActionsForState.contains(key))
					reward = 0;
				else
					reward = -1;
				
				if (key.equals("reported_trustAccused_voteForAccuser") || key.equals("reported_trustAccuser_voteForAccused")
						|| key.equals("reported_untrustAccused_voteForAccused") || key.equals("reported_untrustAccuser_voteForAccuser")) {
					Random rand = new Random();
					int result = rand.nextInt(2);
					if (result == 1) {
						numberOfImpostors--;
						reward = 1;
					}
				}
				
				if (numberOfImpostors == 0) {	//episode concluded, starting new episode
					reward = 100;
					numberOfImpostors = 4;
				}
				
				crewmateSubIterations++;
				
				addPercept("crewmate_RL_",Literal.parseLiteral("rewardForSubState("+subState+","+actionName+","+reward+","+crewmateSubIterations+")"));
			}
			
			return true;
			
		} else if (player.startsWith("impostor") && action.getFunctor().equals("executeAction")) {
			
			if(impostorIterations >= 2000) {
				addPercept("impostor_RL_",Literal.parseLiteral("showValues"));
				return true;
			}
			
			String actionName = action.getTerm(0).toString();
			String state = action.getTerm(1).toString();
			String subState = action.getTerm(2).toString();
			
			if (subState.equals("noSubState")) {
				
				String key = state + "_" + actionName;
				int reward;
				if (impostorPlausibleActionsForState.contains(key))
					reward = 0;
				else
					reward = -1;
				
				String newState = "";
				
				if (key.equals("standing_look"))
					newState = oneOf("found1","found2orMore","notFound");
				else if (key.equals("found1_look") || key.equals("found1_report") || key.equals("found1_dontVote"))
					newState = "found1";
				else if (key.equals("found1_deceive") || key.equals("found1_kill"))
					newState = "goalAccomplished";
				else if (key.equals("found2orMore_look") || key.equals("found2orMore_report") || key.equals("found2orMore_dontVote"))
					newState = "found2orMore";
				else if (key.equals("found2orMore_deceive") || key.equals("found2orMore_kill"))
					newState = "goalAccomplished";
				else if (state.equals("goalAccomplished") && !key.equals("goalAccomplished_move"))
					newState = "goalAccomplished";
				else if (action.equals("notFound") && !key.equals("notFound_move"))
					newState = "notFound";
				else
					newState = "standing";
				
				if (key.equals("found1_kill")) {
					reward = 10;
					numberOfCrewmates--;
				}
				
				if (key.equals("found2orMore_deceive")) {
					reward = 1;
				}
			
				if (numberOfCrewmates == 0) {
					reward = 100;
					numberOfCrewmates = 5;
				}
				
				impostorIterations++;
			
				if (impostorIterations % 100 == 0 && impostorEpsilon < 0.8) {
					removePercept("impostor_RL_",Literal.parseLiteral("updateEpsilon("+impostorEpsilon+")"));
					impostorEpsilon = impostorEpsilon + 0.05;
					addPercept("impostor_RL_",Literal.parseLiteral("updateEpsilon("+impostorEpsilon+")"));
				}
				
				addPercept("impostor_RL_",Literal.parseLiteral("newState("+newState+","+reward+","+impostorIterations+")"));

			} else {
				
				String key = subState + "_" + actionName;
				int reward;
				if (impostorPlausibleActionsForState.contains(key))
					reward = 0;
				else
					reward = -1;
				
				impostorSubIterations++;
				
				addPercept("impostor_RL_",Literal.parseLiteral("rewardForSubState("+subState+","+actionName+","+reward+","+impostorSubIterations+")"));
			}
			
			return true;
			
		} else {
			//this should never happen
			logger.info("action not implemented");
			return false;
		}
	}
	
	private String oneOf(String... args) {
		
		Random rand = new Random();
		int result = rand.nextInt(args.length);
		return args[result];
	}
}
