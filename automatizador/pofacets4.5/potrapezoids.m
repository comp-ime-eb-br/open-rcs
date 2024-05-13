function [coord,facet,scale,symplanes,comments,matrl]=potrapezoids(BB,W,A1,A2,H)
% Arguments: Big Base, Width, Angles (in degrees),Height
% filename: potrapezoids.m
% Project: POFACETS
% Description: This program creates a trapezoid (assumes theta and phi of
% height are zero)
% Author:  Filippos Chatzigeorgiadis
% MODIFIED TO DO A PLATE IF H=0 (Jenn 2018)
% Date:   February 2004
% Place: NPS

%convert angles to radians
A1r=A1*pi/180;
A2r=A2*pi/180;

%Calculate x positions of small base edges
if A1~=90
    x4=W/tan(A1r);
else
    x4=0;
end
if A2~=90
    x3=BB-W/tan(A2r);
else
    x3=BB;
end
if H>=0
coord=[0 0 0
    BB 0 0
    x3 W 0
    x4 W 0
    0 0 H
    BB 0 H
    x3 W H
    x4 W H];
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
coord=[0 0 0
    BB 0 0
    x3 W 0
    x4 W 0];
facet=[1 2 3; 1 3 4];
facet(:,4)=0;
facet(:,5)=0;
end
scale=1;
symplanes=[0 0 0];
for i=1:size(facet,1)
    comments{i,1}='Trapezoid';
    matrl{i,1}='PEC';
    matrl{i,2}=[0 0 0 0 0];
end


  




