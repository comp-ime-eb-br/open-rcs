function [R,theta,phi]=cart2spher(x,y,z)
% filename: cart2spher.m
% Project: POFACETS
% Description: This  function converts cartesian coordinates to spherical 
% Author:  Filippos Chatzigeorgiadis
% Date:   September 2004
% Place: NPS
% Last modifed: Sep 04 (v.3.0)
R=sqrt(x^2+y^2+z^2);
theta=atan2(sqrt(x^2+y^2),z);
phi=atan2(y,x);