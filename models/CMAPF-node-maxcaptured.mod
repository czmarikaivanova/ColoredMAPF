# Parameters:
param cardV; 			# Number of Nodes
param cardE; 			# Number of edges
param k;			# Number of teams 
param lb default 0;
param ub default 50;


# Sets:
set V;
set E within {(i,j) in V cross V: i<j}; 			# Set of edges (communication links) 
set Arcs={(i,j) in V cross V: (i,j) in E || (j,i) in E}; 		# set of arcs (directed communication links)
set N{i in V} within V = {j in V: (i,j) in E || (j,i) in E}; 	# N[i] is a set of all neighbors of i
set Teams{i in 0..k-1};
set Goals{i in 0..k-1};
set Agents := union {i in 0..k-1} Teams[i]; 

# Variables:
var x{ a in Agents, v in V,t in lb..ub} binary;		# x[i,j,t] = 1 iff a signal is sent via the arc (i,j) in time t			

# Objective function:
maximize maxCaptured: sum{i in 0..k-1, a in Teams[i], g in Goals[i]} x[a,g,ub];

# Constraints:

# Each vertex has at most one agent
subject to oneAgentInNode {t in lb .. ub, v in V}:
	sum{a in Agents} x[a,v,t] <= 1;

# Agent in one node
subject to oneNodeForAgent {t in lb .. ub, a in Agents}:
	sum{v in V} x[a,v,t] = 1;


# Agents move along edges or stay at a vertex
subject to moveOrStay {a in Agents,v in V, t in lb..ub-1}:
	x[a,v,t] <=  x[a,v,t+1] + sum{u in N[v]} x[a,u,t+1];

# edge collisions are avoided
subject to noEdgeCollision {u in V, v in N[u], t in lb..ub-1, a in Agents, b in Agents: a<>b}:
	x[a,u,t] + x[a,v,t+1] + x[b,v,t] + x[b,u,t+1] <= 3;

# All goals are eventually reached by a suitable agent
#subject to allArive {i in 0..k-1, a in Teams[i]}:
#	sum { g in Goals[i]} x[a,g,ub] = 1;

# c[t] is true if some goals are not reached by a suitable agent
#subject to stillGoes {i in 0..k-1, a in Teams[i], t in lb..ub-1}:
#	1 - sum{ g in Goals[i]} x[a,g,t] <= c[t];

# if still goes in t, then in t-1 also (vi?)
#subject to timing {t in lb..ub-1}:
#	c[t+1] <= c[t];


# initial positions - agents are identified by their initial node
subject to init {a in Agents}:
	x[a,a,0] = 1;


# -----------------------v VALID INEQUALIETIES ------------------
subject to VInoMoveIfNoNeigh {u in V, t in lb..ub-1, a in Agents,v in V:v not in N[u]}:
	x[a,u,t] + x[a,v,t+1] <= 1;
