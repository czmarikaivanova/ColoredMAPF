# Parameters:
param cardV; 			# Number of Nodes
param cardE; 			# Number of edges
param k default 1;			# Number of teams 
param lb default 1;
param ub default 2;
param ubLimit default 25;
param maxL = 4*ub-1;

# Sets:
set V;
set E within {(i,j) in V cross V: i<j}; 			# Set of edges (communication links) 
set L = {0..maxL};
set Arcs={(i,j) in V cross V: (i,j) in E || (j,i) in E}; 	# set of arcs (directed communication links)
set N{i in V} within V = {j in V: (i,j) in E || (j,i) in E}; 	# N[i] is a set of all neighbors of i
set Teams{i in 0..k-1};
set Goals{i in 0..k-1};
set Agents := union {i in 0..k-1} Teams[i]; 
set Reachable { 0..ubLimit} within V;
set ReachableR {0..ubLimit} within V;
set ReachV {0..ubLimit} within V;
set ReachE {0..ubLimit} within Arcs;

# Sets F
set VF; 
set TeamsF{i in 0..k-1}  = {u in VF: u in Teams[i]};
set GoalsF{i in 0..k-1}; # all the time changing, updated in runfile.
set AF within {(u,v) in VF cross VF};

# Variables:
var f{c in 0..k-1, (u,v) in AF} binary;		# unit flow of commodity c passes through e

# Objective function:
maximize maxFlow: sum{c in 0..k-1, (u,v) in AF: v in GoalsF[c]} f[c,u,v];
#maximize maxFlow: sum{c in 0..k-1, g in Goals[c]} w[g];

# Constraints:

# Initial flow
subject to flowConsS{c in 0..k-1, u in TeamsF[c]}:
	sum{(u,v) in AF} f[c,u,v] = 1;
		
subject to flowConsV{c in 0..k-1, v in VF: v not in TeamsF[c] and v not in GoalsF[c]}:
	sum{(u,v) in AF} f[c,u,v] = sum {(v,w) in AF} f[c,v,w];

subject to flowConsG{c in 0..k-1, v in GoalsF[c] }:
	sum{(u,v) in AF} f[c,u,v] = 1;

#subject to capacity {i in 0..k-1, j in i+1..k-1, (u,v) in (AF[i] intersect AF[j])}:
#	f[i,u,v] + f[j,u,v] <= 1;

subject to capacity {(u,v) in AF}:
	sum{c in 0..k-1} f[c,u,v] <= 1;
