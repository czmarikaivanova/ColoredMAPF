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
set Reachable {0..k-1, 0..ubLimit} within V;
set ReachE {0..k-1, 0..ubLimit} within Arcs;

#set VF =      { (u,v,l) in V cross V cross L : u = v      and  l in 0..maxL   by 4 } 	# input layer
#	union { (u,v,l) in V cross V cross L : u = v      and  l in 3..maxL   by 4 }	# output layer
#	union { (u,v,l) in V cross V cross L : (u,v) in E and  l in 1..maxL-2 by 4 }	# input edge layer
#	union { (u,v,l) in V cross V cross L : (u,v) in E and  l in 2..maxL-1 by 4 };	# output edge layer

set VF  =	 { (u,v,l) in V cross V cross L: u=v and l in 0..maxL by 4 and u in union {i in 0..k-1} Reachable[i,l div 4]} 				 # input layer 
	union	 { (u,v,l) in V cross V cross L: u=v and l in 3..maxL by 4 and u in union {i in 0..k-1} Reachable[i,l div 4+1]}  				 # output layer
	union 	 { (u,v,l) in V cross V cross L: ((u,v) in union {i in 0..k-1} ReachE[i,l div 4 + 1] or (v,u) in union {i in 0..k-1}ReachE[i,l div 4 + 1]) and u<v and l in 1..maxL-2 by 4}	 # input edge layer 
	union 	 { (u,v,l) in V cross V cross L: ((u,v) in union {i in 0..k-1} ReachE[i,l div 4 + 1] or (v,u) in union {i in 0..k-1}ReachE[i,l div 4 + 1]) and u<v and l in 2..maxL-1 by 4};    # output edge laye


set TeamsF{i in 0..k-1} within VF = {(u,v,l) in VF: u in Teams[i] and u = v and l = 0};
set GoalsF{i in 0..k-1} within VF = {(u,v,l) in VF: u in Goals[i] and u = v and l = maxL};

#set AF =      { ( (u,u,l), (u,v,l+1) ) in VF cross VF: u in V and v in V and (u,v) in E and l in 0..3*ub-3 by 3 }
#	union { ( (v,v,l), (u,v,l+1) ) in VF cross VF: (u,v) in E and l in 0..3*ub-3 by 3 } 
#	union { ( (u,v,l), (u,v,l+1) ) in VF cross VF: (u,v) in E and l in 1..3*ub-2 by 3 } 
#	union { ( (u,v,l), (u,u,l+1) ) in VF cross VF: (u,v) in E and l in 2..3*ub-1 by 3 }
#	union { ( (u,v,l), (v,v,l+1) ) in VF cross VF: (u,v) in E and l in 2..3*ub-1 by 3 };

set AF =      {  (u1,v1,l1,u2,v2,l2)  in VF cross VF: u1 = v1 and v1 = u2 and (u2,v2) in E and l1 in 0..maxL-3 by 4 and l2 = l1 + 1}	# right-wise input layer edge
	union {  (u1,v1,l1,u2,v2,l2)  in VF cross VF: u1 = v1 and v1 = v2 and (u2,v2) in E and l1 in 0..maxL-3 by 4 and l2 = l1 + 1} 	# left-wise input layer edge
	union {  (u1,v1,l1,u2,v2,l2)  in VF cross VF: u1 = u2 and v1 = v2 and (u1,v1) in E and l1 in 1..maxL-2 by 4 and l2 = l1 + 1}	# shared edge layer 
	union {  (u1,v1,l1,u2,v2,l2)  in VF cross VF: u1 = u2 and u2 = v2 and (u1,v1) in E and l1 in 2..maxL-1 by 4 and l2 = l1 + 1}	# left-wise output layer
	union {  (u1,v1,l1,u2,v2,l2)  in VF cross VF: v1 = u2 and u2 = v2 and (u1,v1) in E and l1 in 2..maxL-1 by 4 and l2 = l1 + 1}	# right-wise output layer
	union {  (u1,v1,l1,u2,v2,l2)  in VF cross VF: u1 = v1 and v1 = u2 and u2 = v2 	   and l1 in 3..maxL-4 by 4 and l2 = l1 + 1};	# shared node layer
#	union {  (u1,v1,l1,u2,v2,l2)  in VF cross VF: u1 = v1 and v1 = u2 and u2 = v2 	   and l1 in 0..maxL-3 by 4 and l2 = l1 + 3};	# no move edge

#set AF within {  (u1,v1,l1,u2,v2,l2)  in VF cross VF};

# Variables:
var f{c in 0..k-1, (u1,v1,l1,u2,v2,l2) in AF} binary;			# unit flow of commodity c passes through e
#var w{g in AllGoals} binary; # if goal g captured 

# Objective function:
maximize maxFlow: sum{c in 0..k-1, (u1,v1,l1,u2,v2,l2) in AF: (u2,v2,l2) in GoalsF[c]} f[c,u1,v1,l1,u2,v2,l2];
#maximize maxFlow: sum{c in 0..k-1, g in Goals[c]} w[g];

# Constraints:

# Initial flow
subject to flowConsS{c in 0..k-1, (u1,v1,l1) in TeamsF[c]}:
	sum{(u1,v1,l1,u2,v2,l2) in AF} f[c,u1,v1,l1,u2,v2,l2] = 1;
		
subject to flowConsV{c in 0..k-1, (u,v,l) in VF: (u,v,l) not in TeamsF[c] and (u,v,l) not in GoalsF[c]}:
	sum{(u1,v1,l-1,u,v,l) in AF} f[c,u1,v1,l-1,u,v,l] = sum {(u,v,l,u2,v2,l+1) in AF} f[c,u,v,l,u2,v2,l+1];

subject to flowConsG{c in 0..k-1, (u2,v2,l2) in GoalsF[c] }:
	sum{(u1,v1,l1,u2,v2,l2) in AF} f[c,u1,v1,l1,u2,v2,l2] = 1;

subject to capacity {(u1,v1,l1,u2,v2,l2) in AF}:
	sum{c in 0..k-1} f[c,u1,v1,l1,u2,v2,l2] <= 1;

#subject to wfrel {c in 0..k-1,g in Goals[c]}:
#0	f[c,g,g,maxL,g,g,maxL+1] <= w[g];
