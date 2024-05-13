function T21=transfmatrix(a,b)
% filename: transfmatrix.m
% Project: POFACETS
% Description: This  function receives the rotation angles of a facet
% and computes the product of the two transformation matrices
% Author:  Filippos Chatzigeorgiadis
% Date:   September 2004
% Place: NPS
% Last modifed: Sep 04 (v.3.0)
T1=[cos(a) sin(a) 0; -sin(a) cos(a) 0; 0 0 1];
T2=[cos(b) 0 -sin(b); 0 1 0; sin(b) 0 cos(b)];
T21=T2*T1;
    