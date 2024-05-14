function [coord,facet,scale,symplanes,comments,matrl]=poboxes(L,W,H,ALW,ATH,APHI)
% Arguments: Length, Width, Height, Angles:Length to Width, THETA,PHI OF
% Height (in degrees)
% filename: poboxes.m
% Project: POFACETS
% Description: This program creates a model of an arbitrary box
% Author:  Filippos Chatzigeorgiadis
% MODIFIED TO DO A PLATE IF H=0 (Jenn 2018)
% Date:   February 2018
% Place: NPS

%convert angles to radians
ALW=ALW*pi/180;
ATH=ATH*pi/180;
APHI=APHI*pi/180;
%find coordinates of top above 0 0 0
xtop=H*sin(ATH)*cos(APHI);
ytop=H*sin(ATH)*sin(APHI);
ztop=H*cos(ATH);
xyztop=[xtop ytop ztop];
xyztop=[xyztop
    xyztop
    xyztop
    xyztop];
%base vertices
base=[0 0 0
    W 0 0
    L*cos(ALW)+W L*sin(ALW) 0
    L*cos(ALW) L*sin(ALW) 0];
if H==0, coord=base; end
%top vertices

if H>0, top=base+xyztop; coord=[base
    top];
end

%facets
if H>0
facet=[1 3 2; 1 4 3;
    1 2 6; 1 6 5;
    1 5 4; 4 5 8;
    2 3 6;3 7 6;
    3 4 8; 3 8 7;
    5 6 7; 5 7 8];
facet(:,4)=1;
facet(:,5)=0;
end
if H==0
    facet=[1 2 3; 1 3 4];
    facet(:,4)=0;
    facet(:,5)=0;
end
%save
scale=1;
symplanes=[0 0 0];
for i=1:size(facet,1)
    if H>0, comments{i,1}='Box'; end
    if H==0, comments{i,1}='Plate'; end
    matrl{i,1}='PEC';
    matrl{i,2}=[0 0 0 0 0];
end
  




