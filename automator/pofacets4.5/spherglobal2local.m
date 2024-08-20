function [Rloc,thetaloc,philoc]=spherglobal2local(R,theta,phi,T21)
% filename: spherglobal2local.m
% Project: POFACETS
% Description: This  function converts global spherical coordinates to
% local spherical coordinates
% Author:  Filippos Chatzigeorgiadis
% Date:   September 2004
% Place: NPS
% Last modifed: Sep 04 (v.3.0)
%convert to cartesian,
[x,y,z]=spher2cart(R,theta,phi);
%transform to local coordinates
tmp=T21*[x;y;z];
%convert to spherical
[Rloc,thetaloc,philoc]=cart2spher(tmp(1),tmp(2),tmp(3));



