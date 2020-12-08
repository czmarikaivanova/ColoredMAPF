# Parameters:
param cardV; 			# Number of Nodes
param cardE; 			# Number of edges
param k;			# Number of teams 
param lb default 0;
param ub default 50;


# Sets:
set V;
set E within {(i,j) in V cross V: i<j}; 			# Set of edges (communication links) 
set Arcs={(i,j) in V cross V: (i,j) in E || (j,i) in E}; 	# set of arcs (directed communication links)
set N{i in V} within V = {j in V: (i,j) in E || (j,i) in E}; 	# N[i] is a set of all neighbors of i
set Teams{i in 0..k-1};
set Goals{i in 0..k-1};
set Agents := union {i in 0..k-1} Teams[i]; 

# Variables:
var x{ a in Agents, v in V,t in 0..ub} binary;			# x[a,v,t] = 1 iff agent a is in v in time t
#var y{ u in V, v in N[u], t in 1..ub} binary;	# y[u,v,t] == 1 iff (u,v) is used in t

# Objective function:
maximize maxCaptured: sum{i in 0..k-1, a in Teams[i], g in Goals[i]} x[a,g,ub];

# Constraints:

# Each vertex has at most one agent
subject to oneAgentInNode {t in  0 .. ub, v in V}:
	sum{a in Agents} x[a,v,t] <= 1;

# Agent in one node
subject to oneNodeForAgent {t in 0 .. ub, a in Agents}:
	sum{v in V} x[a,v,t] = 1;


# Agents move along edges or stay at a vertex
subject to moveOrStay {a in Agents,v in V, t in 0..ub-1}:
	x[a,v,t] <=  x[a,v,t+1] + sum{u in N[v]} x[a,u,t+1];

# edge collisions are avoided
subject to noEdgeCollision {u in V, v in N[u], t in 0..ub-1, a in Agents, b in Agents: a<>b}:
	x[a,u,t] + x[a,v,t+1] + x[b,v,t] + x[b,u,t+1] <= 3;
#subject to noEdgeCollision {u in V, v in N[u], t in 1..ub}:
#	y[u,v,t] + y[v,u,t] <= 1;


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

# ---------------- constraints on y ----------------------------
#subject to xyrel1 {a in Agents, v in V, t in 1..ub}:
#	x[a,v,t] <= sum{u in N[v]} y[u,v,t];
#
#subject to xyrel2 {a in Agents, v in V, t in 1..ub}:
#	x[a,v,t-1] <= sum{u in N[v]} y[v,u,t];
#
#subject to alongEdgeInNode {a in Agents, u in V, v in N[u],t in 1..ub-0}:
#	x[a,u,t-1] + x[a,v,t] -1 <= y[u,v,t];
#
#subject to alongEdgeInNode1 {u in V, v in N[u],t in 1..ub-0}:
#	y[u,v,t] <= sum{a in Agents} x[a,u,t-1];
#
#subject to alongEdgeInNode2 {u in V, v in N[u],t in 1..ub-0}:
#	y[u,v,t] <= sum{a in Agents} x[a,v,t];
# -----------------------v VALID INEQUALIETIES ------------------
#subject to VInoMoveIfNoNeigh {u in V, t in lb..ub-1, a in Agents,v in V:v not in N[u]}:
#	x[a,u,t] + x[a,v,t+1] <= 1;
