function [x,y,z]=spher2cart(R,theta,phi)
% filename: spher2cart.m
% Project: POFACETS
% Description: This  function converts spherical coordinates to
%  cartesian coordinates
% Author:  Filippos Chatzigeorgiadis
% Date:   September 2004
% Place: NPS
% Last modifed: Sep 04 (v.3.0)
x=R*sin(theta)*cos(phi);
y=R*sin(theta)*sin(phi);
z=R*cos(theta);