%%% Truck Delivery

include "globals.mzn";

% Number of Trucks and the associated set
int : ntrucks;
set of int: TRUCKS = 1..ntrucks;
array[TRUCKS] of int: max_truck_weight;
array[TRUCKS] of int: speed;

% Number of deliveries and the associated set
int: ndeliveries;
set of int: DELIVERIES = 1..ndeliveries;
array[DELIVERIES] of int: weight;
array[DELIVERIES] of TIME: ready_after;
array[DELIVERIES] of int: distance;
%% Setting Time to a constant range
set of int: TIME = 0..1000;

%%% Build Your Model here
array[DELIVERIES] of var TRUCKS: onTruck;
array[DELIVERIES] of var TIME: depart;
array[DELIVERIES] of var int: delivery_time;
array[DELIVERIES] of var TIME: finish_time;

constraint forall(d in DELIVERIES)(
  depart[d] >= ready_after[d]
);

constraint forall(d in DELIVERIES)(
  delivery_time[d] = distance[d] div speed[onTruck[d]]
);

constraint forall(d in DELIVERIES)(
  finish_time[d] = depart[d] + delivery_time[d]
);

constraint forall(d in DELIVERIES)(
  weight[d] <= max_truck_weight[onTruck[d]]
);

constraint forall(d1, d2 in DELIVERIES where d1 < d2)(
  onTruck[d1] = onTruck[d2] -> 
  (finish_time[d1] <= depart[d2] \/ finish_time[d2] <= depart[d1])
);

constraint cumulative(depart, delivery_time, [1 | d in DELIVERIES], 2);

var TIME: makespan;
constraint makespan = max(finish_time);
solve minimize makespan;

%%% DO NOT CHANGE THE FOLLOWING LINES
output [" depart = \(depart); \n delivery_time = \(delivery_time); \n"] ++
       [" onTruck = \(onTruck); \n makespan = \(makespan)"];
       