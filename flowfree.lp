% This .lp program needs clingo 3.0.5

%	Configuration to be solved
%	R Y * *
%	* * B *
%	* Y R *
%	* * * B

% construction of the grid
cell(0,0). cell(0,1). cell(0,2). cell(0,3).
cell(1,0). cell(1,1). cell(1,2). cell(1,3).
cell(2,0). cell(2,1). cell(2,2). cell(2,3).
cell(3,0). cell(3,1). cell(3,2). cell(3,3).

#const rows=4.
#const cols=4.
#const lasttime=rows*cols.

time(0..lasttime).
row(0..rows-1).
col(0..cols-1).

#const numbercolors=3.
color(red;yellow;blue).

% Starting position of edges - If you want to change the configuration to be solved, you must change this positions
startXRed(0). startYRed(0). endXRed(2). endYRed(2).
startXYellow(0). startYYellow(1). endXYellow(2). endYYellow(1).
startXBlue(1). startYBlue(2). endXBlue(3). endYBlue(3).



% GENERATE
% Generate the potential solutions of the problem.

% Define a potential solution to be an arbitrary set of move actions executed prior to lasttime such that, 
% for every T, the number of actions executed at time T is at most the number of colors:
0 {move(X,Y,C,T) : row(X) : col(Y) : color(C)} numbercolors :- time(T), T<lasttime.


% DEFINE
% Define the sequence of states in a potential solution.

% uniqueness of location - if the agent is at (X,Y) at time T, then it is not anywhere else at time T
-move(X,Y1,C,T) :- move(X,Y,C,T), Y!=Y1, row(X), col(Y), col(Y1), color(C), time(T).
-move(X1,Y,C,T) :- move(X,Y,C,T), X!=X1, row(X), col(Y), col(X1), color(C), time(T).

% TEST
% Weed-out the answer-sets that do not correspond to real solutions.

% Can't move to a non-cell position
:- move(X,Y,C,T), not cell(X,Y), row(X), col(Y), color(C), time(T).

% Can't stay still or pass several times on the same location
:- move(X,Y,C,T), move(X,Y,C,T1), T!=T1, row(X), col(Y), color(C), time(T), time(T1).

% Can't move to a diagonal and to a non-adjacent location
:- move(X,Y,C,T), move(X1,Y1,C,T+1), #abs(X-X1)>1, row(X), col(Y), row(X1), col(Y1), color(C), time(T), T<lasttime.
:- move(X,Y,C,T), move(X1,Y1,C,T+1), #abs(Y-Y1)>1, row(X), col(Y), row(X1), col(Y1), color(C), time(T), T<lasttime.
:- move(X,Y,C,T), move(X1,Y1,C,T+1), X1==X+1, Y1==Y+1, row(X), col(Y), row(X1), col(Y1), color(C), time(T), T<lasttime.
:- move(X,Y,C,T), move(X1,Y1,C,T+1), X1==X-1, Y1==Y-1, row(X), col(Y), row(X1), col(Y1), color(C), time(T), T<lasttime.
:- move(X,Y,C,T), move(X1,Y1,C,T+1), X1==X-1, Y1==Y+1, row(X), col(Y), row(X1), col(Y1), color(C), time(T), T<lasttime.
:- move(X,Y,C,T), move(X1,Y1,C,T+1), X1==X+1, Y1==Y-1, row(X), col(Y), row(X1), col(Y1), color(C), time(T), T<lasttime.

% Can't have a move in time T and NOT have a move in time T-1, for any T>0
1 { move(X,Y,C,T-1) : row(X) : col(Y) : color(C) } 1 :- move(X1,Y1,C,T), color(C), row(X1), col(Y1), time(T), T>0.

% The path must start at the initial position
1 { move(R, C, red, 0) : startXRed(R) : startYRed(C) } 1.
1 { move(R, C, yellow, 0) : startXYellow(R) : startYYellow(C) } 1.
1 { move(R, C, blue, 0) : startXBlue(R) : startYBlue(C) } 1.

% The path must end at the final position
1 { move(R, C, red, T) : time(T) : endXRed(R) : endYRed(C) } 1.
1 { move(R, C, yellow, T) : time(T) : endXYellow(R) : endYYellow(C) } 1.
1 { move(R, C, blue, T) : time(T) : endXBlue(R) : endYBlue(C) } 1.

% Can't have a move after that you find the final edge
:- move(R,C,red,T), move(X,Y,red,T1), row(X), col(Y), time(T), time(T1), T1>T, endXRed(R), endYRed(C).
:- move(R,C,yellow,T), move(X,Y,yellow,T1), row(X), col(Y), time(T), time(T1), T1>T, endXYellow(R), endYYellow(C).
:- move(R,C,blue,T), move(X,Y,blue,T1), row(X), col(Y), time(T), time(T1), T1>T, endXBlue(R), endYBlue(C).

% The direct path between two adjacent edges is not allowed
:- move(X,Y,C,T), move(X1,Y1,C,T1), startXRed(X), endXRed(X1), startYRed(Y), endYRed(Y1), color(C), time(T), time(T1), T1==T+1.
:- move(X,Y,C,T), move(X1,Y1,C,T1), startXYellow(X), endXYellow(X1), startYYellow(Y), endYYellow(Y1), color(C), time(T), time(T1), T1==T+1.
:- move(X,Y,C,T), move(X1,Y1,C,T1), startXBlue(X), endXBlue(X1), startYBlue(Y), endYBlue(Y1), color(C), time(T), time(T1), T1==T+1.

% Pipes cannot intersect each other
:- move(X,Y,C,T), move(X,Y,C1,T1), row(X), col(Y), color(C), color(C1), time(T), time(T1), C!=C1.

% All the cells must be colored (lasttime=rows*columns)
lasttime { move(X,Y,C,T) : row(X) : col(Y) : color(C): time(T) } lasttime .

#hide. 
#show move(X,Y,C,T).