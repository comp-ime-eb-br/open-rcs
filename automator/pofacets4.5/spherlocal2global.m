function [R,theta,phi]=spherlocal2global(Rloc,thetaloc,philoc,T21)
% filename: spherlocal2global.m
% Project: POFACETS
% Description: This  function converts local spherical coordinates to
% global spherical coordinates
% Author:  Filippos Chatzigeorgiadis
% Date:   September 2004
% Place: NPS
% Last modifed: Sep 04 (v.3.0)
%convert to cartesian,
[xloc,yloc,zloc]=spher2cart(Rloc,thetaloc,philoc);
%transform to local coordinates
tmp=inv(T21)*[xloc;yloc;zloc];
%convert to spherical
[R,theta,phi]=cart2spher(tmp(1),tmp(2),tmp(3));



