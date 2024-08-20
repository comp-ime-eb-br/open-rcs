function [coord,facet,scale,symplanes,comments,matrl]=posphere(XR,YR,ZR,N)
% filename: posphere.m
% Project: POFACETS
% Description: This program creates a model of an ellipsoid or sphere
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
coord=a(N:size(a,1)-(N-1),:);

facet=[];
%bottom section
for i=1:N
  if i<N
    facet=[facet
        1,i+2,i+1];
  else
     facet=[facet
        1,2,i+1];
  end
end

%intermediate sections
for section=1:N-2
    mul=(section-1)*N;
    for i=1:N
        if i<N
            facet=[facet
                 mul+i+1,mul+i+2,mul+i+1+N
                 mul+i+2,mul+i+2+N,mul+i+1+N];
                                 
        else
            facet=[facet
                 mul+i+1,mul+i+2-N,mul+i+1+N
                 mul+i+2-N,mul+i+2,mul+i+1+N];
  
        end
    end
end

%last section
last=size(coord,1);
mul=N*(N-2);
for i=1:N
        if i<N
            facet=[facet
                mul+i+1,mul+i+2,last];
        else
            facet=[facet
                mul+i+1,mul+i+2-N,last];
        end
end
%set illumination and RS
facet(:,4)=1;
facet(:,5)=0;
scale=1;
symplanes=[0 0 0];
if XR==YR & YR==ZR
    txt='Sphere';
else
    txt='Ellipsoid';
end
for i=1:size(facet,1)
    comments{i,1}=txt;
    matrl{i,1}='PEC';
    matrl{i,2}=[0 0 0 0 0];
end

  




