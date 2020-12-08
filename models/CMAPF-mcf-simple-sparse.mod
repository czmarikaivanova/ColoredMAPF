# Parameters:
param cardV; 			# Number of Nodes
param cardE; 			# Number of edges
param k default 1;			# Number of teams 
param lb default 1;
param ub default 2;
param ubLimit default 100;
param maxL = 4*ub-1;

# Sets:
set V;
set E within {(i,j) in V cross V: i<j}; 			# Set of edges (communication links) 
set L = {0..maxL};
set Arcs={(i,j) in V cross V: (i,j) in E || (j,i) in E || i = j}; 	# set of arcs (directed communication links)
set N{i in V} within V = {j in V: (i,j) in E || (j,i) in E || j = i}; 	# N[i] is a set of all neighbors of i
set Teams{i in 0..k-1};
set Goals{i in 0..k-1};
set Agents := union {i in 0..k-1} Teams[i]; 
set Reachable {c in 0..k-1, 0..ubLimit} within V;
set ReachableR {c in 0..k-1, 0..ubLimit} within V;
set ReachV {c in 0..k-1, 0..ubLimit} within V;
set ReachE {c in 0..k-1, 0..ubLimit} within Arcs;

# Variables:
var f{c in 0..k-1, t in 1..ub, (u,v) in Arcs: u in ReachV[c,t-1] and v in ReachV[c,t]} binary;		# unit flow of commodity c passes through e

# Objective function:
maximize maxFlow: sum{c in 0..k-1, (u,v) in Arcs: v in Goals[c] and u in ReachV[c,ub-1] and v in ReachV[c,ub]} f[c,ub,u,v];

# Constraints:

# Initial flow
subject to flowConsS1{c in 0..k-1, u in Teams[c]}:
	sum{v in N[u]: v in ReachV[c,1]} f[c,1,u,v] = 1;

#subject to flowConsS2{c in 0..k-1, u in V: u not in Teams[c] and u in ReachV[c,0]}:
#	sum{v in N[u]} f[c,1,u,v] = 0;
		
subject to flowConsV{c in 0..k-1, t in 1..ub-1,v in V: v in ReachV[c,t]}:
	sum{u in N[v]: u in ReachV[c,t-1]} f[c,t,u,v] = sum {w in N[v]: w in ReachV[c,t+1]} f[c,t+1,v,w];

subject to flowConsG1{c in 0..k-1, v in Goals[c] }:
	sum{u in N[v]: u in ReachV[c,ub-1]} f[c,ub,u,v] = 1;

#subject to flowConsG2{c in 0..k-1, v in V: v not in Goals[c] }:
#	sum{u in N[v]: u in ReachV[c,ub-1]} f[c,ub,u,v] = 0;

#subject to capacity {t in 1..ub,(u,v) in Arcs}:
#	sum{c in 0..k-1: u in ReachV[c,t-1] and v in ReachV[c,t]} f[c,t,u,v] <= 1;

# -1 because we have flowConsG1
subject to nocrash {t in 1..ub-1,v in V}:
	sum{c in 0..k-1,u in N[v]: u in ReachV[c,t-1] and v in ReachV[c,t]} f[c,t,u,v] <= 1; 

subject to noswap {t in 1..ub,(u,v) in E}:
	sum{c in 0..k-1: u in ReachV[c,t-1] and v in ReachV[c,t] } f[c,t,u,v] + sum{c in 0..k-1: v in ReachV[c,t-1] and u in ReachV[c,t] } f[c,t,v,u] <=1;

# swap allowed only for teammates
#subject to noswap {t in 1..ub, (u,v) in E,  c1 in 0..k-1, c2 in 0..k-1: c1 != c2 and u in ReachV[c1,t-1] and v in ReachV[c1,t] and v in ReachV[c2,t-1] and u in ReachV[c2,t]}:
#	f[c1,t,u,v] + f[c2,t,v,u] <= 1;
