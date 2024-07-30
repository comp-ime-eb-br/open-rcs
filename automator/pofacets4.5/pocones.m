function [coord,facet,scale,symplanes,comments,matrl]=pocones(R,H,N,base)
%Arguments: Radius, Heigh, # of points, base: 'Yes' to create, anything else to skip
% filename: pocones.m
% Project: POFACETS
% Description: This program creates a model of a cone with or w/o base
% Author:  Filippos % Chatzigeorgiadis
% Date:   February 2004
% Place: NPS

[x,y,z]=cylinder(R,N);
x=x(1,1:N)';
y=y(1,1:N)';
z=z(1,1:N)';
ind=0;
switch base
    case 'Yes'
       coord=[0 0 0
       x y z
       0 0 H];
       facet=[];
      %base
        for i=1:N
          if i<N
            facet=[facet
                1,i+2,i+1];
          else
            facet=[facet
              1,2,i+1];
            end
            ind=ind+1;
            comments{ind}='Cone Base';
        end

    %conical surface
    last=size(coord,1);
    for i=1:N
      if i<N
        facet=[facet
            last,i+1,i+2];
      else
        facet=[facet
            last,i+1,2];
      end
      ind=ind+1;
      comments{ind}='Conical Surface';
   end
   
otherwise
    coord=[x y z
       0 0 H];
       facet=[];
       comments=[];
     %conical surface
    last=size(coord,1);
    for i=1:N
      if i<N
        facet=[facet
            last,i,i+1];
      else
        facet=[facet
            last,i,1];
      end
      ind=ind+1;
      comments{ind}='Cone Base';
  end
end% switch
%set illumination and RS
facet(:,4)=1;
facet(:,5)=0;
scale=1;
symplanes=[0 0 0];
for i=1:size(facet,1)
    matrl{i,1}='PEC';
    matrl{i,2}=[0 0 0 0 0];
end
comments=comments';

