function [coord, facet, scale, symplanes,comments,matrl]=pofuselage(MFL,RL,R,N,M)

%Arguments, Main Fuselage Length, Radome Length, Radius of Fuselage,
%N=points to approximate circle in cylinder base
%M=points to approximate radome curve
% filename: pofuselage.m
% Project: POFACETS
% Description: This program creates a model of a fuselage
% Author:  Filippos % Chatzigeorgiadis
% Date:   February 2004
% Place: NPS

Rs=0;

%Create Radome points
a=0:M;
b=R*sqrt(abs(M-a)/M);
[x,y,z]=cylinder(b,N);
z=RL*z+MFL;
%eliminate peak points and common points with fuselage
x=x(2:M,:);
y=y(2:M,:);
z=z(2:M,:);
%Create Fuselage
[xa,ya,za]=cylinder(R,N);
za=za*MFL;

%Connect Radome and Fuselage
x=[xa
    x];
y=[ya
    y];
z=[za
    z];
%eliminate last datapoints (same as first)
x=x(:,1:N);y=y(:,1:N);z=z(:,1:N);
%First point is center of exhaust
fuselage=[0 0 0];
%Add all points in fuselage
for j=1:M+1
    for i=1:N
        fuselage=[fuselage
            x(j,i),y(j,i),z(j,i)];
    end
end

%Add  tip of UAV radome
coord=[fuselage
    0 0 MFL+RL];
% --------------- End Part 1 -----------------



%------------------PART 2 FACETS -----------------
fac=[];
count=0;
ind=0;
%Create back cylinder base
for i=2:N
      fac=[fac
          i,1,i+1,1,Rs];
        ind=ind+1;
        comments{ind}='Fuselage base';
  end
  fac=[fac
       N+1,1,2,1,Rs];
  ind=ind+1;
        comments{ind}='Fuselage base';
      
%Create main fuselage
for level=0:M-1
    start=(level)*N;
    for i=2:N
        fac=[fac
        N+start+i,start+i,start+i+1,1,Rs
        N+start+i,start+i+1,N+start+i+1,1,Rs];
       ind=ind+1;
       comments{ind}='Fuselage';
       ind=ind+1;
       comments{ind}='Fuselage';
    end
       fac=[fac
           2*N+start+1,N+start+1,start+2,1,Rs
           2*N+start+1,start+2,N+start+2,1,Rs];
      ind=ind+1;
       comments{ind}='Fuselage';
       ind=ind+1;
       comments{ind}='Fuselage';   
        
               
end


%Create radome tip
for i=2:N
       fac=[fac
          (M+1)*N+2,M*N+i,M*N+i+1,1,Rs];
     ind=ind+1;
     comments{ind}='Radome';

end
fac=[fac
   (M+1)*N+2,M*N+N+1,M*N+2,1,Rs];
     ind=ind+1;
     comments{ind}='Radome';
       
facet=fac;
%------------------End Part 2 ---------------------------


scale=1;
symplanes=[0 0 0];
comments=comments';
for i=1:size(facet,1)
    matrl{i,1}='PEC';
    matrl{i,2}=[0 0 0 0 0];
end

