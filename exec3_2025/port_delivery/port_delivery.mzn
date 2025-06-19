%%% Port Delivery
include "globals.mzn";
% number of trucks
int: num_trucks;
int:num_derricks;
set of int: TRUCKS = 1..num_trucks;
int: max_time;
set of int: TIME = 0..max_time;
enum CDATA = {BOXES,DEST};

array[TRUCKS,CDATA] of int: delivery; 

enum WAREHOUSES = {wh1,wh2};
array[WAREHOUSES] of int: travel_time = [15,20];

%%%% ADD YOUR CODE HERE
int: LOAD_TIME = 4;
int: UNLOAD_TIME = 1;

array[TRUCKS] of var TIME: StartLoad;
array[TRUCKS] of var TIME: StartUnload;
array[TRUCKS] of var TIME: End;

array[TRUCKS] of int: load_durations = [delivery[t, BOXES] * LOAD_TIME | t in TRUCKS];
array[TRUCKS] of int: unload_durations = [delivery[t, BOXES] * UNLOAD_TIME | t in TRUCKS];

% Loading of the trucks
constraint cumulative(StartLoad, load_durations, [1 | t in TRUCKS], num_derricks);

% Unloading of the trucks
constraint forall(w in WAREHOUSES) (
  let {
    set of int: WTRUCKS = {t | t in TRUCKS where delivery[t, DEST] == w}
  } in
  disjunctive([StartUnload[t] | t in WTRUCKS], [unload_durations[t] | t in WTRUCKS])
);

% Start time of unloading
constraint forall(t in TRUCKS) (
  StartUnload[t] >= StartLoad[t] + load_durations[t] + travel_time[to_enum(WAREHOUSES, delivery[t, DEST])]
);

% Finish of unloading
constraint forall(t in TRUCKS) (
  End[t] = StartUnload[t] + unload_durations[t]
);

var TIME: makespan;
constraint makespan = max([End[t] | t in TRUCKS]);
solve minimize makespan;

output [
  "StartLoad = ", show(StartLoad), "\n",
  "StartUnload = ", show(StartUnload), "\n",
  "End = ", show(End), "\n",
  "_objective = ", show(makespan)
];
