% Use this editor as a MiniZinc scratch book
%% size of map (grid_size * grid_size)
int:grid_size;
%% the set of positions (coordinates for x and y)
set of int: POSITIONS = 1..grid_size;
%% Distance Domain 
set of int: DIST_RANGE = 0..2*(grid_size - 1);
%% number of clients
int: num_clients;
set of int: CLIENTS = 1..num_clients;
%% number of facilities to be placed
int: num_facilities;
set of int: FACILITIES = 1..num_facilities;
%% Sets the minimum distance between any two facilities;
int : distance_between_facilities;
% To easily access coordinates
enum COORDS = {POSX,POSY};
% client Locations (data)
array[CLIENTS,COORDS] of int: client_loc;
% minimum distance between facilities and clients (different for each facility)
array[FACILITIES] of int: min_distance;

%%% ADD your code here
array[CLIENTS] of var DIST_RANGE: client_min_distance;                                                                                         
var DIST_RANGE: max_of_mins; 

array[FACILITIES, COORDS] of var POSITIONS: facility_loc;

constraint forall(i, j in FACILITIES where i < j) (
  abs(facility_loc[i, POSX] - facility_loc[j, POSX]) + abs(facility_loc[i, POSY] - facility_loc[j, POSY]) > distance_between_facilities
);

constraint forall(f in FACILITIES, c in CLIENTS) (
  abs(facility_loc[f, POSX] - client_loc[c, POSX]) + abs(facility_loc[f, POSY] - client_loc[c, POSY]) > min_distance[f]
);

constraint forall(c in CLIENTS) (
  client_min_distance[c] = min([abs(facility_loc[f, POSX] - client_loc[c, POSX]) + abs(facility_loc[f, POSY] - client_loc[c, POSY]) | f in FACILITIES])
);

constraint max_of_mins = max(client_min_distance);
solve minimize max_of_mins;

% Heuristic 1: First-fail
/*
solve :: int_search(
 [facility_loc[f,c] | f in FACILITIES, c in COORDS], 
 first_fail, 
 indomain_min, 
 complete
) minimize max_of_mins;
*/

% Heuristic 2: Anti-first-fail
/*
solve :: int_search(
  [facility_loc[f,c] | f in FACILITIES, c in COORDS],
  anti_first_fail,
  indomain_min,
  complete
) minimize max_of_mins;
*/

% Heuristic 3: Domain-Weighted Degree
/*
solve :: int_search(
  [facility_loc[f,c] | f in FACILITIES, c in COORDS], 
  dom_w_deg, 
  indomain_min,
  complete
) minimize max_of_mins;
*/


%%% DO NOT CHANGE OUTPUT
output [" client_min_distance = \(client_min_distance);\n max_of_mins = \(max_of_mins);"];
