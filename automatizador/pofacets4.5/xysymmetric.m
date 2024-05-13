function xysymmetric
% filename: xysymmetric.m
% Project: POFACETS
% Description: This function generates the symmetric of a model 
% with respect to the xy plane
% The output matrices contain both the original and symmetric model
% Author:  Filippos Chatzigeorgiadis
% Date:  11 June 2004
% Place: NPS

global coord facet matrl

ncoord=size(coord,1);

%z coordinate symmetrical to xy plane
coordsym=coord;
coordsym(:,3)=-coordsym(:,3);
%merge coordinates
coord=[coord;coordsym];

% order of facet changes to keep same outward vector
facetsym=facet;
facetsym(:,2)=facet(:,3);
facetsym(:,3)=facet(:,2);
% new facet numbers
facetsym(:,1:3)=facetsym(:,1:3)+ncoord;
%merge facets
facet=[facet;facetsym];


%material
matrl=[matrl;matrl];