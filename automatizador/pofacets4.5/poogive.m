function [coord,facet,scale,symplanes,comments,matrl]=poogive(XR,YR,ZR,N)
% filename: poogive.m
% Project: POFACETS
% Description: This program creates a model of an ogive
% Author:  Filippos % Chatzigeorgiadis
% Date:   February 2004
% Place: NPS

[x,y,z]=ellipsoid(0,0,0,XR,YR,ZR,N);
x=x(:,1:N);
y=y(:,1:N);
z=z(:,1:N);
x=reshape(x',1,prod(size(x)))';
y=reshape(y',1,prod(size(y)))';
z=reshape(z',1,prod(size(z)))';
a=[x,y,z];
coord=a(2:size(a,1)-(N-1),:);
n=size(coord,1);
coord=coord(floor(n/2):n,:);
n=(size(coord,1)-1)/N;

facet=[];
for section=1:n-1
    mul=(section-1)*N;
    for i=1:N
        if i<N
            facet=[facet
                mul+i,mul+i+1,mul+i+N
                mul+i+1,mul+i+1+N,mul+i+N];
        else
            facet=[facet
                mul+i,mul+i+1-N,mul+i+N
                mul+i+1-N,mul+i+1,mul+i+N];
        end
    end
end

%last section
last=size(coord,1);
mul=N*(n-1);
for i=1:N
        if i<N
            facet=[facet
                mul+i,mul+i+1,last];
        else
            facet=[facet
                mul+i,mul+i+1-N,last];
        end
end
%set illumination and RS
facet(:,4)=1;
facet(:,5)=0;
scale=1;
symplanes=[0 0 0];
for i=1:size(facet,1)
    comments{i,1}='Ogive';
    matrl{i,1}='PEC';
    matrl{i,2}=[0 0 0 0 0];
end


  




