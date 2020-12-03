# Parameters:
param cardV; 			# Number of Nodes
param cardE; 			# Number of edges
param k default 1;			# Number of teams 
param lb default 1;
param ub default 2;
param ubLimit default 25;

# Sets:
set V;
set E within {(i,j) in V cross V: i<j}; 			# Set of edges (communication links) 
set Arcs={(i,j) in V cross V: (i,j) in E || (j,i) in E}; 	# set of arcs (directed communication links)
set N{i in V} within V = {j in V: (i,j) in E || (j,i) in E}; 	# N[i] is a set of all neighbors of i
set Teams{i in 0..k-1};
set Goals{i in 0..k-1};
set Agents := union {i in 0..k-1} Teams[i]; 
set Reachable { 0..ubLimit} within V;
set ReachableR {0..ubLimit} within V;
set ReachV {0..ubLimit} within V;
set ReachE {0..ubLimit} within Arcs;
set Pos = {1..5};

# Variables:
var fv{v in V, t in 0..ub, c in 0..k-1} binary;		# unit flow of commodity c passes through e
var fe{(u,v) in E, t in 1..ub, c in 0..k-1, p in Pos} binary;		# unit flow of commodity c passes through e

# Objective function:
maximize maxFlow: sum{c in 0..k-1, g in Goals[c]} fv[g,ub,c];
#maximize maxFlow: sum{c in 0..k-1, g in Goals[c]} w[g];

# Constraints:

# Initial flow
subject to flowConsS1{c in 0..k-1, u in Teams[c]}:
	fv[u,0,c] = 1;
		
subject to flowConsS2{c in 0..k-1, u in V: u not in Teams[c]}:
	fv[u,0,c] = 0;

subject to flowConsG1{c in 0..k-1, u in Goals[c]}:
	fv[u,ub,c] = 1;

subject to flowConsG2{c in 0..k-1, u in V: u not in Goals[c]}:
	fv[u,ub,c] = 0;

subject to flowConsV12{u in V, t in 1..ub,c in 0..k-1}:
	fv[u,t-1,c] = (sum{v in N[u]: u < v} fe[u,v,t,c,1]) + (sum{v in N[u]: v < u} fe[v,u,t,c,2]);

subject to flowConsV3{(u,v) in E, t in 1..ub,c in 0..k-1}:
	fe[u,v,t,c,1] + fe[u,v,t,c,2] = fe[u,v,t,c,3];

subject to flowConsV4{(u,v) in E, t in 1..ub,c in 0..k-1}:
	fe[u,v,t,c,3] = fe[u,v,t,c,4] + fe[u,v,t,c,5];

subject to flowConsV56{v in V, t in 1..ub,c in 0..k-1}:
	 sum{u in N[v]: u < v} fe[u,v,t,c,5] + sum{u in N[v]: v < u} fe[v,u,t,c,4] = fv[v,t,c];

subject to capacityV {u in V, t in 0..ub}:
	sum{c in 0..k-1} fv[u,t,c] <= 1;

subject to capacityE {(u,v) in E, t in 1..ub, p in Pos}:
	sum{c in 0..k-1} fe[u,v,t,c,p] <= 1;
