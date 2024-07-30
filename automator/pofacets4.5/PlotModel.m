function Plotmodel
% filename: Plotmodel.m  
% Project: POFACETS
% Description: This function plots a model and its symmetry planes 
% Author:  Prof. David C. Jenn, Elmo E. Garrido Jr. and Filippos
% Chatzigeorgiadis
% Date:  12 February 2004
% Place: NPS
global coord nvert modelname
global ntria facet scale symplanes

%clear drawing area
reset(gca);
%number of vertices and facets
nvert=size(coord,1);
ntria=size(facet,1);
%coordinates of all vertices
xpts = coord(:,1)*scale;
ypts = coord(:,2)*scale;
zpts = coord(:,3)*scale;
%nodes of all facets
node1 = facet(:,1); 	
node2 = facet(:,2); 
node3 = facet(:,3);
%illumination and surf resistivity
ilum  = facet(:,4);
Rs	= facet(:,5);
%store node of each vertex to the vind array
for i  = 1:ntria 
			pts = [node1(i) node2(i) node3(i)];
			vind(i,:) = pts;       
end
x = xpts; 	y = ypts; 	z = zpts;
% define X,Y,Z arrays and plot them 
      for i = 1:ntria
         X = [x(vind(i,1)) x(vind(i,2)) x(vind(i,3)) x(vind(i,1))];
    	 Y = [y(vind(i,1)) y(vind(i,2)) y(vind(i,3)) y(vind(i,1))];
	     Z = [z(vind(i,1)) z(vind(i,2)) z(vind(i,3)) z(vind(i,1))];
         plot3(X,Y,Z,'b')
		 if i == 1
     			hold on
         end
      end      
      axis square   
      title(['Triangular Surface of ',modelname,' Model']);
	  xlabel('x');  ylabel('y');    zlabel('z');
% This is to avoid both a max and min of zero in any one dimension
      xmax = max(xpts); xmin = min(xpts);
%       if xmin==xmax
%           xmax=xmin+1;
%       end
      ymax = max(ypts); ymin = min(ypts);
%       if ymin==ymax
%           ymax=ymin+1;
%       end
      zmax = max(zpts); zmin = min(zpts);
%       if zmin==zmax
%           zmax=zmin+1;
%       end
      dmax = max([xmax ymax zmax]); 
      dmin = min([xmin ymin zmin]);
	% This is to avoid both a max and min of zero in any one dimension
	  xmax = dmax; 	ymax = dmax; 	zmax = dmax;
      xmin = dmin; 	ymin = dmin; 	zmin = dmin;
      % add buffer space to plot edges
      bufx=.2*(xmax-xmin);
      bufy=.2*(ymax-ymin);
      bufz=.2*(zmax-zmin);
      axis([xmin-bufx, xmax+bufx, ymin-bufy, ymax+bufy, zmin-bufz, zmax+bufz]*1.1); 
%Plot symmetry planes like triangles
%first check for appropriate number of points (multiple of 3)
      valid=0;
      if mod(size(symplanes,1),3)~=0
          valid=1;
      end
      %3 planes of symmetry, each with different color and triangle size
      col=['r';'g';'y'];
      len=dmax*[0.6,0.4,0.2];
      if valid==0
          for i=1:size(symplanes,1)/3
            %coordinates of all points
            x=len(i)*symplanes((i-1)*3+1:(i-1)*3+3,1);
            y=len(i)*symplanes((i-1)*3+1:(i-1)*3+3,2);
            z=len(i)*symplanes((i-1)*3+1:(i-1)*3+3,3);
            x(4)=x(1);y(4)=y(1);z(4)=z(1);
            %draw the lines
            plot3(x,y,z,col(i),'linewidth',2);
        end
     end
