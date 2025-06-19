% Use this editor as a MiniZinc scratch book
include "globals.mzn";
enum CONTROL_SHIFT = {MORNING,AFTERNOON,NIGHT,OFF};

int : air_t_controllers ;
set of int: CONTROLLERS = 1..air_t_controllers;
set of int: DAYS = 1..7;

%% Some Decision Vars (You can add more)
array[CONTROLLERS,DAYS] of var CONTROL_SHIFT: roster;
array[CONTROLLERS] of var int: work;
var 0..4*7: gap;

%%%%% Add your model here
int: ns = 5;
set of int : STATE = 1..ns;
array[STATE,CONTROL_SHIFT] of opt STATE : allowed =
 % MRN AFT NGT OFF
 [| 2,  3,  5, 1
  | 3,  4, <>, 1
  | 4,  5, <>, 1
  | 5, <>, <>, 1
  |<>, <>, <>, 1|];
  
constraint forall(c in CONTROLLERS)(
  regular(row(roster,c), allowed, 1, STATE)
);

% Daily staffing requirements
constraint forall(d in DAYS) (
  sum(c in CONTROLLERS)(roster[c,d] = MORNING) >= 3
  /\
  sum(c in CONTROLLERS)(roster[c,d] = AFTERNOON) >= 2  
  /\
  sum(c in CONTROLLERS)(roster[c,d] = NIGHT) >= 1
);

% Each controller must work at least one of each shift type during the week
constraint forall(c in CONTROLLERS) (
  sum(d in DAYS)(roster[c,d] = MORNING) >= 1
  /\
  sum(d in DAYS)(roster[c,d] = AFTERNOON) >= 1
  /\
  sum(d in DAYS)(roster[c,d] = NIGHT) >= 1
);

% Calculate work points for each controller
array[CONTROL_SHIFT] of int: shift_work = [MORNING: 1, AFTERNOON: 2, NIGHT: 4, OFF: 0];

constraint forall(c in CONTROLLERS) (
  work[c] = sum(d in DAYS)(shift_work[roster[c,d]])
);

% Maximum amount of possible shifts in a week, optimization
constraint forall(c in CONTROLLERS) (
  sum(d in DAYS)(roster[c,d] = NIGHT) <= 2
  /\
  sum(d in DAYS)(roster[c,d] = AFTERNOON) <= 3
  /\
  sum(d in DAYS)(roster[c,d] = MORNING) <= 3
);

% Maximum possible work points a controller can have, optimization
constraint forall(c in CONTROLLERS) (
  work[c] >= 7 /\ work[c] <= 12 
);

constraint gap = max(work) - min(work);
constraint gap = 1;
solve 
  :: int_search(
       [roster[c,d] | c in CONTROLLERS, d in DAYS], 
       dom_w_deg,
       indomain_random,
       complete
     )
  :: restart_luby(1000)
  minimize gap;
      
%%% DO NOT CHANGE THE FOLLWOING LINES

output ["% Just for debugging. The table of shifts.\n%"]
       ++ [format(10,D) | D in DAYS ] ++ ["\n% "]
       ++ [format(10,roster[C,D]) ++ if (D==card(DAYS)) then "\n% " else "" endif | C in CONTROLLERS, D in DAYS]
       ++ ["% Raw Data in Tables ------------ \n"]
       ++ ["roster = \(roster); \nwork = \(work); \ngap=\(gap);\n"]
       
