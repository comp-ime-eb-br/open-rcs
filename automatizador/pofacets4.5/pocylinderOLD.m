function [coord,facet,scale,symplanes,comments,matrl]=pocylinder(R,H,N,ctop,cbottom)

%Arguments: Radius,Heigth
%N=points to approximate circle in cylinder base
%cbottom='Yes': cylinder has bottom base, otherwise:no bottom base
%ctop='Yes':cylinder has top base, otherwise: no top base
% filename: pocylinder.m
% Project: POFACETS
% Description: This program creates a model of a cylinder with or w/o base
% Author:  Filippos % Chatzigeorgiadis
% Date:   February 2004
% Place: NPS

  switch ctop
     case 'Yes'
        top=1;
     otherwise
        top=0;
     end

   switch cbottom
    case 'Yes'
        bottom=1;
    otherwise
        bottom=0;
    end

Rs=0;

%Create Cylinder
[x,y,z]=cylinder(R,N);
z=z*H;

%eliminate last datapoints (same as first)
x=x(:,1:N);y=y(:,1:N);z=z(:,1:N);
if bottom==1
  %First point is center of bottom base
  fuselage=[0 0 0];
else 
  fuselage=[];
end
%Add all points in cylinder
for j=1:2
    for i=1:N
        fuselage=[fuselage
            x(j,i),y(j,i),z(j,i)];
    end
end
if top==1
%Add  center of top base
fuselage=[fuselage
    0 0 H];
end
coord=fuselage;
% --------------- End Part 1 -----------------



%------------------PART 2 FACETS -----------------
fac=[];
count=0;
ind=0;
if bottom==1
    %Create back cylinder base
 for i=2:N
      fac=[fac
          i,1,i+1,1,Rs];
      ind=ind+1;
      comments{ind}='Bottom base';
  end
  fac=[fac
       N+1,1,2,1,Rs];
   ind=ind+1;
   comments{ind}='Bottom base';
  diff=0;
else
  diff=-1;
end
      
%Create cylinder

    for i=2:N
        fac=[fac
        N+i+diff,i+diff,i+1+diff,1,Rs
        N+i+diff,i+1+diff,N+i+1+diff,1,Rs];
        ind=ind+1;
        comments{ind}='Cylindrical Surface';
        ind=ind+1;
        comments{ind}='Cylindrical Surface';
    end
       fac=[fac
           2*N+1+diff,N+1+diff,2+diff,1,Rs
           2*N+1+diff,2+diff,N+2+diff,1,Rs];
        ind=ind+1;
        comments{ind}='Cylindrical Surface';
        ind=ind+1;
        comments{ind}='Cylindrical Surface';
    
if top==1
last=size(coord,1);
%Create top base
 for i=2:N
       fac=[fac
          N+i+diff,last,N+i+1+diff,1,Rs];
        ind=ind+1;
        comments{ind}='Top base';

 end
 fac=[fac
   2*N+diff,last,N+2+diff,1,Rs];
        ind=ind+1;
        comments{ind}='Top base';
end
facet=fac;
%------------------End Part 2 ---------------------------


scale=1;
symplanes=[0 0 0];
comments=comments';
for i=1:size(facet,1)
   matrl{i,1}='PEC';
   matrl{i,2}=[0 0 0 0 0];
end