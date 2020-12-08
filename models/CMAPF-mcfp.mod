# Parameters:
param cardV; 			# Number of Nodes
param cardE; 			# Number of edges
param k default 1;			# Number of teams 
param lb default 1;
param ub default 2;
param ubLimit default 100;

# Sets:
set V;
set E within {(i,j) in V cross V: i<j}; 			# Set of edges (communication links) 
set Arcs={(i,j) in V cross V: (i,j) in E || (j,i) in E}; 	# set of arcs (directed communication links)
set N{i in V} within V = {j in V: (i,j) in E || (j,i) in E}; 	# N[i] is a set of all neighbors of i
set Teams{i in 0..k-1};
set Goals{i in 0..k-1};
set Agents := union {i in 0..k-1} Teams[i]; 

set Reachable {0..k-1, 0..ubLimit} within V;   
set ReachableR {0..k-1, 0..ubLimit} within V; 
set ReachV {0..k-1, 0..ubLimit} within V;   
set ReachE {0..k-1, 0..ubLimit} within Arcs;


set Pos = {1..5};

# Variables:
var fv{t in 0..ub, c in 0..k-1, v in V} binary;		# unit flow of commodity c passes through e
#var fe{ t in 1..ub, c in 0..k-1, p in Pos, (u,v) in E: u in ReachV[c,t-1] and u in ReachV[c,t] and v in ReachV[c,t-1] and v in ReachV[c,t]} binary;		# unit flow of commodity c passes through e
var fe{ t in 1..ub, c in 0..k-1, p in Pos, (u,v) in E} binary;		# unit flow of commodity c passes through e

# Objective function:
maximize maxFlow: sum{c in 0..k-1, g in Goals[c]} fv[ub,c,g];
#maximize maxFlow: sum{c in 0..k-1, g in Goals[c]} w[g];

# Constraints:

# Initial flow
subject to flowConsS1{c in 0..k-1, u in Teams[c]}:
	fv[0,c,u] = 1;
		
subject to flowConsS2{c in 0..k-1, u in V: u not in Teams[c]}:
	fv[0,c,u] = 0;

subject to flowConsG1{c in 0..k-1, u in Goals[c]}:
	fv[ub,c,u] = 1;

subject to flowConsG2{c in 0..k-1, u in V: u not in Goals[c]}:
	fv[ub,c,u] = 0;

subject to flowConsV12{t in 1..ub,c in 0..k-1, u in V}:
	fv[t-1,c,u] = (sum{v in N[u]: u < v} fe[t,c,1,u,v]) + (sum{v in N[u]: v < u } fe[t,c,2,v,u]);

subject to flowConsV3{t in 1..ub,c in 0..k-1, (u,v) in E}:
	fe[t,c,1,u,v] + fe[t,c,2,u,v] = fe[t,c,3,u,v];

subject to flowConsV4{t in 1..ub,c in 0..k-1, (u,v) in E}:
	fe[t,c,3,u,v] = fe[t,c,4,u,v] + fe[t,c,5,u,v];

subject to flowConsV56{ t in 1..ub,c in 0..k-1, v in V}:
	 sum{u in N[v]: u < v } fe[t,c,5,u,v] + sum{u in N[v]: v < u } fe[t,c,4,v,u] = fv[t,c,v];

#subject to capacityV {c1 in 0..k-1, c2 in c1+1..k-1,t in 0..ub, u in V: u in ReachV[c1,t] and u in ReachV[c2,t]}:
#	fv[t,c1,u] + fv[t,c2,u] <= 1;

#subject to capacityE {c1 in 0..k-1, c2 in c1+1..k-1, t in 1..ub, p in Pos,(u,v) in E}:
#	fe[t,c1,p,u,v] + fe[t,c2,p,u,v] <= 1;

subject to capacityV {t in 0..ub, u in V}:
	sum{c in 0..k-1} fv[t,c,u] <= 1;

subject to capacityE {(u,v) in E, t in 1..ub, p in Pos}:
	sum{c in 0..k-1} fe[t,c,p,u,v] <= 1;
